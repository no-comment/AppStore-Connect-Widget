//
//  Widgets.swift
//  Widgets
//
//  Created by Miká Kruschel on 29.03.21.
//

import WidgetKit
import SwiftUI
import Intents
import Promises

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ACStatEntry {
        ACStatEntry(date: Date(), data: .example, configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (ACStatEntry) -> ()) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            getApiData()
                .then { data in
                    let entry = ACStatEntry(date: Date(), data: data, configuration: configuration)
                    completion(entry)
                }
                .catch { err in
                    let entry = ACStatEntry(date: Date(), data: nil, error: err as? APIError, configuration: configuration)
                    completion(entry)
                }
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ACStatEntry] = []
        
        getApiData()
            .then { data in
                let entry = ACStatEntry(date: Date(), data: data, configuration: configuration)
                entries.append(entry)
                
                let nextUpdateDate = Date().advanced(by: 5 * 60)
                let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
                completion(timeline)
            }
            .catch { err in
                let entry = ACStatEntry(date: Date(), data: nil, error: err as? APIError, configuration: configuration)
                entries.append(entry)
                
                let nextUpdateDate = Date().advanced(by: 5 * 60)
                let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
                completion(timeline)
            }
    }
    
    func getApiData() -> Promise<ACData> {
        let issuerID: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.issuerID) ?? ""
        let privateKeyID: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.privateKeyID) ?? ""
        let privateKey: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.privateKey) ?? ""
        let vendorNumber: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.vendorNumber) ?? ""

        if issuerID == "" || privateKeyID == "" || privateKey == "" || vendorNumber == "" {
            let promise = Promise<ACData>.pending()
            promise.reject(APIError.invalidCredentials)
            return promise
        }
        let api = AppStoreConnectApi(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: privateKey, vendorNumber: vendorNumber)
        return api.getData()
    }
}

struct ACStatEntry: TimelineEntry {
    let date: Date
    let data: ACData?
    var error: APIError? = nil
    let configuration: ConfigurationIntent
}

extension ACStatEntry {
    static let placeholder = ACStatEntry(date: Date(), data: .example, configuration: ConfigurationIntent())
}

struct WidgetsEntryView : View {
    @Environment(\.widgetFamily) var size
    
    var entry: Provider.Entry
    
    var body: some View {
        if let data = entry.data {
            switch size {
            case .systemSmall:
                SummarySmall(data: data)
            case .systemMedium:
                SummaryMedium(data: data)
            default:
                ErrorWidget(error: .unknown)
            }
        } else {
            ErrorWidget(error: entry.error ?? .unknown)
        }
    }
}

@main
struct Widgets: Widget {
    let kind: String = "Widgets"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsEntryView(entry: ACStatEntry(date: Date(), data: .example, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        WidgetsEntryView(entry: ACStatEntry(date: Date(), data: .example, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
