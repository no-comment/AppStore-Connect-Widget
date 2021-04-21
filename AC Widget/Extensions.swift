//
//  Extensions.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import SwiftUI
import WidgetKit
import DynamicColor

extension Date {
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }

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

    func toString() -> String {
        if Calendar.current.isDateInToday(self) {
            return NSLocalizedString("TODAY", comment: "")
        }
        if Calendar.current.isDateInYesterday(self) {
            return NSLocalizedString("YESTERDAY", comment: "")
        }
        if self == Date(timeIntervalSince1970: 0) {
            return ""
        }
        let df = DateFormatter()
        if Calendar.current.isDate(self, inSameDayAs: Date().advanced(by: -86400*6)) || self > Date().advanced(by: -86400*6) {
            return df.weekdaySymbols[Calendar.current.component(.weekday, from: self) - 1]
        }
        df.dateFormat = "dd. MMM."
        return df.string(from: self)
    }
}

// MARK: User Defaults
extension UserDefaults {
    static var shared: UserDefaults? {
        UserDefaults(suiteName: "group.dev.kruschel.ACWidget")
    }
}

enum UserDefaultsKey {
    static let apiKeys = "apiKeys"
    static let completedOnboarding = "completedOnboarding"
    static let dataCache = "dataCache"
    static let homeSelectedKey = "homeSelectedKey"
}

// MARK: Editing Strings
extension String {
    func removeCharacters(from set: CharacterSet) -> String {
        var newString = self
        newString.removeAll { char -> Bool in
            guard let scalar = char.unicodeScalars.first else { return false }
            return set.contains(scalar)
        }
        return newString
    }
}

// MARK: View Modifier
// Hide Redacted
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

// Show As Widget
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

// MARK: Color
extension Color {
    static let widgetBackground: Color = Color("WidgetBackground")
    static let widgetSecondary: Color = Color("WidgetSecondary")
    static let systemWhite: Color = Color("systemWhite")
}

// From: http://brunowernimont.me/howtos/make-swiftui-color-codable
extension Color {
    // swiftlint:disable:next large_tuple
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }

        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)

        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}

// From: https://stackoverflow.com/questions/42355778/how-to-compute-color-contrast-ratio-between-two-uicolor-instances/42355779
extension Color {
    func readable(colorScheme: ColorScheme) -> Color {
        let lum = self.luminance()

        switch colorScheme {
        case .light:
            if lum > 0.99 {
                return .black
            } else if lum > 0.7 {
                return Color(DynamicColor(self).darkened())
            }
        case .dark:
            if lum < 0.01 {
                return .white
            } else if lum < 0.2 {
                return Color(DynamicColor(self).lighter())
            }
        @unknown default:
            return self
        }

        return self
    }

    func luminance() -> CGFloat {
        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * adjust(colorComponent: self.colorComponents?.red ?? 0) + 0.7152 * adjust(colorComponent: self.colorComponents?.green ?? 0) + 0.0722 * adjust(colorComponent: self.colorComponents?.blue ?? 0)
    }
}

// MARK: Other
extension Collection {
    func count(where test: (Element) throws -> Bool) rethrows -> Int {
        return try self.filter(test).count
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
