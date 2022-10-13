//
//  AppStoreConnectApi.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import AppStoreConnect_Swift_SDK
import Gzip
import SwiftCSV

@MainActor
class AppStoreConnectApi {
    private let privateKeyMinLength = 100

    private var apiKey: APIKey

    init(apiKey: APIKey) {
        self.apiKey = apiKey
    }

    private var issuerID: String { apiKey.issuerID }
    private var privateKeyID: String { apiKey.privateKeyID }
    private var privateKey: String { apiKey.privateKey }
    private var vendorNumber: String { apiKey.vendorNumber }

    static private var lastData: [APIKey: LoaderStatus] = [:]
    private enum LoaderStatus {
        case inProgress(Task<ACData, Error>)
        case loaded((data: ACData, date: Date))
    }

    static func clearMemoization() {
        lastData.removeAll()
    }

    public func getData(currency: CurrencyParam?, numOfDays: Int = 35, useCache: Bool = true) async throws -> ACData {
        if apiKey.name.caseInsensitiveCompare(APIKey.demoKeyName) == .orderedSame { return ACData.example }
        return try await getData(currency: currency?.toCurrency(), numOfDays: numOfDays, useCache: useCache)
    }

    public func getData(currency: Currency? = nil, numOfDays: Int = 35, useCache: Bool = true, useMemoization: Bool = true) async throws -> ACData {
        if apiKey.name.caseInsensitiveCompare(APIKey.demoKeyName) == .orderedSame { return ACData.example }

        if useMemoization {
            if let last = AppStoreConnectApi.lastData[apiKey] {
                switch last {
                case .loaded(let res):
                    if res.date.timeIntervalSinceNow > -60 * 5 {
                        return res.data.changeCurrency(to: currency ?? .USD)
                    } else {
                        AppStoreConnectApi.lastData.removeValue(forKey: apiKey)
                    }
                case .inProgress(let task):
                    return try await task.value.changeCurrency(to: currency ?? .USD)
                }
            }
        }

        let task: Task<ACData, Error> = Task {
            return try await getDataFromAPI(localCurrency: currency ?? .USD, numOfDays: numOfDays, useCache: useCache)
        }

        AppStoreConnectApi.lastData[apiKey] = .inProgress(task)

        let data = try await task.value

        AppStoreConnectApi.lastData[apiKey] = .loaded((data, .now))

        return data
    }

    private func getDataFromAPI(localCurrency: Currency, numOfDays: Int = 35, useCache: Bool = true) async throws -> ACData {
        if self.privateKey.count < privateKeyMinLength {
            throw APIError.invalidCredentials
        }

        let configuration = APIConfiguration(issuerID: self.issuerID, privateKeyID: self.privateKeyID, privateKey: self.privateKey)

        let provider: APIProvider = APIProvider(configuration: configuration)

        var entries: [ACEntry] = []

        await CurrencyConverter.shared.updateExchangeRates()

        let dates = Date.now.dayBefore.getLastNDates(numOfDays).map({ $0.acApiFormat() })

        if useCache {
            let cachedData = ACDataCache.getData(apiKey: self.apiKey)?.changeCurrency(to: localCurrency)
            let cachedEntries: [ACEntry] = cachedData?.entries ?? []

            entries.append(contentsOf: cachedEntries)
        }

        let entriesDates = entries.map({ $0.date.acApiFormat() })
        let missingDates = dates.filter({ !entriesDates.contains($0) })

        async let results: [Data] = withThrowingTaskGroup(of: Data?.self) { group in
            var data: [Data] = []

            for date in missingDates {
                group.addTask {
                    do {
                        return try await self.apiSalesAndTrendsWrapped(provider: provider, vendorNumber: self.vendorNumber, date: date)
                    } catch APIError.noDataAvailable {
                        return nil
                    }
                }
            }

            for try await d in group {
                if let d = d {
                    data.append(d)
                }
            }

            return data
        }

        for result in try await results {
            entries.append(contentsOf: parseApiResult(result, localCurrency: localCurrency))
        }

        let apps = try? await self.getApps(entries: entries)
        let acdata = ACData(entries: entries, currency: localCurrency, apps: apps ?? [])
        ACDataCache.saveData(data: acdata, apiKey: self.apiKey)

        return acdata
    }

    private func parseApiResult(_ result: Data, localCurrency: Currency) -> [ACEntry] {
        var entries: [ACEntry] = []

        guard let decompressedData = try? result.gunzipped() else {
            #if DEBUG
            fatalError()
            #else
            return []
            #endif
        }

        let str = String(decoding: decompressedData, as: UTF8.self)

        guard let tsv: CSV = try? CSV(string: str, delimiter: "\t") else {
            #if DEBUG
            fatalError()
            #else
            return []
            #endif
        }

        try? tsv.enumerateAsDict { dict in
            let parentId: String = dict["Parent Identifier"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let sku: String = dict["SKU"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            var proceeds = Double(dict["Developer Proceeds"] ?? "0.00") ?? 0
            if let cur: Currency = Currency(rawValue: dict["Currency of Proceeds"] ?? "") {
                proceeds = CurrencyConverter.shared.convert(proceeds, valueCurrency: cur, outputCurrency: localCurrency) ?? 0
            } else {
                proceeds = 0
            }

            let newEntry = ACEntry(appTitle: dict["Title"] ?? "UNKNOWN",
                                   appSKU: parentId.isEmpty ? sku : parentId,
                                   units: Int(dict["Units"] ?? "0") ?? 0,
                                   proceeds: Float(proceeds),
                                   date: Date.fromACFormat(dict["Begin Date"] ?? "") ?? Date.distantPast,
                                   countryCode: dict["Country Code"] ?? "UNKNOWN",
                                   device: dict["Device"] ?? "UNKNOWN",
                                   appIdentifier: dict["Apple Identifier"] ?? "",
                                   type: ACEntryType(dict["Product Type Identifier"]))
            entries.append(newEntry)
        }
        return entries
    }

    private func getApps(entries: [ACEntry]) async throws -> [ACApp] {
        let tupples: [ITunesLookupApp] = entries.map({ .init(appstoreId: $0.appIdentifier, name: $0.appTitle, sku: $0.appSKU) })
        var uniqueTupple: [ITunesLookupApp] = []
        for tupple in tupples {
            if !uniqueTupple.contains(where: { $0.appstoreId == tupple.appstoreId }) {
                uniqueTupple.append(tupple)
            }
        }

        return await withTaskGroup(of: ACApp?.self) { group in
            var lookUps: [ACApp] = []
            lookUps.reserveCapacity(uniqueTupple.count)

            for app in uniqueTupple {
                group.addTask {
                    return try? await self.iTunesLookup(app: app)
                }
            }

            for await app in group {
                if let app = app {
                    lookUps.append(app)
                }
            }

            return lookUps
        }
    }

    private func apiSalesAndTrendsWrapped(provider: APIProvider, vendorNumber: String, date: String) async throws -> Data {
        print("Loading data for: \(date)")
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(APIEndpoint.downloadSalesAndTrendsReports(filter: [
                .frequency([.DAILY]),
                .reportSubType([.SUMMARY]),
                .reportType([.SALES]),
                .vendorNumber([vendorNumber]),
                .reportDate([date]),
            ]), completion: { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    if let apiError = error as? AppStoreConnect_Swift_SDK.APIProvider.Error {
                        switch apiError {
                        case .requestFailure(let statusCode, let errData):
                            switch statusCode {
                            case 401:
                                continuation.resume(throwing: APIError.invalidCredentials)
                            case 429:
                                continuation.resume(throwing: APIError.exceededLimit)
                            case 403:
                                continuation.resume(throwing: APIError.wrongPermissions)
                            case 404:
                                guard let errData = errData else {
                                    continuation.resume(throwing: APIError.unknown)
                                    break
                                }

                                let resp = String(decoding: errData, as: UTF8.self)
                                if resp.contains("The request expected results but none were found") {
                                    continuation.resume(throwing: APIError.noDataAvailable)
                                } else {
                                    continuation.resume(throwing: APIError.unknown)
                                }
                            default:
                                print(statusCode)
                                continuation.resume(throwing: APIError.unknown)
                            }
                        case .requestGeneration:
                            continuation.resume(throwing: APIError.invalidCredentials)
                        default:
                            continuation.resume(throwing: APIError.unknown)
                        }
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            })
        }
    }

    private struct ITunesResponse: Codable {
        let resultCount: Int
        let results: [ITunesAppData]
    }

    private struct ITunesAppData: Codable {
        let artworkUrl60: String
        let artworkUrl100: String
        let currentVersionReleaseDate: String
        let version: String
    }

    private struct ITunesLookupApp {
        let appstoreId: String
        let name: String
        let sku: String
    }

    private func iTunesLookup(app: ITunesLookupApp) async throws -> ACApp {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=" + app.appstoreId) else {
            throw APIError.unknown
        }

        if let data = try? await URLSession.shared.data(from: url).0 {
            let decoder = JSONDecoder()
            let result = try? decoder.decode(ITunesResponse.self, from: data)
            guard let appData = result?.results.first else {
                throw APIError.unknown
            }

            var imageData: Data?
            if let imgUrl = URL(string: appData.artworkUrl60) {
                imageData = try? await URLSession.shared.data(from: imgUrl).0
            }

            return ACApp(appstoreId: app.appstoreId,
                         name: app.name,
                         sku: app.sku,
                         version: appData.version,
                         currentVersionReleaseDate: appData.currentVersionReleaseDate,
                         artworkUrl60: appData.artworkUrl60,
                         artworkUrl100: appData.artworkUrl100,
                         artwork60ImgData: imageData)
        } else {
            throw APIError.unknown
        }
    }

    private func apiAppsWrapped(provider: APIProvider) async throws -> AppsResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(APIEndpoint.apps(select: [.apps([.name, .sku])]), completion: { result in
                continuation.resume(with: result)
            })
        }
    }
}

extension Date {
    func acApiFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    static func fromACFormat(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: dateString)
    }

    func getLastNDates(_ n: Int) -> [Date] {
        if n == 0 { return [] }
        let cal = NSCalendar.current
        // start with today
        var date = cal.startOfDay(for: self)

        var res: [Date] = []

        for _ in 1 ... max(1, n) {
            res.append(date)
            if let nextDate = cal.date(byAdding: Calendar.Component.day, value: -1, to: date) {
                date = nextDate
            }
        }
        return res
    }
}
