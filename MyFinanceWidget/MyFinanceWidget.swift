//
//  MyFinanceWidget.swift
//  MyFinanceWidget
//
//  Created by Вова Сербин on 01.07.2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.init(date: Date(), category: ["lol", "gigi"])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry.init(date: Date(), category: ["lol", "gigi"])
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        let entry = SimpleEntry.init(date: Date(), category: ["lol", "gigi"])
        entries.append(entry)
        
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let category: [String]
}

struct MyFinanceWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.category[0])
            Text(entry.category[1])
        }
    }
}

@main
struct MyFinanceWidget: Widget {
    let kind: String = "MyFinanceWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MyFinanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct MyFinanceWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyFinanceWidgetEntryView(entry: SimpleEntry.init(date: Date(), category: ["lol", "gigi"]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
