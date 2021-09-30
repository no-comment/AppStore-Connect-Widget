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
    // MARK: Get String
    func getAsString(_ type: InfoType, lastNDays: Int, size: NumberLength = .standard, filteredApps: [ACApp] = []) -> String {
        switch type {
        case .downloads:
            return getDownloadsString(lastNDays, size: size, filteredApps: filteredApps)
        case .proceeds:
            return getProceedsString(lastNDays, size: size, filteredApps: filteredApps)
        case .updates:
            return getUpdatesString(lastNDays, size: size, filteredApps: filteredApps)
        case .iap:
            return getIapString(lastNDays, size: size, filteredApps: filteredApps)
        }
    }

    private func getDownloadsString(_ lastNDays: Int, size: NumberLength, filteredApps: [ACApp] = []) -> String {
        let num: Float = getDownloadsSum(lastNDays, filteredApps: filteredApps)
        return num.toString(abbreviation: .intelligent, maxSize: size == .compact ? 4 : nil, maxFractionDigits: 2)
    }

    private func getProceedsString(_ lastNDays: Int, size: NumberLength, filteredApps: [ACApp] = []) -> String {
        let num: Float = getProceedsSum(lastNDays, filteredApps: filteredApps)
        return num.toString(abbreviation: .intelligent, maxSize: size == .compact ? 3 : nil, maxFractionDigits: 2)
    }

    private func getUpdatesString(_ lastNDays: Int, size: NumberLength, filteredApps: [ACApp] = []) -> String {
        let num: Float = getUpdatesSum(lastNDays, filteredApps: filteredApps)
        return num.toString(abbreviation: .intelligent, maxSize: size == .compact ? 4 : nil, maxFractionDigits: 2)
    }

    private func getIapString(_ lastNDays: Int, size: NumberLength, filteredApps: [ACApp] = []) -> String {
        let num: Float = getIapSum(lastNDays, filteredApps: filteredApps)
        return num.toString(abbreviation: .intelligent, maxSize: size == .compact ? 4 : nil, maxFractionDigits: 2)
    }

    enum NumberLength { case compact, standard }

    // MARK: Get Raw Data
    func getRawData(_ type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        switch type {
        case .downloads:
            return getRawDownloads(lastNDays, filteredApps: filteredApps)
        case .proceeds:
            return getRawProceeds(lastNDays, filteredApps: filteredApps)
        case .updates:
            return getRawUpdates(lastNDays, filteredApps: filteredApps)
        case .iap:
            return getRawIap(lastNDays, filteredApps: filteredApps)
        }
    }

    private func getRawDownloads(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        var downloadEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)

        // Checking if Re-Dowloads are to be included
        if UserDefaults.shared?.bool(forKey: UserDefaultsKey.includeRedownloads) ?? false {
            downloadEntries = downloadEntries.filter({ $0.type == .download || $0.type == .redownload })
        } else {
            downloadEntries = downloadEntries.filter({ $0.type == .download })
        }

        return Dictionary(grouping: downloadEntries, by: { $0.date })
            .map { (key: Date, value: [ACEntry]) -> (Float, Date) in
                return (Float(value.reduce(0, { $0 + $1.units })), key)
            }.fillZeroLastDays(lastNDays, latestDate: self.latestReportingDate())
    }

    private func getRawProceeds(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.proceeds > 0 })

        return Dictionary(grouping: proceedEntries, by: { $0.date })
            .map { (key: Date, value: [ACEntry]) -> (Float, Date) in
                return (value.reduce(0, { $0 + $1.proceeds * Float($1.units) }), key)
            }.fillZeroLastDays(lastNDays, latestDate: self.latestReportingDate())
    }

    private func getRawUpdates(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.type == .update })

        return Dictionary(grouping: proceedEntries, by: { $0.date })
            .map { (key: Date, value: [ACEntry]) -> (Float, Date) in
                return (Float(value.reduce(0, { $0 + $1.units })), key)
            }.fillZeroLastDays(lastNDays, latestDate: self.latestReportingDate())
    }

    private func getRawIap(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.type == .iap })

        return Dictionary(grouping: proceedEntries, by: { $0.date })
            .map { (key: Date, value: [ACEntry]) -> (Float, Date) in
                return (Float(value.reduce(0, { $0 + $1.units })), key)
            }.fillZeroLastDays(lastNDays, latestDate: self.latestReportingDate())
    }

    // MARK: Get Sum
    func getSum(_ type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        switch type {
        case .downloads:
            return getDownloadsSum(lastNDays, filteredApps: filteredApps)
        case .proceeds:
            return getProceedsSum(lastNDays, filteredApps: filteredApps)
        case .updates:
            return getUpdatesSum(lastNDays, filteredApps: filteredApps)
        case .iap:
            return getIapSum(lastNDays, filteredApps: filteredApps)
        }
    }

    private func getDownloadsSum(_ lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        return getRawDownloads(lastNDays, filteredApps: filteredApps).map({ $0.0 }).reduce(0, +)
    }

    private func getProceedsSum(_ lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        return getRawProceeds(lastNDays, filteredApps: filteredApps).map({ $0.0 }).reduce(0, +)
    }

    private func getUpdatesSum(_ lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        return getRawUpdates(lastNDays, filteredApps: filteredApps).map({ $0.0 }).reduce(0, +)
    }

    private func getIapSum(_ lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        return getRawIap(lastNDays, filteredApps: filteredApps).map({ $0.0 }).reduce(0, +)
    }

    // MARK: Get CountryCode
    func getCountries(_ type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        switch type {
        case .downloads:
            return getDownloadsCountries(lastNDays, filteredApps: filteredApps)
        case .proceeds:
            return getProceedsCountries(lastNDays, filteredApps: filteredApps)
        case .updates:
            return getUpdatesCountries(lastNDays, filteredApps: filteredApps)
        case .iap:
            return getIapCountries(lastNDays, filteredApps: filteredApps)
        }
    }

    private func getDownloadsCountries(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var downloadEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)

        // Checking if Re-Dowloads are to be included
        if UserDefaults.shared?.bool(forKey: UserDefaultsKey.includeRedownloads) ?? false {
            downloadEntries = downloadEntries.filter({ $0.type == .download || $0.type == .redownload })
        } else {
            downloadEntries = downloadEntries.filter({ $0.type == .download })
        }

        return Dictionary(grouping: downloadEntries, by: { $0.countryCode })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
    }

    private func getProceedsCountries(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.proceeds > 0 })

        return Dictionary(grouping: proceedEntries, by: { $0.countryCode })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, value.reduce(0, { $0 + $1.proceeds * Float($1.units) }))
            }
    }

    private func getUpdatesCountries(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.type == .update })

        return Dictionary(grouping: proceedEntries, by: { $0.countryCode })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
    }

    private func getIapCountries(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.type == .iap })

        return Dictionary(grouping: proceedEntries, by: { $0.countryCode })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
    }

    // MARK: Get Device
    func getDevices(_ type: InfoType, lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        switch type {
        case .downloads:
            return getDownloadsDevices(lastNDays, filteredApps: filteredApps)
        case .proceeds:
            return getProceedsDevices(lastNDays, filteredApps: filteredApps)
        case .updates:
            return getUpdatesDevices(lastNDays, filteredApps: filteredApps)
        case .iap:
            return getIapDevices(lastNDays, filteredApps: filteredApps)
        }
    }

    private func getDownloadsDevices(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var downloadEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)

        // Checking if Re-Dowloads are to be included
        if UserDefaults.shared?.bool(forKey: UserDefaultsKey.includeRedownloads) ?? false {
            downloadEntries = downloadEntries.filter({ $0.type == .download || $0.type == .redownload })
        } else {
            downloadEntries = downloadEntries.filter({ $0.type == .download })
        }

        return Dictionary(grouping: downloadEntries, by: { $0.device })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
    }

    private func getProceedsDevices(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.proceeds > 0 })

        return Dictionary(grouping: proceedEntries, by: { $0.device })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, value.reduce(0, { $0 + $1.proceeds * Float($1.units) }))
            }
    }

    private func getUpdatesDevices(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.type == .update })

        return Dictionary(grouping: proceedEntries, by: { $0.device })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
    }

    private func getIapDevices(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(String, Float)] {
        var proceedEntries = entries.getLastDays(lastNDays).filterApps(filteredApps)
        proceedEntries = proceedEntries.filter({ $0.type == .iap })

        return Dictionary(grouping: proceedEntries, by: { $0.device })
            .map { (key: String, value: [ACEntry]) -> (String, Float) in
                return (key, Float(value.reduce(0, { $0 + $1.units })))
            }
    }

    // MARK: Get Change
    func getChange(_ type: InfoType) -> String {
        let latestInterval = getSum(type, lastNDays: 15)
        let previousInterval = getSum(type, lastNDays: 30) - latestInterval
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
        let latestDate: Date? = entries.map({ $0.date }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 })

        guard let date = latestDate else {
            return NSLocalizedString("NO_DATA", comment: "")
        }
        return date.toString(format: "dd. MMM.", smartConversion: true)
    }

    // MARK: Mock Data
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
