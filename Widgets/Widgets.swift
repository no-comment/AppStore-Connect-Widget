//
//  Widgets.swift
//  AC Widget by NO-COMMENT
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ACStatEntry {
        ACStatEntry(date: Date(), data: .example, filteredApps: [], color: .accentColor, configuration: WidgetConfigurationIntent())
    }

    func getSnapshot(for configuration: WidgetConfigurationIntent, in context: Context, completion: @escaping (ACStatEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            Task.init {
                do {
                    let data = try await getApiData(currencyParam: configuration.currency, apiKeyParam: configuration.apiKey)
                    let isNewData = data.getRawData(for: .proceeds, lastNDays: 3).contains { (proceed) -> Bool in
                        Calendar.current.isDateInToday(proceed.1) ||
                        Calendar.current.isDateInYesterday(proceed.1)
                    }

                    let entry = ACStatEntry(
                        date: Date(),
                        data: data,
                        filteredApps: configuration.filteredApps?.compactMap({ $0.toACApp(data: data) }) ?? [],
                        color: configuration.apiKey?.getColor() ?? .accentColor,
                        configuration: configuration,
                        relevance: isNewData ? .high : .medium
                    )
                    completion(entry)
                } catch let err {
                    let entry = ACStatEntry(date: Date(), data: nil, filteredApps: [], error: err as? APIError, color: configuration.apiKey?.getColor() ?? .accentColor, configuration: configuration, relevance: .low)
                    completion(entry)
                }
            }
        }
    }

    func getTimeline(for configuration: WidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task.init {
            do {
                let data = try await getApiData(currencyParam: configuration.currency, apiKeyParam: configuration.apiKey)
                let isNewData = data.getRawData(for: .proceeds, lastNDays: 3).contains { (proceed) -> Bool in
                    Calendar.current.isDateInToday(proceed.1) ||
                    Calendar.current.isDateInYesterday(proceed.1)
                }

                let entry = ACStatEntry(date: Date(),
                                        data: data,
                                        filteredApps: configuration.filteredApps?.compactMap({ $0.toACApp(data: data) }) ?? [],
                                        color: configuration.apiKey?.getColor() ?? .accentColor,
                                        configuration: configuration,
                                        relevance: isNewData ? .high : .medium)

                // Report is not available yet. Daily reports for the Americas are available by 5 am Pacific Time; Japan, Australia, and New Zealand by 5 am Japan Standard Time; and 5 am Central European Time for all other territories.

                var nextUpdate = Date()

                if nextUpdate.getCETHour() <= 12 {
                    // every 15 minutes
                    nextUpdate = nextUpdate.advanced(by: 15 * 60)
                } else {
                    nextUpdate = nextUpdate.nextFullHour()
                }

                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch let err as APIError {
                let entry = ACStatEntry(date: Date(), data: nil, filteredApps: [], error: err, color: .accentColor, configuration: configuration)

                var nextUpdateDate = Date()
                if err == .invalidCredentials {
                    nextUpdateDate = nextUpdateDate.advanced(by: 24 * 60)
                } else {
                    // wenn api down, update in 5 min erneut
                    nextUpdateDate = nextUpdateDate.advanced(by: 5 * 60)
                }

                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            } catch {
                let entry = ACStatEntry(date: Date(), data: nil, filteredApps: [], error: nil, color: .accentColor, configuration: configuration)

                // wenn api down, update in 5 min erneut
                let timeline = Timeline(entries: [entry], policy: .after(Date().advanced(by: 5 * 60)))
                completion(timeline)
            }
        }
    }

    func getApiData(currencyParam: CurrencyParam?, apiKeyParam: ApiKeyParam?) async throws -> ACData {
        guard let apiKey = apiKeyParam?.toApiKey(),
              APIKeyProvider().getApiKey(apiKeyId: apiKey.id) != nil else {
                  throw APIError.invalidCredentials
              }
        let api = await AppStoreConnectApi(apiKey: apiKey)
        return try await api.getData(currency: currencyParam)
    }
}

struct ACStatEntry: TimelineEntry {
    let date: Date
    let data: ACData?
    let filteredApps: [ACApp]
    var error: APIError?
    let color: Color
    let configuration: WidgetConfigurationIntent
    var relevance: TimelineEntryRelevance?
}

extension ACStatEntry {
    static let placeholder = ACStatEntry(date: Date(), data: .example, filteredApps: [], color: .accentColor, configuration: WidgetConfigurationIntent())
}

extension TimelineEntryRelevance {
    static let low = TimelineEntryRelevance(score: 0, duration: 0)
    static let medium = TimelineEntryRelevance(score: 50, duration: 60 * 60)
    static let high = TimelineEntryRelevance(score: 100, duration: 60 * 60)
}

struct WidgetsEntryView: View {
    @Environment(\.widgetFamily) var size

    var entry: Provider.Entry

    var body: some View {
        if let data = entry.data {
            switch size {
            case .systemSmall:
                SummarySmall(data: data, color: entry.color, filteredApps: entry.filteredApps)
            case .systemMedium:
                SummaryMedium(data: data, color: entry.color, filteredApps: entry.filteredApps)
            case .systemLarge:
                SummaryLarge(data: data, color: entry.color, filteredApps: entry.filteredApps)
            case .systemExtraLarge:
                SummaryExtraLarge(data: data, color: entry.color, filteredApps: entry.filteredApps)
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
        IntentConfiguration(kind: kind, intent: WidgetConfigurationIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.widgetBackground)
        }
        .configurationDisplayName("WIDGET_NAME")
        .description("WIDGET_DESC")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsEntryView(entry: ACStatEntry(date: Date(), data: .example, filteredApps: [.mockApp], color: .accentColor, configuration: WidgetConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        WidgetsEntryView(entry: ACStatEntry(date: Date(), data: .example, filteredApps: [.mockApp], color: .accentColor, configuration: WidgetConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
