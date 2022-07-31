//
//  ACDataCache.swift
//  AC Widget by NO-COMMENT
//

import Foundation

class ACDataCache {
    private init() {}

    private static var storageUrl: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.kruschel.ACWidget")
    }

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
        DispatchQueue.global(qos: .background).async {
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
                oldEntries = oldData.changeCurrency(to: data.displayCurrency).entries.elements
            }

            // merge items
            let oldDataFiltered = oldEntries.filter { oldEntry in
                !data.entries.contains(where: { $0.date == oldEntry.date })
            }

            var entries: SortedArray<ACEntry> = .init(data.entries.elements + oldDataFiltered)

            // delete entries from all object that are to old
            let latest: ACEntry? = entries.last

            let latestDate = latest?.date ?? Date()
            let validDays = latestDate.getLastNDates(370).map({ $0.acApiFormat() })

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
    }

    private static func saveCollection(_ collection: CacheObjectCollection) {
        guard let storageUrl = storageUrl?.appendingPathComponent("cache.json") else { return }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(collection) {
            do {
                try encoded.write(to: storageUrl)
            } catch {
                print("Caching failed", error)
            }
        }
    }

    private static func getCollection() -> CacheObjectCollection? {
        guard let storageUrl = storageUrl?.appendingPathComponent("cache.json") else { return nil }
        if let savedData: Data = try? Data(contentsOf: storageUrl) {
            let decoder = JSONDecoder()
            let loadedData = try? decoder.decode(CacheObjectCollection.self, from: savedData)
            return loadedData
        }

        return nil
    }

    public static func numberOfEntriesCached(apiKey: APIKey? = nil) -> Int {
        let cacheObjects: [CacheObject] = getCollection()?.objects ?? []
        let count = cacheObjects.filter({
            guard let keyId = apiKey?.id else { return true }
            return $0.apiKeyId == keyId
        }).reduce(0) { partialResult, obj in
            partialResult + obj.data.entries.count
        }
        return count
    }

    public static func clearCache(apiKey: APIKey) {
        var cacheObjects: [CacheObject] = getCollection()?.objects ?? []
        cacheObjects.removeAll(where: { $0.apiKeyId == apiKey.id })
        let collection = CacheObjectCollection(objects: cacheObjects)
        saveCollection(collection)
    }

    public static func clearCache() {
        guard let storageUrl = storageUrl?.appendingPathComponent("cache.json") else { return }
        try? FileManager.default.removeItem(at: storageUrl)
    }
}
