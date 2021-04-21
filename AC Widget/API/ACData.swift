//
//  ACData.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import SwiftUI

struct ACData: Codable {
    let apps: [ACApp]
    let entries: [ACEntry]
    let displayCurrency: Currency

    init(entries: [ACEntry], currency: Currency, apps: [ACApp]) {
        self.entries = entries
        self.displayCurrency = currency
        self.apps = apps
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
        }
    }

    private func getDownloadsString(_ lastNDays: Int, size: NumberLength, filteredApps: [ACApp] = []) -> String {
        let num: Float = getDownloadsSum(lastNDays, filteredApps: filteredApps)
        return ACData.formatNumberLength(num: num, size: size, type: .downloads)
    }

    private func getProceedsString(_ lastNDays: Int, size: NumberLength, filteredApps: [ACApp] = []) -> String {
        let num: Float = getProceedsSum(lastNDays, filteredApps: filteredApps)
        return ACData.formatNumberLength(num: num, size: size, type: .proceeds)
    }

    private func getUpdatesString(_ lastNDays: Int, size: NumberLength, filteredApps: [ACApp] = []) -> String {
        let num: Float = getUpdatesSum(lastNDays, filteredApps: filteredApps)
        return ACData.formatNumberLength(num: num, size: size, type: .updates)
    }

    // swiftlint:disable:next function_body_length
    public static func formatNumberLength(num: Float, size: NumberLength = .standard, type: InfoType) -> String {
        switch type {
        case .downloads, .updates:
            if num < 1000 { return "\(Int(num))" }

            let fNum: NSNumber = NSNumber(value: num/1000)
            let nf = NumberFormatter()

            switch size {
            case .compact:
                if num <  10000 {
                    nf.numberStyle = .decimal
                    nf.maximumFractionDigits = 1
                }
            case .standard:
                nf.numberStyle = .decimal
                nf.maximumFractionDigits = 2
            }

            return (nf.string(from: fNum) ?? "0").appending("K")
        case .proceeds:
            var fNum: NSNumber = NSNumber(value: num)
            let nf = NumberFormatter()
            var addK = false

            switch size {
            case .compact:
                if num <  10 {
                    nf.numberStyle = .decimal
                    nf.maximumFractionDigits = 2
                } else if num < 100 {
                    nf.numberStyle = .decimal
                    nf.maximumFractionDigits = 1
                } else if num < 1000 {
                } else if num < 10000 {
                    fNum = NSNumber(value: num/1000)
                    nf.numberStyle = .decimal
                    nf.maximumFractionDigits = 1
                    addK = true
                } else if num < 100000 {
                    fNum = NSNumber(value: num/1000)
                    addK = true
                }
            case .standard:
                if num >= 1000 {
                    fNum = NSNumber(value: num/1000)
                    addK = true
                }
                nf.numberStyle = .decimal
                nf.maximumFractionDigits = (num >= 1000 && num/1000 < 10) || num < 10 ? 2 : 1
            }

            return (nf.string(from: fNum) ?? "0").appending(addK ? "K" : "")
        }
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
        }
    }

    private func getRawDownloads(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        let downloadEntries = entries.filter({ $0.type == .download && $0.belongsToApp(apps: filteredApps) })
        let latestDate: Date = downloadEntries.count > 0 ? downloadEntries.map({ $0.date }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 }) : Date()

        return latestDate.getLastNDates(lastNDays)
            .map { day -> (Float, Date) in
                let count = downloadEntries.filter({ $0.date == day }).reduce(0, { $0 + $1.units })
                return (Float(count), day)
            }
    }

    private func getRawProceeds(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        let downloadEntries = entries.filter({ $0.proceeds > 0 && $0.belongsToApp(apps: filteredApps) })
        let latestDate: Date? = entries.reduce(Date.distantPast, { $0 > $1.date ? $0 : $1.date })

        return (latestDate ?? Date()).getLastNDates(lastNDays)
            .map { day -> (Float, Date) in
                let sum = downloadEntries.filter({ $0.date == day }).reduce(Float.zero, { $0 + $1.proceeds * Float($1.units) })
                return (sum, day)
            }
    }

    private func getRawUpdates(_ lastNDays: Int, filteredApps: [ACApp] = []) -> [(Float, Date)] {
        let downloadEntries = entries.filter({ $0.type == .update && $0.belongsToApp(apps: filteredApps) })
        let latestDate: Date = downloadEntries.count > 0 ? downloadEntries.map({ $0.date }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 }) : Date()

        return latestDate.getLastNDates(lastNDays)
            .map { day -> (Float, Date) in
                let count = downloadEntries.filter({ $0.date == day }).reduce(0, { $0 + $1.units })
                return (Float(count), day)
            }
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
        }
    }

    private func getDownloadsSum(_ lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        var result: Float = 0
        for download in getRawDownloads(lastNDays, filteredApps: filteredApps) {
            result += download.0
        }
        return result
    }

    private func getProceedsSum(_ lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        var result: Float = 0
        for proceed in getRawProceeds(lastNDays, filteredApps: filteredApps) {
            result += proceed.0
        }
        return result
    }

    private func getUpdatesSum(_ lastNDays: Int, filteredApps: [ACApp] = []) -> Float {
        var result: Float = 0
        for update in getRawUpdates(lastNDays, filteredApps: filteredApps) {
            result += update.0
        }
        return result
    }

    // MARK: Getting Dates
    func latestReportingDate() -> String {
        let latestDate: Date? = entries.map({ $0.date }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 })

        guard let date = latestDate else {
            return NSLocalizedString("NO_DATA", comment: "")
        }
        return date.toString()
    }

    // MARK: Mock Data
    static let example = createMockData(31)
    static let exampleLargeSums = createMockData(31, largeValues: true)

    private static func createMockData(_ days: Int, largeValues: Bool = false) -> ACData {
        var entries: [ACEntry] = []
        let countries = ["US", "DE", "ES", "UK"]
        let devices = ["Desktop", "iPhone", "iPad"]

        Date(timeIntervalSinceNow: -86400).getLastNDates(days).forEach { day in
            for _ in 0...(Int.random(in: 10...30) * (largeValues ? 5 : 1)) {
                entries.append(ACEntry(appTitle: "TestApp",
                                       appSKU: "TestApp",
                                       units: Int.random(in: 1...10),
                                       proceeds: Float.random(in: 0...5),
                                       date: day, countryCode: countries.randomElement() ?? "US",
                                       device: devices.randomElement() ?? "iPhone",
                                       type: ACEntryType.allCases.randomElement() ?? .download))
            }
        }
        // TODO: create mock ACApp
        return ACData(entries: entries, currency: .USD, apps: [])
    }
}

enum InfoType {
    case proceeds, downloads, updates

    var systemImage: String {
        switch self {
        case .proceeds:
            return "dollarsign.circle"
        case .downloads:
            return "square.and.arrow.down"
        case .updates:
            return "arrow.triangle.2.circlepath"
        }
    }
}
