//
//  Extensions.swift
//  AC Widget
//
//  Created by Miká Kruschel on 01.04.21.
//

import Foundation
import SwiftUI

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

struct HideViewRedacted: ViewModifier {
    @Environment(\.redactionReasons) private var reasons
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if reasons.isEmpty {
            content
        } else {
            EmptyView()
        }
    }
}

extension View {
    func hideWhenRedacted() -> some View {
        self.modifier(HideViewRedacted())
    }
}
