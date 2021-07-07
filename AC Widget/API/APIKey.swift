//
//  APIKey.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import UIKit
import SwiftUI
import WidgetKit
import Promises

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

    static func getDataFromKeys(_ keys: [APIKey]) -> Data? {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(keys)
        return data
    }

    static func getKeysFromData(_ data: Data) -> [APIKey]? {
        let decoder = JSONDecoder()
        let keys = try? decoder.decode([APIKey].self, from: data)
        return keys
    }

    static func getApiKeys() -> [APIKey] {
        guard let data: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.apiKeys) else { return [] }
        return getKeysFromData(data) ?? []
    }

    static func getApiKey(apiKeyId: String) -> APIKey? {
        return getApiKeys().first(where: { $0.id == apiKeyId })
    }

    /// Saves APIKey to UserDefaults; Replaces any key with same id (PrivateKeyId)
    /// - Parameter apiKey: new or updated APIKey
    static func addApiKey(apiKey: APIKey) {
        var keys: [APIKey] = []
        if let data: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.apiKeys) {
            keys = getKeysFromData(data) ?? []
        }
        keys.removeAll(where: { $0.id == apiKey.id })
        keys.append(apiKey)
        let newData = getDataFromKeys(keys)
        UserDefaults.shared?.setValue(newData, forKey: UserDefaultsKey.apiKeys)
        WidgetCenter.shared.reloadAllTimelines()
    }

    @discardableResult
    static func deleteApiKey(apiKey: APIKey) -> Bool {
        guard let data: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.apiKeys) else { return false }
        guard var keys = getKeysFromData(data) else { return false }
        keys.removeAll(where: { $0.id == apiKey.id })
        let newData = getDataFromKeys(keys)
        UserDefaults.shared?.setValue(newData, forKey: UserDefaultsKey.apiKeys)
        WidgetCenter.shared.reloadAllTimelines()
        return true
    }

    @discardableResult
    static func deleteApiKeys(apiKeys: [APIKey]) -> Bool {
        guard let data: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.apiKeys) else { return false }
        guard var keys = getKeysFromData(data) else { return false }
        keys.removeAll(where: { del in
            return apiKeys.contains(where: { other in
                return del.id == other.id
            })
        })
        let newData = getDataFromKeys(keys)
        UserDefaults.shared?.setValue(newData, forKey: UserDefaultsKey.apiKeys)
        WidgetCenter.shared.reloadAllTimelines()
        return true
    }
}

extension APIKey {
    static let demoKeyName = "demoKey1234"
}

extension ApiKeyParam {
    convenience init(key: APIKey) {
        self.init(identifier: key.id, display: key.name)
    }

    func toApiKey() -> APIKey? {
        return APIKey.getApiKeys().first(where: { $0.id == self.identifier })
    }

    func getColor() -> Color? {
        return self.toApiKey()?.color
    }
}
