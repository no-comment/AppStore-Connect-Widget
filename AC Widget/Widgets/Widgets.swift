//
//  Widgets.swift
//  Widgets
//
//  Created by Miká Kruschel on 29.03.21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ACStatEntry {
        ACStatEntry(date: Date(), proceedToday: 4, configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (ACStatEntry) -> ()) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            let entry = ACStatEntry(date: Date(), proceedToday: 4, configuration: configuration)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ACStatEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ACStatEntry(date: entryDate, proceedToday: 4, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ACStatEntry: TimelineEntry {
    let date: Date
    let proceedToday: Float
    let configuration: ConfigurationIntent
}

extension ACStatEntry {
    static let placeholder = ACStatEntry(date: Date(), proceedToday: 42.69, configuration: ConfigurationIntent())
}

struct WidgetsEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text(entry.date, style: .time)
            Text("\(entry.proceedToday)$")
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
    }
}

struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsEntryView(entry: ACStatEntry(date: Date(), proceedToday: 42.49, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
