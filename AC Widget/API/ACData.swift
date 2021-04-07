//
//  ACData.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import Foundation
import SwiftUI

struct ACData {
    private let entries: [ACEntry]
    let displayCurrency: Currency

    init(entries: [ACEntry], currency: Currency) {
        self.entries = entries
        self.displayCurrency = currency
    }

    // MARK: Getting Numbers
    func getDownloadsString(_ lastNDays: Int = 1, size: NumberLength = .standard) -> String {
        let num: Int = getDownloadsSum(lastNDays)
        if num < 1000 {
            return "\(num)"
        }

        let fNum: NSNumber = NSNumber(value: Float(num)/1000)
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
    }

    func getProceedsString(_ lastNDays: Int = 1, size: NumberLength = .standard) -> String {
        let num: Float = getProceedsSum(lastNDays)
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

    func getDownloads(_ lastNDays: Int) -> [(Int, Date)] {
        let downloadEntries = entries.filter({ $0.type == .download })
        let latestDate: Date = downloadEntries.count > 0 ? downloadEntries.map({ $0.date }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 }) : Date()

        return latestDate.getLastNDates(lastNDays)
            .map { day -> (Int, Date) in
                let count = downloadEntries.filter({ $0.date == day }).reduce(0, { $0 + $1.units })
                return (count, day)
            }
    }

    func getProceeds(_ lastNDays: Int) -> [(Float, Date)] {
        let downloadEntries = entries.filter({ $0.proceeds > 0 })
        let latestDate: Date? = entries.reduce(Date.distantPast, { $0 > $1.date ? $0 : $1.date })

        return (latestDate ?? Date()).getLastNDates(lastNDays)
            .map { day -> (Float, Date) in
                let sum = downloadEntries.filter({ $0.date == day }).reduce(Float.zero, { $0 + $1.proceeds * Float($1.units) })
                return (sum, day)
            }
    }

    private func getDownloadsSum(_ lastNDays: Int = 1) -> Int {
        var result: Int = 0
        for download in getDownloads(lastNDays) {
            result += download.0
        }
        return result
    }

    private func getProceedsSum(_ lastNDays: Int = 1) -> Float {
        var result: Float = 0
        for proceed in getProceeds(lastNDays) {
            result += proceed.0
        }
        return result
    }

    enum NumberLength { case compact, standard }

    // MARK: Getting Dates
    func latestReportingDate() -> String {
        let latestDate: Date? = entries.map({ $0.date }).reduce(Date.distantPast, { $0 > $1 ? $0 : $1 })

        guard let date = latestDate else {
            return NSLocalizedString("NO_DATA", comment: "")
        }
        return dateToString(date)
    }

    private func dateToString(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return NSLocalizedString("TODAY", comment: "")
        }
        if Calendar.current.isDateInYesterday(date) {
            return NSLocalizedString("YESTERDAY", comment: "")
        }
        let df = DateFormatter()
        if Calendar.current.isDate(date, inSameDayAs: date.advanced(by: -86400*6)) || date > date.advanced(by: -86400*6) {
            return df.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
        }
        df.dateFormat = "dd. MMM."
        return df.string(from: date)
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

        return ACData(entries: entries, currency: .USD)
    }
}
