//
//  APIKey.swift
//  AC Widget
//
//  Created by Miká Kruschel on 04.04.21.
//

import Foundation

struct APIKey: Codable, Identifiable {
    var id: String { privateKeyID }
    let name: String
    let issuerID: String
    let privateKeyID: String
    let privateKey: String
    let vendorNumber: String
}

extension APIKey {
    func checkKey() -> APIError? {
        return nil
    }

    static let example = APIKey(name: "Example Key",
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

    @discardableResult
    static func addApiKey(apiKey: APIKey) -> Bool {
        guard let data: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.apiKeys) else { return false }
        guard var keys = getKeysFromData(data) else { return false }
        keys.append(apiKey)
        let newData = getDataFromKeys(keys)
        UserDefaults.shared?.setValue(newData, forKey: UserDefaultsKey.apiKeys)
        return true
    }

    @discardableResult
    static func deleteApiKey(apiKey: APIKey) -> Bool {
        guard let data: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.apiKeys) else { return false }
        guard var keys = getKeysFromData(data) else { return false }
        keys.removeAll(where: { $0.id == apiKey.id })
        let newData = getDataFromKeys(keys)
        UserDefaults.shared?.setValue(newData, forKey: UserDefaultsKey.apiKeys)
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
}
