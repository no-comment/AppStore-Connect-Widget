//
//  ACEntry.swift
//  AC Widget
//
//  Created by Miká Kruschel on 06.04.21.
//

import Foundation

struct ACEntry: Codable {
    let appTitle: String
    let appSKU: String
    let units: Int
    let proceeds: Float // TODO: Maybe use Decimal or change encodable for float to save space (1.9408223628997803)
    let date: Date
    let countryCode: String
    let device: String
    let type: ACEntryType
}

enum ACEntryType: String, CaseIterable, Codable {
    case download
    case redownload
    case aip
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
            self = .aip
        case "IA3":
            self = .restoredIap
        case "7", "7F", "7T", "F7":
            self = .update
        default:
            self = .unknown
        }
    }
}
