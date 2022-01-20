//
//  ACData.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import SwiftUI
import BetterToStrings

struct ACData: Codable {
    let apps: [ACApp]
    let entries: [ACEntry]
    let displayCurrency: Currency

    init(entries: [ACEntry], currency: Currency, apps: [ACApp]) {
        self.entries = entries
        self.displayCurrency = currency
        self.apps = apps.sorted { entries.filterApps([$0]).count > entries.filterApps([$1]).count }
    }
}

extension ACData {
    func changeCurrency(to outputCurrency: Currency) -> ACData {
        let newEntries: [ACEntry] = self.entries.map({ entry -> ACEntry in
            let proceeds = CurrencyConverter.shared.convert(Double(entry.proceeds),
                                                            valueCurrency: self.displayCurrency,
                                                            outputCurrency: outputCurrency) ?? 0
            return ACEntry(appTitle: entry.appTitle,
                           appSKU: entry.appSKU,
                           units: entry.units,
                           proceeds: Float(proceeds),
                           date: entry.date,
                           countryCode: entry.countryCode,
                           device: entry.device,
                           appIdentifier: entry.appIdentifier,
                           type: entry.type)
        })

        return ACData(entries: newEntries, currency: outputCurrency, apps: self.apps)
    }
}

extension ACData {
    // MARK: Get Raw Data
    func getEntries(for type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> [ACEntry] {
        var entries = entries.getLastDays(lastNDays).filterApps(filteredApps)

        switch type {
        case .proceeds:
            entries = entries.filter({ $0.proceeds > 0 })
        case .downloads:
            if UserDefaults.shared?.bool(forKey: UserDefaultsKey.includeRedownloads) ?? false {
                entries = entries.filter({ $0.type == .download || $0.type == .redownload })
            } else {
                entries = entries.filter({ $0.type == .download })
            }
        case .updates:
            entries = entries.filter({ $0.type == .update })
        case .iap:
            entries = entries.filter({ $0.type == .iap })
        }

        return entries
    }

    func getRawData(for type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        let dict = Dictionary(grouping: getEntries(for: type, lastNDays: lastNDays, filteredApps: filteredApps), by: { $0.date })
        var result: [(Float, Date)]

        switch type {
        case .proceeds:
            result = dict.map { (key: Date, value: [ACEntry]) -> (Float, Date) in
                return (value.reduce(0, { $0 + $1.proceeds * Float($1.units) }), key)
            }
        default:
            result = dict.map { (key: Date, value: [ACEntry]) -> (Float, Date) in
                return (Float(value.reduce(0, { $0 + $1.units })), key)
            }
        }

        return result.fillZeroLastDays(lastNDays, latestDate: self.latestReportingDate())
    }

    // MARK: Get CountryCode
    func getCountries(_ type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        let dict = Dictionary(grouping: getEntries(for: type, lastNDays: lastNDays, filteredApps: filteredApps), by: { $0.countryCode })
        var result: [(String, Float)]

        switch type {
        case .proceeds:
            result = dict.map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, value.reduce(0, { $0 + $1.proceeds * Float($1.units) }))
            }
        default:
            result = dict.map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
        }

        return result
    }

    // MARK: Get Device
    func getDevices(_ type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        let dict = Dictionary(grouping: getEntries(for: type, lastNDays: lastNDays, filteredApps: filteredApps), by: { $0.device })
        var result: [(String, Float)]

        switch type {
        case .proceeds:
            result = dict.map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, value.reduce(0, { $0 + $1.proceeds * Float($1.units) }))
            }
        default:
            result = dict.map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
        }

        return result
    }

    // MARK: Get Change
    func getChange(_ type: InfoType) -> String {
        let latestInterval = getRawData(for: type, lastNDays: 15).map({ $0.0 }).reduce(0, +)
        let previousInterval = getRawData(for: type, lastNDays: 30).map({ $0.0 }).reduce(0, +) - latestInterval
        let change = NSNumber(value: ((latestInterval/previousInterval) - 1) * 100)
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 1
        return nf.string(from: change) ?? "-"
    }

    // MARK: Getting Dates
    func latestReportingDate() -> Date {
        return entries.map({ $0.date }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 })
    }

    func latestReportingDate() -> String {
        return latestReportingDate().toString(format: "dd. MMM.", smartConversion: true)
    }
}

// MARK: Mock Data
extension ACData {
    static let example = createMockData(31)
    static let exampleLargeSums = createMockData(31, largeValues: true)

    private static func createMockData(_ days: Int, largeValues: Bool = false) -> ACData {
        var entries: [ACEntry] = []
        let countries = ["US", "DE", "ES", "UK", "IN", "CA", "SE", "NZ"]
        let devices = ["Desktop", "iPhone", "iPad"]

        Date(timeIntervalSinceNow: -86400).getLastNDates(days).forEach { day in
            for _ in 0...(Int.random(in: 10...30) * (largeValues ? 5 : 1)) {
                entries.append(ACEntry(appTitle: "TestApp",
                                       appSKU: "TestApp",
                                       units: Int.random(in: 1...10),
                                       proceeds: Float.random(in: 0...5),
                                       date: day, countryCode: countries.randomElement() ?? "US",
                                       device: devices.randomElement() ?? "iPhone",
                                       appIdentifier: "",
                                       type: ACEntryType.allCases.randomElement() ?? .download))
            }
        }
        return ACData(entries: entries, currency: .USD, apps: [ACApp.mockApp])
    }
}

extension Array where Element == (Float, Date) {
    enum NumberLength { case standard, compact }
    func toString(size: NumberLength = .standard) -> String {
        self.map({ $0.0 })
            .reduce(0, +)
            .toString(abbreviation: .intelligent, maxSize: size == .compact ? 4 : nil, maxFractionDigits: 2)
    }
}

enum InfoType {
    case proceeds, downloads, updates, iap

    var systemImage: String {
        switch self {
        case .proceeds:
            return "dollarsign.circle"
        case .downloads:
            return "square.and.arrow.down"
        case .updates:
            return "arrow.triangle.2.circlepath"
        case .iap:
            return "cart"
        }
    }
}
