// タンザクのホーム画面・ロック画面ウィジェット（WidgetKit）。
//
// このファイルはまだ Xcode のプロジェクトに入っていない。Xcode で
// File > New > Target > Widget Extension（名前 TanzakuWidget）を作り、
// できたファイルをこのファイルで置き換える。本体とウィジェットの両方に
// App Group「group.com.ookura.tanzaku」を付ける（README の手順）。
import SwiftUI
import WidgetKit

private let appGroup = "group.com.ookura.tanzaku"

struct TanzakuEntry: TimelineEntry {
    let date: Date
    let kigo: String
    let reading: String
    let season: String
    let streak: Int
    let composedToday: Bool
    let latestHaiku: String
}

struct TanzakuProvider: TimelineProvider {
    private var jst: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return c
    }

    func placeholder(in context: Context) -> TanzakuEntry {
        TanzakuEntry(date: Date(), kigo: "木枯", reading: "こがらし", season: "冬", streak: 3, composedToday: false, latestHaiku: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (TanzakuEntry) -> Void) {
        completion(entry(at: Date(), tomorrow: false))
    }

    /// 今日の分と、日本時間の0時からの翌日分の2つを並べる（アプリが翌日分も書いておく）。
    func getTimeline(in context: Context, completion: @escaping (Timeline<TanzakuEntry>) -> Void) {
        let now = Date()
        let midnight = jst.startOfDay(for: jst.date(byAdding: .day, value: 1, to: now)!)
        let entries = [entry(at: now, tomorrow: false), entry(at: midnight, tomorrow: true)]
        completion(Timeline(entries: entries, policy: .after(midnight.addingTimeInterval(60 * 60))))
    }

    private func entry(at date: Date, tomorrow: Bool) -> TanzakuEntry {
        let d = UserDefaults(suiteName: appGroup)
        let p = tomorrow ? "tomorrow_" : ""
        return TanzakuEntry(
            date: date,
            kigo: d?.string(forKey: tomorrow ? "tomorrow_kigo" : "kigo") ?? "タンザク",
            reading: d?.string(forKey: tomorrow ? "tomorrow_reading" : "kigo_reading") ?? "",
            season: d?.string(forKey: "\(p)season") ?? "",
            streak: d?.integer(forKey: "streak") ?? 0,
            composedToday: tomorrow ? false : (d?.bool(forKey: "composed_today") ?? false),
            latestHaiku: d?.string(forKey: "latest_haiku") ?? ""
        )
    }
}

struct TanzakuWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: TanzakuEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("兼題 \(entry.kigo)")
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("今日の兼題").font(.caption2)
                Text(entry.kigo).font(.headline)
            }
        default:
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.season.isEmpty ? "今日の兼題" : "今日の兼題・\(entry.season)")
                    .font(.caption).foregroundColor(.secondary)
                Text(entry.kigo).font(.system(size: 28, design: .serif))
                Text(entry.reading).font(.caption2).foregroundColor(.secondary)
                Spacer(minLength: 0)
                if family == .systemMedium && !entry.latestHaiku.isEmpty {
                    Text(entry.latestHaiku).font(.system(size: 13, design: .serif)).lineLimit(1)
                }
                Text(entry.composedToday ? "連続 \(entry.streak) 日 ✓" : "連続 \(entry.streak) 日")
                    .font(.caption).foregroundColor(Color(red: 0.72, green: 0.16, blue: 0.18))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@main
struct TanzakuWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TanzakuWidget", provider: TanzakuProvider()) { entry in
            TanzakuWidgetView(entry: entry)
                .widgetURL(URL(string: "tanzaku://compose?homeWidget"))
                .containerBackground(Color(red: 0.96, green: 0.93, blue: 0.87), for: .widget)
        }
        .configurationDisplayName("今日の兼題")
        .description("今日の季語と連続日数。タップで「詠む」を開きます。")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}
