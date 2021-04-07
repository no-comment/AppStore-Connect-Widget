//
//  APIKey.swift
//  AC Widget
//
//  Created by Miká Kruschel on 04.04.21.
//

import Foundation
import UIKit
import SwiftUI
import WidgetKit

struct APIKey: Codable, Identifiable {
    var id: String { privateKeyID }
    let name: String
    let color: Color
    let issuerID: String
    let privateKeyID: String
    let privateKey: String
    let vendorNumber: String
}

extension APIKey {
    func checkKey() -> APIError? {
        // TODO: Check API Key
        return nil
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

// MARK: Codable Color Extension
// From: http://brunowernimont.me/howtos/make-swiftui-color-codable
fileprivate extension Color {
    // swiftlint:disable:next large_tuple
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        #if os(macOS)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
        #else
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Pay attention that the color should be convertible into RGB format
            // Colors using hue, saturation and brightness won't work
            return nil
        }
        #endif

        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)

        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}
