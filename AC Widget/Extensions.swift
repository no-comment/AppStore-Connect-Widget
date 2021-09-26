//
//  Extensions.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import SwiftUI
import WidgetKit
import DynamicColor
import KeychainAccess

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

    func dateToMonthNumber() -> Int {
        return Int(Calendar.current.component(.day, from: self))
    }
}

// MARK: UIApplication
extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    static var buildVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

// MARK: User Defaults
extension UserDefaults {
    static var shared: UserDefaults? {
        UserDefaults(suiteName: "group.dev.kruschel.ACWidget")
    }
}

enum UserDefaultsKey {
    @available(*, deprecated)
    static let apiKeys = "apiKeys"
    static let dataCache = "dataCache"
    static let includeRedownloads = "includeRedownloads"
    static let homeSelectedKey = "homeSelectedKey"
    static let homeCurrency = "homeCurrency"
    static let tilesInHome = "tilesInHome"
    static let appStoreNotice = "appStoreNotice"
    static let lastSeenVersion = "lastSeenVersion"
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

    func countryCodeToName() -> String {
        return (Locale.current as NSLocale).localizedString(forCountryCode: self) ?? ""
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
        case .systemExtraLarge:
            width = 660
            height = 345
        @unknown default:
            width = 329
            height = 141
        }
    }
    func body(content: Content) -> some View {
        content
            .aspectRatio(CGSize(width: width, height: height), contentMode: .fill)
            .frame(minWidth: 0.8 * width, maxWidth: 1.2 * width, minHeight: 0.8 * height, maxHeight: 1.2 * height)
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

// Close sheet button
struct CloseSheet: ViewModifier {
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle").imageScale(.large)
                    }.keyboardShortcut(.cancelAction)
                }
            })
    }
}

extension View {
    func closeSheetButton() -> some View {
        self.modifier(CloseSheet())
    }
}

// MARK: Color
extension Color {
    static let widgetBackground: Color = Color("WidgetBackground")
    static let widgetSecondary: Color = Color("WidgetSecondary")
    static let systemWhite: Color = Color("systemWhite")
    static let cardColor: Color = Color("CardColor")
    static let secondaryCardColor: Color = Color("SecondaryCardColor")
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

// MARK: ACEntry Array
extension Array where Element == ACEntry {
    func getLastDays(_ n: Int) -> [ACEntry] {
        let latestDate: Date? = self.reduce(Date.distantPast, { $0 > $1.date ? $0 : $1.date })
        let lastNDays: [Date] = (latestDate ?? Date()).getLastNDates(n)
        return self.filter({ lastNDays.contains($0.date) })
    }

    func filterApps(_ isIncluded: [ACApp]) -> [ACEntry] {
        return self.filter({ $0.belongsToApp(apps: isIncluded) })
    }
}

extension Array where Element == (Float, Date) {
    func fillZeroLastDays(_ n: Int, latestDate: Date) -> [(Float, Date)] {
        let lastNDays: [Date] = latestDate.getLastNDates(n)
        return lastNDays.map({ day -> (Float, Date) in
            return self.first(where: { $0.1 == day }) ?? (Float.zero, day)
        })
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
