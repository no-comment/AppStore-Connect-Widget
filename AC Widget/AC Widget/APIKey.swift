//
//  APIKey.swift
//  AC Widget
//
//  Created by Miká Kruschel on 04.04.21.
//

import Foundation

struct Note: Codable {
    let issuerID: String
    let privateKeyID: String
    let privateKey: String
    let vendorNumber: String
}
