//
//  Extensions.swift
//  AC Widget
//
//  Created by Miká Kruschel on 01.04.21.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults? {
        UserDefaults(suiteName: "group.dev.kruschel.ACWidget")
    }
}

struct UserDefaultsKey {
    static let issuerID = "issuerID"
    static let privateKeyID = "privateKeyID"
    static let privateKey = "privateKey"
    static let vendorNumber = "vendorNumber"
}
