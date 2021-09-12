//
//  ACApp.swift
//  AC Widget by NO-COMMENT
//

import Foundation

struct ACApp: Codable, Identifiable {
    let id: String
    let name: String
    let sku: String
    let version: String
    let currentVersionReleaseDate: String
    let artworkUrl60: String
    let artworkUrl100: String
}

extension ACApp {
    static let mockApp = ACApp(
        id: "testId",
        name: "Test App",
        sku: "test.app.sku",
        version: "1.2.3",
        currentVersionReleaseDate: "1.2.3",
        artworkUrl60: "https://is2-ssl.mzstatic.com/image/thumb/Purple115/v4/16/fa/99/16fa99d4-67b5-3bcc-9b28-34f88326ac5d/source/60x60bb.jpg",
        artworkUrl100: "https://is2-ssl.mzstatic.com/image/thumb/Purple115/v4/16/fa/99/16fa99d4-67b5-3bcc-9b28-34f88326ac5d/source/100x100bb.jpg")
}
