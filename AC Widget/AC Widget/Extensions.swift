//
//  Extensions.swift
//  AC Widget
//
//  Created by Miká Kruschel on 01.04.21.
//

import Foundation
import SwiftUI
import WidgetKit

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

struct ShowAsWidget: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    
    init(_ size: WidgetFamily) {
        switch size {
        case .systemSmall:
            width = 155
            height = 155
        case .systemMedium:
            width = 329
            height = 155
        case .systemLarge:
            width = 329
            height = 345
        @unknown default:
            width = 329
            height = 141
        }
    }
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 6)
    }
}

extension View {
    func showAsWidget(_ size: WidgetFamily) -> some View {
        self.modifier(ShowAsWidget(size))
    }
}
