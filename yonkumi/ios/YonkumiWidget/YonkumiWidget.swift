// ホーム画面・ロック画面のウィジェット（WidgetKit）。
//
// アプリ（ookura_daily の DailyWidgetSnapshot）が App Group の UserDefaults に
// 今日と翌日の2日分を書く。タイムラインに「いま」と「切り替え時刻（日本時間の0時）」の
// 2項目を置き、アプリを開かなくても0時に翌日の番号へ進むようにする。
// 語はネタバレになるので出さない。
//
// Xcode でウィジェットの Extension ターゲット（名前 YonkumiWidget）を作り、
// このファイルと Info.plist を入れる。Runner と Extension の両方に
// App Group「group.com.ookura.yonkumi」を付ける（手順は README）。
import SwiftUI
import WidgetKit

private let appGroupId = "group.com.ookura.yonkumi"

struct DayEntry: TimelineEntry {
  let date: Date
  let title: String
  let status: String
  let done: Bool
  let streak: Int
}

private func readEntry(_ prefix: String, at date: Date) -> DayEntry {
  let d = UserDefaults(suiteName: appGroupId)
  return DayEntry(
    date: date,
    title: d?.string(forKey: "ookura_daily.\(prefix).title") ?? "今日の問題",
    status: d?.string(forKey: "ookura_daily.\(prefix).status") ?? "未解決",
    done: d?.string(forKey: "ookura_daily.\(prefix).done") == "1",
    streak: Int(d?.string(forKey: "ookura_daily.\(prefix).streak") ?? "") ?? 0
  )
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> DayEntry {
    DayEntry(date: Date(), title: "第1問", status: "未解決", done: false, streak: 0)
  }

  func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
    completion(currentEntries().first ?? placeholder(in: context))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
    completion(Timeline(entries: currentEntries(), policy: .atEnd))
  }

  private func currentEntries() -> [DayEntry] {
    let now = Date()
    let raw = UserDefaults(suiteName: appGroupId)?.string(forKey: "ookura_daily.switch_at")
    guard let ms = Double(raw ?? ""), ms > 0 else {
      return [readEntry("today", at: now)]
    }
    let switchAt = Date(timeIntervalSince1970: ms / 1000)
    if now >= switchAt {
      return [readEntry("tomorrow", at: now)]
    }
    return [readEntry("today", at: now), readEntry("tomorrow", at: switchAt)]
  }
}

struct YonkumiWidgetView: View {
  var entry: DayEntry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryInline:
      Text("\(entry.title) \(entry.status)")
    case .accessoryRectangular:
      VStack(alignment: .leading) {
        Text(entry.title).font(.headline)
        Text(entry.streak > 0 ? "\(entry.status)・連続\(entry.streak)日" : entry.status)
      }
    default:
      VStack(spacing: 4) {
        Text("ヨンクミ").font(.caption2).foregroundColor(.secondary)
        Text(entry.title).font(.title2).bold()
        Text(entry.status)
          .font(.subheadline)
          .foregroundColor(entry.done ? .secondary : Color(red: 0.61, green: 0.24, blue: 0.18))
        if entry.streak > 0 {
          Text("連続\(entry.streak)日").font(.caption).foregroundColor(.secondary)
        }
      }
    }
  }
}

@main
struct YonkumiWidget: Widget {
  let kind = "YonkumiWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        YonkumiWidgetView(entry: entry)
          .containerBackground(Color(red: 0.965, green: 0.945, blue: 0.906), for: .widget)
      } else {
        YonkumiWidgetView(entry: entry)
          .padding()
          .background(Color(red: 0.965, green: 0.945, blue: 0.906))
      }
    }
    .configurationDisplayName("今日のヨンクミ")
    .description("今日の問題の番号と、解いたかどうか、連続日数")
    .supportedFamilies([.systemSmall, .accessoryInline, .accessoryRectangular])
  }
}
