// ホーム画面・ロック画面ウィジェット：今日の4桁と、解いたかどうか。
//
// まだ Xcode の target には入れていない。入れ方は kipputen/README.md の「iOS ウィジェット」を参照。
// アプリは今日と翌日の分を App Group（group.com.ookura.kipputen）に書く（lib/daily/widget_payload.dart）。
// タイムラインに「今日」と「翌日 JST 0時」の2つを置くので、アプリを開かなくても0時に進む。
import SwiftUI
import WidgetKit

private let appGroup = "group.com.ookura.kipputen"

struct KipEntry: TimelineEntry {
  let date: Date
  let number: String?
  let done: Bool
}

private func jstKey(_ date: Date) -> String {
  let f = DateFormatter()
  f.locale = Locale(identifier: "en_US_POSIX")
  f.timeZone = TimeZone(identifier: "Asia/Tokyo")
  f.dateFormat = "yyyyMMdd"
  return f.string(from: date)
}

private func entry(at date: Date) -> KipEntry {
  let d = UserDefaults(suiteName: appGroup)
  let key = jstKey(date)
  return KipEntry(
    date: date,
    number: d?.string(forKey: "day_\(key)_title"),
    done: d?.string(forKey: "day_\(key)_done") == "1")
}

struct KipProvider: TimelineProvider {
  func placeholder(in context: Context) -> KipEntry {
    KipEntry(date: Date(), number: "5839", done: false)
  }

  func getSnapshot(in context: Context, completion: @escaping (KipEntry) -> Void) {
    completion(entry(at: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<KipEntry>) -> Void) {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    let now = Date()
    let midnight = cal.nextDate(
      after: now, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime)!
    completion(Timeline(entries: [entry(at: now), entry(at: midnight)], policy: .after(midnight)))
  }
}

struct KipputenWidgetView: View {
  let entry: KipEntry

  var body: some View {
    VStack(spacing: 4) {
      Text("今日の切符").font(.caption2)
      Text(entry.number.map { $0.map(String.init).joined(separator: " ") } ?? "- - - -")
        .font(.system(size: 26, weight: .heavy, design: .rounded))
        .minimumScaleFactor(0.6)
      Text(entry.number == nil ? "アプリを開いてください" : (entry.done ? "✂ 入鋏済み" : "まだ解いていません"))
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .foregroundStyle(Color(red: 0.13, green: 0.20, blue: 0.16))
    .containerBackground(Color(red: 0.90, green: 0.94, blue: 0.85), for: .widget)
  }
}

@main
struct KipputenWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "KipputenWidget", provider: KipProvider()) { e in
      KipputenWidgetView(entry: e)
    }
    .configurationDisplayName("今日の切符")
    .description("今日の4桁と、解いたかどうか")
    .supportedFamilies([.systemSmall, .accessoryRectangular])
  }
}
