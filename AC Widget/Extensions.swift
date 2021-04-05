//
//  Extensions.swift
//  AC Widget
//
//  Created by Miká Kruschel on 01.04.21.
//

import Foundation
import SwiftUI
import WidgetKit

extension Date {
    func getCETHour() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "CET") ?? .current
        return calendar.component(.hour, from: self)
    }

    func getPSTHour() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "PST") ?? .current
        return calendar.component(.hour, from: self)
    }

    func getJSTHour() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "JST") ?? .current
        return calendar.component(.hour, from: self)
    }

    func getMinutes() -> Int {
        return Calendar(identifier: .gregorian).component(.minute, from: self)
    }

    func nextFullHour() -> Date {
        if let next = Calendar.current.date(bySetting: .minute, value: 0, of: self) {
            return next.addingTimeInterval(60 * 60) // next hour
        }

        return self
    }

    func nextDateWithMinute(_ minute: Int) -> Date {
        if let next = Calendar.current.date(bySetting: .minute, value: 30, of: self) {
            return next
        }

        return self
    }
}

extension UserDefaults {
    static var shared: UserDefaults? {
        UserDefaults(suiteName: "group.dev.kruschel.ACWidget")
    }
}

enum UserDefaultsKey {
    static let apiKeys = "apiKeys"

    static let completedOnboarding = "completedOnboarding"

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

extension CurrencyParam {
    static let system = CurrencyParam(identifier: "System", display: NSLocalizedString("SYSTEM", comment: ""))

    func toCurrency() -> Currency? {
        if self == .system {
            return Currency(rawValue: Locale.current.currencyCode ?? "")
        }
        return Currency(rawValue: self.identifier ?? "")
    }
}
