import SwiftUI
import WidgetKit

// ホーム画面（小・中）とロック画面のウィジェット：今月のシートの埋まり具合と、今日の空欄。
//
// アプリは App Group「group.com.ookura.keshiin」の UserDefaults に、今日の分（today_）と
// 明日の分（next_）を書いておく。タイムラインに「今」と「次の0時」の2つを載せ、
// 0時になったらアプリを開かなくても明日の分に切り替わるようにする。

private let appGroup = "group.com.ookura.keshiin"

struct SheetEntry: TimelineEntry {
  let date: Date
  let month: String
  let count: String
  let grid: String
  let status: String
}

private func isoDay(_ d: Date) -> String {
  let f = DateFormatter()
  f.calendar = Calendar(identifier: .gregorian)
  f.locale = Locale(identifier: "en_US_POSIX")
  f.dateFormat = "yyyy-MM-dd"
  return f.string(from: d)
}

private func entry(at date: Date) -> SheetEntry {
  let ud = UserDefaults(suiteName: appGroup)
  let day = isoDay(date)
  let prefix = ud?.string(forKey: "next_date") == day ? "next_" : "today_"
  let fresh = ud?.string(forKey: "\(prefix)date") == day
  return SheetEntry(
    date: date,
    month: ud?.string(forKey: "\(prefix)month") ?? "今月のシート",
    count: ud?.string(forKey: "\(prefix)count") ?? "—",
    grid: ud?.string(forKey: "\(prefix)grid") ?? "",
    status: fresh ? (ud?.string(forKey: "\(prefix)status") ?? "") : "アプリを開くと更新します"
  )
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SheetEntry {
    SheetEntry(date: Date(), month: "11月のシート", count: "12／30", grid: "■■■■□\n■■◇□□", status: "今日のマスは空欄")
  }

  func getSnapshot(in context: Context, completion: @escaping (SheetEntry) -> Void) {
    completion(entry(at: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SheetEntry>) -> Void) {
    let now = Date()
    let midnight = Calendar.current.nextDate(
      after: now, matching: DateComponents(hour: 0, minute: 0, second: 5), matchingPolicy: .nextTime
    ) ?? now.addingTimeInterval(3600)
    completion(Timeline(entries: [entry(at: now), entry(at: midnight)], policy: .after(midnight)))
  }
}

struct KeshiinWidgetView: View {
  @Environment(\.widgetFamily) var family
  let entry: SheetEntry

  var body: some View {
    switch family {
    case .accessoryRectangular, .accessoryInline:
      Text("\(entry.count)　\(entry.status)")
    default:
      VStack(alignment: .leading, spacing: 4) {
        Text(entry.month).font(.caption).foregroundColor(.secondary)
        Text(entry.count).font(.title2).bold()
        if family == .systemMedium {
          Text(entry.grid).font(.system(size: 11, design: .monospaced))
        }
        Text(entry.status).font(.caption2).foregroundColor(Color(red: 0.72, green: 0.26, blue: 0.18))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }
}

@main
struct KeshiinWidget: Widget {
  let kind = "KeshiinWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      KeshiinWidgetView(entry: entry)
        .containerBackground(Color(red: 0.96, green: 0.94, blue: 0.89), for: .widget)
        .widgetURL(URL(string: "keshiin://create"))
    }
    .configurationDisplayName("今月のシート")
    .description("シートの埋まり具合と、今日の空欄")
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
  }
}
