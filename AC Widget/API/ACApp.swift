//
//  ACApp.swift
//  AC Widget by NO-COMMENT
//

import Foundation

struct ACApp: Codable, Identifiable {
    var id: String { return sku }
    let appstoreId: String
    let name: String
    let sku: String
    let version: String
    let currentVersionReleaseDate: String
    let artworkUrl60: String
    let artworkUrl100: String

    static func == (lhs: ACApp, rhs: ACApp) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ACApp {
    static let mockApp = ACApp(
        appstoreId: "testId",
        name: "Test App",
        sku: "test.app.sku",
        version: "1.2.3",
        currentVersionReleaseDate: "1.2.3",
        artworkUrl60: "https://is2-ssl.mzstatic.com/image/thumb/Purple125/v4/62/05/65/6205654f-2791-70f0-c96a-ecb4e2a662f7/source/60x60bb.jpg",
        artworkUrl100: "https://is2-ssl.mzstatic.com/image/thumb/Purple115/v4/16/fa/99/16fa99d4-67b5-3bcc-9b28-34f88326ac5d/source/100x100bb.jpg")
}

extension FilteredAppParam {
    func toACApp(data: ACData) -> ACApp? {
        return data.apps.first(where: { $0.id == self.identifier })
    }
}
