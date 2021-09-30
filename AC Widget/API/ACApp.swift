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
    let artwork60ImgData: Data?

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
        artworkUrl100: "https://is2-ssl.mzstatic.com/image/thumb/Purple115/v4/16/fa/99/16fa99d4-67b5-3bcc-9b28-34f88326ac5d/source/100x100bb.jpg",
        // swiftlint:disable:next line_length
        artwork60ImgData: Data(base64Encoded: "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"))
}

extension FilteredAppParam {
    func toACApp(data: ACData) -> ACApp? {
        return data.apps.first(where: { $0.id == self.identifier })
    }
}
