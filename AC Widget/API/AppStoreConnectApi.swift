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

    private var issuerID: String
    private var privateKeyID: String
    private var privateKey: String
    private var vendorNumber: String

    init(issuerID: String, privateKeyID: String, privateKey: String, vendorNumber: String) {
        self.issuerID = issuerID
        self.privateKeyID = privateKeyID
        self.vendorNumber = vendorNumber

        self.privateKey = privateKey
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .removeCharacters(from: .whitespacesAndNewlines)
    }

    convenience init(apiKey: APIKey) {
        self.init(issuerID: apiKey.issuerID, privateKeyID: apiKey.privateKeyID, privateKey: apiKey.privateKey, vendorNumber: apiKey.vendorNumber)
    }

    // swiftlint:disable:next function_body_length
    public func testApiKeys() -> Promise<Bool> {
        let promise = Promise<Bool>.pending()

        if self.privateKey.count < privateKeyMinLength {
            promise.reject(APIError.invalidCredentials)
            return promise
        }
        let configuration = APIConfiguration(issuerID: self.issuerID, privateKeyID: self.privateKeyID, privateKey: self.privateKey)

        let provider: APIProvider = APIProvider(configuration: configuration)

        any(Date().getLastNDates(10)
                .map({ $0.acApiFormat() })
                .map({ self.apiWrapped(provider: provider, vendorNumber: self.vendorNumber, date: $0) }))
            .then { results in
                var success = false
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

                    guard let _: CSV = try? CSV(string: str, delimiter: "\t") else {
                        #if DEBUG
                        fatalError()
                        #endif
                        continue
                    }

                    success = true
                    break
                }

                promise.fulfill(success)
            }
            .catch { err in
                if let apiError = err as? AppStoreConnect_Swift_SDK.APIProvider.Error {
                    switch apiError {
                    case .requestFailure(let statusCode, _):
                        print(statusCode)
                        switch statusCode {
                        case 401:
                            promise.reject(APIError.invalidCredentials)
                        case 429:
                            promise.reject(APIError.exceededLimit)
                        case 403:
                            promise.reject(APIError.wrongPermissions)
                        default:
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

        return promise
    }

    // swiftlint:disable:next function_body_length
    public func getData(currency: CurrencyParam? = nil) -> Promise<ACData> {
        let promise = Promise<ACData>.pending()

        if self.privateKey.count < privateKeyMinLength {
            promise.reject(APIError.invalidCredentials)
            return promise
        }
        let configuration = APIConfiguration(issuerID: self.issuerID, privateKeyID: self.privateKeyID, privateKey: self.privateKey)

        let provider: APIProvider = APIProvider(configuration: configuration)

        var downloads: [(Int, Date)] = []
        var proceeds: [(Float, Date)] = []

        let localCurrency: Currency = currency?.toCurrency() ?? .USD

        let converter = CurrencyConverter.shared
        converter.updateExchangeRates()
            .then { _ in
                any(Date().getLastNDates(35)
                        .map({ $0.acApiFormat() })
                        .map({ self.apiWrapped(provider: provider, vendorNumber: self.vendorNumber, date: $0) }))
            }
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

                    var procForDay: Double = 0
                    var downloadsForDay: Int = 0
                    try? tsv.enumerateAsDict { dict in
                        let type = dict["Product Type Identifier"] ?? ""
                        if type.contains("7") || type.contains("3") { return } // skip redownloads, updates and restoring of iap
                        if let units = Int(dict["Units"] ?? "0"), let pro: Double = Double(dict["Developer Proceeds"] ?? "0.00") {
                            if pro > 0 {
                                if let cur: Currency = Currency(rawValue: dict["Currency of Proceeds"] ?? "") {
                                    procForDay += converter.convert(Double(units) * pro, valueCurrency: cur, outputCurrency: localCurrency) ?? 0
                                }
                            } else {
                                downloadsForDay += units
                            }
                        }
                    }

                    if let beginDate = tsv.namedRows.first?["Begin Date"], let entryDate = Date.fromACFormat(beginDate) {
                        proceeds.append((Float(procForDay), entryDate))
                        downloads.append((downloadsForDay, entryDate))
                    }
                }

                let firstDate: Date = proceeds.count > 0 ? proceeds.map({ $0.1 }).reduce(Date.distantFuture, { $0 < $1 ? $0 : $1 }) : Date()
                let lastDate: Date = proceeds.count > 0 ? proceeds.map({ $0.1 }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 }) : Date()
                var curDate = firstDate
                while curDate < lastDate {
                    if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: curDate) {
                        curDate = newDate
                    }
                    if !proceeds.contains(where: { $0.1 == curDate }) {
                        proceeds.append((0, curDate))
                    }
                    if !downloads.contains(where: { $0.1 == curDate }) {
                        downloads.append((0, curDate))
                    }
                }

                proceeds.sort(by: { $0.1.compare($1.1) == .orderedDescending })
                downloads.sort(by: { $0.1.compare($1.1) == .orderedDescending })

                promise.fulfill(ACData(downloads: downloads, proceeds: proceeds, currency: localCurrency.symbol))
            }
            .catch { err in
                if let apiError = err as? AppStoreConnect_Swift_SDK.APIProvider.Error {
                    switch apiError {
                    case .requestFailure(let statusCode, _):
                        print(statusCode)
                        switch statusCode {
                        case 401:
                            promise.reject(APIError.invalidCredentials)
                        case 429:
                            promise.reject(APIError.exceededLimit)
                        case 403:
                            promise.reject(APIError.wrongPermissions)
                        default:
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

        return promise
    }

    private func apiWrapped(provider: APIProvider, vendorNumber: String, date: String) -> Promise<Data> {
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

        for _ in 1 ... n {
            res.append(date)
            if let nextDate = cal.date(byAdding: Calendar.Component.day, value: -1, to: date) {
                date = nextDate
            }
        }
        return res
    }
}
