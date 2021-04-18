//
//  AppStoreConnectApi.swift
//  AC Widget
//
//  Created by Miká Kruschel on 01.04.21.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Gzip
import SwiftCSV
import Promises

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

    // swiftlint:disable:next large_tuple
    static private var lastData: [(key: APIKey, date: Date, result: Promise<ACData>)] = []

    // swiftlint:disable:next function_body_length
    public func getData(currency: CurrencyParam? = nil, numOfDays: Int = 35, useCache: Bool = true) -> Promise<ACData> {
        if useCache {
            if let last = AppStoreConnectApi.lastData.first(where: { $0.key.id == self.apiKey.id }) {
                if last.date.timeIntervalSinceNow > -60 * 5 {
                    return last.result
                } else {
                    AppStoreConnectApi.lastData.removeAll(where: { $0.key.id == self.apiKey.id })
                }
            }
        }

        let promise = Promise<ACData>.pending()

        if self.privateKey.count < privateKeyMinLength {
            promise.reject(APIError.invalidCredentials)
            return promise
        }
        let configuration = APIConfiguration(issuerID: self.issuerID, privateKeyID: self.privateKeyID, privateKey: self.privateKey)

        let provider: APIProvider = APIProvider(configuration: configuration)

        var entries: [ACEntry] = []

        let localCurrency: Currency = currency?.toCurrency() ?? .USD

        let converter = CurrencyConverter.shared

        converter.updateExchangeRates()
            .then({ _ ->  Promise<[Maybe<Data>]> in
                let dates = Date().dayBefore.getLastNDates(numOfDays-1).map({ $0.acApiFormat() })

                if useCache {
                    let cachedData = ACDataCache.getData(apiKey: self.apiKey)?.changeCurrency(to: localCurrency)
                    let cachedEntries: [ACEntry] = cachedData?.entries ?? []

                    entries.append(contentsOf: cachedEntries)
                }
                let entriesDates = entries.map({ $0.date.acApiFormat() })
                let missingDates = dates.filter({ !entriesDates.contains($0) })

                return any(missingDates.map({ self.apiSalesAndTrendsWrapped(provider: provider, vendorNumber: self.vendorNumber, date: $0) }))
            })
            .then { results in
                for result in results {
                    guard let resultValue = result.value else {
                        print("ERROR: \(result.error?.localizedDescription ?? "")")
                        continue
                    }
                    guard let decompressedData = try? resultValue.gunzipped() else {
                        #if DEBUG
                        fatalError()
                        #endif
                        continue
                    }

                    let str = String(decoding: decompressedData, as: UTF8.self)

                    guard let tsv: CSV = try? CSV(string: str, delimiter: "\t") else {
                        #if DEBUG
                        fatalError()
                        #endif
                        continue
                    }

                    try? tsv.enumerateAsDict { dict in
                        let parentId: String = dict["Parent Identifier"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let sku: String = dict["SKU"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                        var proceeds = Double(dict["Developer Proceeds"] ?? "0.00") ?? 0
                        if let cur: Currency = Currency(rawValue: dict["Currency of Proceeds"] ?? "") {
                            proceeds = converter.convert(proceeds, valueCurrency: cur, outputCurrency: localCurrency) ?? 0
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
                                               type: ACEntryType(dict["Product Type Identifier"]))
                        entries.append(newEntry)
                    }
                }

                self.getApps()
                    .then { apps in
                        let newData = ACData(entries: entries, currency: localCurrency, apps: apps)
                        ACDataCache.saveData(data: newData, apiKey: self.apiKey)
                        promise.fulfill(newData)
                    }
                    .catch { _ in
                        let newData = ACData(entries: entries, currency: localCurrency, apps: [])
                        ACDataCache.saveData(data: newData, apiKey: self.apiKey)
                        promise.fulfill(newData)
                    }
            }
            .catch { err in
                if let apiError = err as? AppStoreConnect_Swift_SDK.APIProvider.Error {
                    switch apiError {
                    case .requestFailure(let statusCode, let errData):
                        switch statusCode {
                        case 401:
                            promise.reject(APIError.invalidCredentials)
                        case 429:
                            promise.reject(APIError.exceededLimit)
                        case 403:
                            promise.reject(APIError.wrongPermissions)
                        case 404:
                            guard let errData = errData else {                            promise.reject(APIError.unknown)
                                break
                            }

                            let resp = String(decoding: errData, as: UTF8.self)
                            if resp.contains("The request expected results but none were found") {
                                if entries.isEmpty {
                                    promise.reject(APIError.noDataAvailable)
                                } else {
                                    promise.fulfill(ACData(entries: entries, currency: localCurrency, apps: []))
                                }
                            } else {
                                promise.reject(APIError.unknown)
                            }
                        default:
                            print(statusCode)
                            promise.reject(APIError.unknown)
                        }
                    case .requestGeneration:
                        promise.reject(APIError.invalidCredentials)
                    default:
                        promise.reject(APIError.unknown)
                    }
                } else {
                    promise.reject(APIError.unknown)
                }
            }

        if useCache {
            AppStoreConnectApi.lastData.append((key: self.apiKey, date: Date(), result: promise))
        }

        return promise
    }

    private func getApps() -> Promise<[ACApp]> {
        let promise = Promise<[ACApp]>.pending()
        let configuration = APIConfiguration(issuerID: self.issuerID, privateKeyID: self.privateKeyID, privateKey: self.privateKey)

        let provider: APIProvider = APIProvider(configuration: configuration)

        apiAppsWrapped(provider: provider)
            .then { resp in
                any(resp.data.map({ self.iTunesLookup(app: $0) }))
                    .then { data in
                        promise.fulfill(data.compactMap({ $0.value }))
                    }
            }.catch { err in
                promise.reject(err)
            }
        return promise
    }

    private func apiSalesAndTrendsWrapped(provider: APIProvider, vendorNumber: String, date: String) -> Promise<Data> {
        print("Call api for \(date)")
        return Promise<Data> { fulfill, reject in
            provider.request(APIEndpoint.downloadSalesAndTrendsReports(filter: [
                .frequency([.DAILY]),
                .reportSubType([.SUMMARY]),
                .reportType([.SALES]),
                .vendorNumber([vendorNumber]),
                .reportDate([date]),
            ]), completion: { result in
                switch result {
                case .success(let data):
                    fulfill(data)
                case .failure(let reason):
                    reject(reason)
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

    private func iTunesLookup(app: App) -> Promise<ACApp> {
        let appId: String = app.id
        let promise = Promise<ACApp>.pending()
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=" + appId) else {
            promise.reject(APIError.unknown)
            return promise
        }

        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            let result = try? decoder.decode(ITunesResponse.self, from: data)
            guard let appData = result?.results.first else {
                promise.reject(APIError.notPublic)
                return promise
            }
            promise.fulfill(
                ACApp(id: app.id,
                      name: app.attributes?.name ?? "",
                      sku: app.attributes?.sku ?? "",
                      version: appData.version,
                      currentVersionReleaseDate: appData.currentVersionReleaseDate,
                      artworkUrl60: appData.artworkUrl60,
                      artworkUrl100: appData.artworkUrl100)
            )
        } else {
            promise.reject(APIError.unknown)
        }

        return promise
    }

    private func apiAppsWrapped(provider: APIProvider) -> Promise<AppsResponse> {
        return Promise<AppsResponse> { fulfill, reject in
            provider.request(APIEndpoint.apps(select: [.apps([.name, .sku])]),
                             completion: { result in
                                switch result {
                                case .success(let data):
                                    fulfill(data)
                                case .failure(let reason):
                                    print("Something went wrong fetching the apps: \(reason)")
                                    reject(reason)
                                }
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
