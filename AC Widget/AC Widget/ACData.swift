//
//  ACData.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import Foundation

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
    func getDownloads(_ lastNDays: Int = 1, size: NumberLength = .standard) -> String {
        let num: Int = getDownloads(lastNDays)
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
            nf.maximumFractionDigits = 3
        }
        
        return (nf.string(from: fNum) ?? "0").appending("K")
    }
    
    func getProceeds(_ lastNDays: Int = 1, size: NumberLength = .standard) -> String {
        let num: Float = getProceeds(lastNDays)
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
    
    private func getDownloads(_ lastNDays: Int = 1) -> Int {
        var result: Int = 0
        let range = min(downloads.count, lastNDays)
        for i in 0..<range {
            result += downloads[i].0
        }
        return result
    }
    
    private func getProceeds(_ lastNDays: Int = 1) -> Float {
        var result: Float = 0
        let range = min(proceeds.count, lastNDays)
        for i in 0..<range {
            result += proceeds[i].0
        }
        return result
    }
    
    enum NumberLength { case compact, standard }
    
    
    // MARK: Getting Dates
    func latestReportingDate() -> String {
        guard let date = downloads.first?.1 else {
            return "No Data"
        }
        return dateToString(date)
    }
    
    private func dateToString(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        let df = DateFormatter()
        df.dateFormat = "dd. MM."
        return df.string(from: date)
    }
    
    
    // MARK: Mock Data
    static let example = ACData(downloads: [
        (47, Date(timeIntervalSinceNow: -86400*1)),
        (34, Date(timeIntervalSinceNow: -86400*2)),
        (44, Date(timeIntervalSinceNow: -86400*3)),
        (12, Date(timeIntervalSinceNow: -86400*4)),
        (43, Date(timeIntervalSinceNow: -86400*5)),
        (53, Date(timeIntervalSinceNow: -86400*6)),
        (69, Date(timeIntervalSinceNow: -86400*7)),
        (37, Date(timeIntervalSinceNow: -86400*8)),
        (82, Date(timeIntervalSinceNow: -86400*9)),
        (79, Date(timeIntervalSinceNow: -86400*10))
    ], proceeds: [
        (13.5, Date(timeIntervalSinceNow: -86400*1)),
        (18.2, Date(timeIntervalSinceNow: -86400*2)),
        (9.7, Date(timeIntervalSinceNow: -86400*3)),
        (15.0, Date(timeIntervalSinceNow: -86400*4)),
        (16.3, Date(timeIntervalSinceNow: -86400*5)),
        (13.9, Date(timeIntervalSinceNow: -86400*6)),
        (15.5, Date(timeIntervalSinceNow: -86400*7)),
        (18.1, Date(timeIntervalSinceNow: -86400*8)),
        (34.5, Date(timeIntervalSinceNow: -86400*9)),
        (22.4, Date(timeIntervalSinceNow: -86400*10))
    ], currency: "$")
    
    static let exampleLargeSums = ACData(downloads: [
        (473, Date(timeIntervalSinceNow: -86400*1)),
        (344, Date(timeIntervalSinceNow: -86400*2)),
        (447, Date(timeIntervalSinceNow: -86400*3)),
        (121, Date(timeIntervalSinceNow: -86400*4)),
        (435, Date(timeIntervalSinceNow: -86400*5)),
        (538, Date(timeIntervalSinceNow: -86400*6)),
        (690, Date(timeIntervalSinceNow: -86400*7)),
        (378, Date(timeIntervalSinceNow: -86400*8)),
        (823, Date(timeIntervalSinceNow: -86400*9)),
        (797, Date(timeIntervalSinceNow: -86400*10))
    ], proceeds: [
        (453.54, Date(timeIntervalSinceNow: -86400*1)),
        (128.2, Date(timeIntervalSinceNow: -86400*2)),
        (69.7, Date(timeIntervalSinceNow: -86400*3)),
        (195.0, Date(timeIntervalSinceNow: -86400*4)),
        (316.3, Date(timeIntervalSinceNow: -86400*5)),
        (173.9, Date(timeIntervalSinceNow: -86400*6)),
        (135.5, Date(timeIntervalSinceNow: -86400*7)),
        (418.1, Date(timeIntervalSinceNow: -86400*8)),
        (324.5, Date(timeIntervalSinceNow: -86400*9)),
        (542.4, Date(timeIntervalSinceNow: -86400*10))
    ], currency: "$")
}
