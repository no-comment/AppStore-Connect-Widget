//
//  ACEntry.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct ACEntry: Codable {
    let appTitle: String
    let appSKU: String
    let units: Int
    let proceeds: Float
    let date: Date
    let countryCode: String
    let device: String
    let appIdentifier: String
    let type: ACEntryType
}

extension ACEntry {
    func belongsToApp(apps: [ACApp]) -> Bool {
        if apps.count == 0 { return true }
        return apps.contains(where: { app in
            app.sku == self.appSKU
        })
    }
}

enum ACEntryType: String, CaseIterable, Codable {
    case download
    case redownload
    case iap
    case restoredIap
    case update
    case unknown

    init(_ productTypeIdentifier: String?) {
        switch productTypeIdentifier {
        case "1", "1-B", "F1-B", "1E", "1EP", "1EU", "1F", "1T", "F1":
            self = .download
        case "3", "3F", "F3":
            self = .redownload
        case "FI1", "IA1", "IA1-M", "IA9", "IA9-M", "IAY", "IAY-M":
            self = .iap
        case "IA3":
            self = .restoredIap
        case "7", "7F", "7T", "F7":
            self = .update
        default:
            self = .unknown
        }
    }
}

enum ACDevice: String, CaseIterable, Identifiable {
    case desktop
    case iPhone
    case iPad
    case appleWatch
    case appleTV
    case iPod
    case unknown

    init(_ deviceString: String?) {
        switch deviceString {
        case "iPhone":
            self = .iPhone
        case "iPad":
            self = .iPad
        case "Desktop":
            self = .desktop
        case "Apple Watch":
            self = .appleWatch
        case "Apple TV":
            self = .appleTV
        case "iPod":
            self = .iPod
        default:
            self = .unknown
        }
    }

    var id: String {
        self.rawValue
    }

    var symbol: String {
        switch self {
        case .iPhone:
            return "iphone"
        case .iPad:
            return "ipad"
        case .desktop:
            return "desktopcomputer"
        case .appleWatch:
            return "watchface.applewatch.case"
        case .appleTV:
            return "appletv"
        case .iPod:
            return "ipodtouch"
        case .unknown:
            return "questionmark"
        }
    }

    var color: Color {
        switch self {
        case .desktop:
            return Color("ChartColor1")
        case .iPhone:
            return Color("ChartColor2")
        case .iPad:
            return Color("ChartColor3")
        case .appleWatch:
            return Color("ChartColor4")
        case .appleTV:
            return Color("ChartColor5")
        case .iPod:
            return Color("ChartColor6")
        case .unknown:
            return .gray
        }
    }
}
