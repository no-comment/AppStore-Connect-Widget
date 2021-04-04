//
//  ACData.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import Foundation
import SwiftUI

struct ACData {
    private let downloads: [(Int, Date)]
    private let proceeds: [(Float, Date)]
    let currency: String

    init(downloads: [(Int, Date)], proceeds: [(Float, Date)], currency: String) {
        self.downloads = downloads.sorted { $0.1 > $1.1 }
        self.proceeds = proceeds.sorted { $0.1 > $1.1 }
        self.currency = currency
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
        var result: [(Int, Date)] = []
        let range = min(downloads.count, lastNDays)
        for i in 0..<range {
            result.append(downloads[i])
        }
        return result
    }

    func getProceeds(_ lastNDays: Int) -> [(Float, Date)] {
        var result: [(Float, Date)] = []
        let range = min(proceeds.count, lastNDays)
        for i in 0..<range {
            result.append(proceeds[i])
        }
        return result
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
        guard let date = downloads.first?.1 else {
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
    static let example = createMockData(35)
    static let exampleLargeSums = createMockData(35, largeValues: true)

    private static func createMockData(_ days: Int, largeValues: Bool = false) -> ACData {
        var downloads: [(Int, Date)] = []
        var proceeds: [(Float, Date)] = []

        for i in 1..<days+1 {
            if largeValues {
                downloads.append((Int.random(in: 0..<1600), Date(timeIntervalSinceNow: -86400*Double(i))))
                proceeds.append((Float.random(in: 0..<700), Date(timeIntervalSinceNow: -86400*Double(i))))
            } else {
                downloads.append((Int.random(in: 0..<110), Date(timeIntervalSinceNow: -86400*Double(i))))
                proceeds.append((Float.random(in: 0..<40), Date(timeIntervalSinceNow: -86400*Double(i))))
            }
        }

        return ACData(downloads: downloads, proceeds: proceeds, currency: "$")
    }
}
