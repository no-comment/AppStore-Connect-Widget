//
//  ACDataCache.swift
//  AC Widget by NO-COMMENT
//

import Foundation

class ACDataCache {
    private init() {}

    private struct CacheObjectCollection: Codable {
        let objects: [CacheObject]
    }

    private struct CacheObject: Codable {
        let apiKeyId: String
        let data: ACData
    }

    public static func getData(apiKey: APIKey) -> ACData? {
        guard let collection = getCollection() else { return nil }
        return collection.objects.first(where: { $0.apiKeyId == apiKey.id })?.data
    }

    public static func saveData(data: ACData, apiKey: APIKey) {
        var cacheObjects: [CacheObject] = getCollection()?.objects ?? []

        // find existing data for apiKey and remove matching data temporarily from array
        var oldData: ACData?
        cacheObjects.removeAll(where: {
            let matching = $0.apiKeyId == apiKey.id
            if matching { oldData = $0.data }
            return matching
        })

        // Convert currency from oldData to data.displayCurrency
        var oldEntries: [ACEntry] = []
        if let oldData = oldData {
            oldEntries = oldData.changeCurrency(to: data.displayCurrency).entries
        }

        // merge items
        let oldDataFiltered = oldEntries.filter { oldEntry in
            return !data.entries.contains(where: { $0.date == oldEntry.date })
        }

        var entries: [ACEntry] = data.entries + oldDataFiltered

        // delete entries from all object that are to old
        let latest: ACEntry? = entries.sorted { a, b in
            a.date.compare(b.date) == .orderedDescending
        }.first

        let latestDate = latest?.date ?? Date()
        let validDays = latestDate.getLastNDates(35).map({ $0.acApiFormat() })

        entries = entries.filter({ entry in
            validDays.contains(entry.date.acApiFormat())
        })

        if !entries.isEmpty {
            let newObj = CacheObject(apiKeyId: apiKey.id, data: ACData(entries: entries, currency: data.displayCurrency, apps: data.apps))
            cacheObjects.append(newObj)
        }

        let collection = CacheObjectCollection(objects: cacheObjects)
        saveCollection(collection)
    }

    private static func saveCollection(_ collection: CacheObjectCollection) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(collection) {
            UserDefaults.shared?.setValue(encoded, forKey: UserDefaultsKey.dataCache)
        }
    }

    private static func getCollection() -> CacheObjectCollection? {
        if let savedData: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.dataCache) {
            let decoder = JSONDecoder()
            let loadedData = try? decoder.decode(CacheObjectCollection.self, from: savedData)
            return loadedData
        }

        return nil
    }

    public static func numberOfEntriesCached(apiKey: APIKey? = nil) -> Int {
        let cacheObjects: [CacheObject] = getCollection()?.objects ?? []
        let data: [ACEntry] = cacheObjects.filter({
            guard let keyId = apiKey?.id else { return true }
            return $0.apiKeyId == keyId
        }).flatMap({ $0.data.entries })
        return data.count
    }

    public static func clearCache(apiKey: APIKey) {
        var cacheObjects: [CacheObject] = getCollection()?.objects ?? []
        cacheObjects.removeAll(where: { $0.apiKeyId == apiKey.id })
        let collection = CacheObjectCollection(objects: cacheObjects)
        saveCollection(collection)
    }

    public static func clearCache() {
        UserDefaults.shared?.removeObject(forKey: UserDefaultsKey.dataCache)
    }
}
