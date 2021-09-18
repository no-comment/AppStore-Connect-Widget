//
//  APIKey.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import UIKit
import SwiftUI
import WidgetKit
import Promises
import KeychainAccess

class APIKeyProvider: ObservableObject {
    @Published private(set) var apiKeys: [APIKey]

    init() {
        do {
            guard let data = try APIKeyProvider.keychain.getData(APIKeyProvider.keychainKey), !data.isEmpty else {
                apiKeys = []
                return
            }
            apiKeys = try APIKeyProvider.getKeysFromData(data)
        } catch {
            print(error.localizedDescription)
            apiKeys = []
            #if DEBUG
            fatalError(error.localizedDescription)
            #endif
        }
    }

    private static let keychain = Keychain(service: "dev.kruschel.AC-Widget.AC", accessGroup: "E348R9JYR6.dev.kruschel.AC-Widget")
        .synchronizable(true)
    private static let keychainKey = "ac-api-key"

    static private func getKeysFromData(_ data: Data) throws -> [APIKey] {
        let keys = try JSONDecoder().decode([APIKey].self, from: data)
        return keys
    }

    func getApiKey(apiKeyId: String) -> APIKey? {
        return apiKeys.first(where: { $0.id == apiKeyId })
    }

    /// Saves APIKey to UserDefaults; Replaces any key with same id (PrivateKeyId)
    /// - Parameter apiKey: new or updated APIKey
    func addApiKey(apiKey: APIKey) throws {
        apiKeys.removeAll(where: { $0.id == apiKey.id })
        apiKeys.append(apiKey)
        let encoded = try JSONEncoder().encode(apiKeys)
        try APIKeyProvider.keychain.set(encoded, key: APIKeyProvider.keychainKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    @discardableResult
    func deleteApiKey(apiKey: APIKey) -> Bool {
        apiKeys.removeAll(where: { $0.id == apiKey.id })
        do {
            let encoded = try JSONEncoder().encode(apiKeys)
            try APIKeyProvider.keychain.set(encoded, key: APIKeyProvider.keychainKey)
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    func deleteApiKeys(keys: [APIKey]) -> Bool {
        apiKeys.removeAll(where: { del in
            return keys.contains(where: { other in
                return del.id == other.id
            })
        })
        do {
            let encoded = try JSONEncoder().encode(apiKeys)
            try APIKeyProvider.keychain.set(encoded, key: APIKeyProvider.keychainKey)
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            return false
        }
    }
}

struct APIKey: Codable, Identifiable {
    var id: String { privateKeyID }
    let name: String
    let color: Color
    let issuerID: String
    let privateKeyID: String
    let privateKey: String
    let vendorNumber: String

    init(name: String, color: Color, issuerID: String, privateKeyID: String, privateKey: String, vendorNumber: String) {
        self.name = name
        self.color = color
        self.issuerID = issuerID
        self.privateKeyID = privateKeyID
        self.vendorNumber = vendorNumber

        self.privateKey = privateKey
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .removeCharacters(from: .whitespacesAndNewlines)
    }
}

extension APIKey {
    func equalsKeyDetails(other key: APIKey) -> Bool {
        return self.issuerID == key.issuerID && self.privateKeyID == key.privateKeyID && self.privateKey == key.privateKey && self.privateKeyID == key.privateKeyID
    }
}

extension APIKey {
    // swiftlint:disable:next large_tuple
    static private var lastChecks: [(key: APIKey, date: Date, result: Promise<Void>)] = []

    static func clearInMemoryCache() {
        lastChecks = []
    }

    func checkKey() -> Promise<Void> {
        if let last = APIKey.lastChecks.first(where: { self.equalsKeyDetails(other: $0.key) }) {
            if last.date.timeIntervalSinceNow > -30 {
                return last.result
            } else {
                APIKey.lastChecks.removeAll(where: { $0.key.id == self.id })
            }
        }

        let promise = Promise<Void>.pending()

        let api = AppStoreConnectApi(apiKey: self)
        api.getData(currency: .system, numOfDays: 1, useCache: false)
            .then { _ in
                promise.fulfill(())
            }
            .catch { error in
                if let error = error as? APIError {
                    if error == .noDataAvailable {
                        promise.fulfill(())
                    } else {
                        promise.reject(error)
                    }
                } else {
                    promise.reject(APIError.unknown)
                }
            }

        APIKey.lastChecks.append((key: self, date: Date(), result: promise))

        return promise
    }

    static let example = APIKey(name: "Example Key",
                                color: .accentColor,
                                issuerID: "2345-324-12",
                                privateKeyID: "AJDBS7K",
                                privateKey: "sjgdsdjfvnjsdhvjshgs834zuegrh794zthweurhgeurh3479zhuewfheuwzrt97834ehgh34e9tn",
                                vendorNumber: "94658")
}

extension APIKey {
    static let demoKeyName = "demoKey1234"
}

extension ApiKeyParam {
    convenience init(key: APIKey) {
        self.init(identifier: key.id, display: key.name)
    }

    func toApiKey() -> APIKey? {
        return APIKeyProvider().getApiKey(apiKeyId: self.identifier ?? "")
    }

    func getColor() -> Color? {
        return self.toApiKey()?.color
    }
}
