//
//  ACEntry.swift
//  AC Widget by NO-COMMENT
//

import Foundation

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
        case "3", "3F":
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
