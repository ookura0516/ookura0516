// ナナコロビのホーム画面・ロック画面ウィジェット（WidgetKit）。
//
// Flutter 側（lib/services/widget_sync.dart）が App Group の UserDefaults に書いた
// だるまの絵（通常・転倒）と日付の元データから、残り日数と転倒を「その日の日付」で計算する。
// Timeline に今後 14 日分の 0 時のエントリを前もって入れるので、アプリを開かなくても日数が進む。
// ターゲットは tool/add_ios_widget_target.py が足す（docs/WIDGET_SETUP.md）。
import SwiftUI
import WidgetKit

private let appGroup = "group.com.ookura.nanakorobi"

struct DarumaEntry: TimelineEntry {
  let date: Date
  let has: Bool
  let name: String
  let label: String
  /// 本番までの日数。本番の日がなければ nil。0 は今日が本番。負は過ぎた日数。
  let daysLeft: Int?
  let dayNumber: Int
  let fallen: Bool
  let doneToday: Bool
  let image: UIImage?
}

/// 文言。端末の言語が日本語でなければ英語。
private enum L {
  static let ja = (Locale.preferredLanguages.first ?? "ja").hasPrefix("ja")
  static func daysLeft(_ n: Int) -> String { ja ? "あと\(n)日" : "\(n) days left" }
  static var today: String { ja ? "今日が本番" : "Today is the day" }
  static func daysPassed(_ n: Int) -> String { ja ? "\(n)日 過ぎました" : "\(n) days ago" }
  static func dayN(_ n: Int) -> String { ja ? "開眼から\(n)日目" : "Day \(n)" }
  static var done: String { ja ? "今日の一歩 済" : "Done today" }
  static var empty: String { ja ? "だるまを作る" : "Make a daruma" }
  static var defaultLabel: String { ja ? "本番" : "The big day" }
  static var description: String { ja ? "だるまと、本番までの残り日数" : "Your daruma and the days left" }
  static var daysUnit: String { ja ? "日" : "days" }
}

/// 端末のローカル日付の epoch day（Flutter 側の LocalDate.epochDay と同じ数）。
private func epochDay(_ date: Date) -> Int {
  let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
  var utc = Calendar(identifier: .gregorian)
  utc.timeZone = TimeZone(identifier: "UTC")!
  let utcDate = utc.date(from: comps) ?? date
  return Int(floor(utcDate.timeIntervalSince1970 / 86_400))
}

struct DarumaProvider: TimelineProvider {
  func placeholder(in context: Context) -> DarumaEntry {
    DarumaEntry(date: Date(), has: true, name: "合格", label: "共通テスト", daysLeft: 73, dayNumber: 12,
                fallen: false, doneToday: false, image: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (DarumaEntry) -> Void) {
    completion(entry(for: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<DarumaEntry>) -> Void) {
    var entries = [entry(for: Date())]
    let cal = Calendar.current
    let startOfToday = cal.startOfDay(for: Date())
    for i in 1...14 {
      if let midnight = cal.date(byAdding: .day, value: i, to: startOfToday) {
        entries.append(entry(for: midnight.addingTimeInterval(1)))
      }
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }

  /// キーは lib/services/widget_sync.dart と同じ。
  func entry(for date: Date) -> DarumaEntry {
    let d = UserDefaults(suiteName: appGroup)
    let has = d?.bool(forKey: "nk_has") ?? false
    let today = epochDay(date)
    let deadline = d?.object(forKey: "nk_deadline") as? Int ?? -1
    let created = d?.object(forKey: "nk_created") as? Int ?? today
    let lastStep = d?.object(forKey: "nk_last_step") as? Int ?? -1
    let anchor = lastStep >= 0 ? lastStep : created
    // 最後に記録した日（なければ開眼日）が昨日より前なら転倒（lib/core/rules.dart と同じ）。
    let fallen = today - anchor > 1
    let path = d?.string(forKey: fallen ? "nk_img_fallen" : "nk_img_up")
    let image = path.flatMap { UIImage(contentsOfFile: $0) }
    return DarumaEntry(
      date: date,
      has: has,
      name: d?.string(forKey: "nk_name") ?? "",
      label: d?.string(forKey: "nk_label") ?? "",
      daysLeft: deadline >= 0 ? deadline - today : nil,
      dayNumber: today - created + 1,
      fallen: fallen,
      doneToday: lastStep == today,
      image: image
    )
  }
}

private let paper = Color(red: 0.953, green: 0.925, blue: 0.875)
private let ink = Color(red: 0.165, green: 0.133, blue: 0.110)
private let inkDim = Color(red: 0.420, green: 0.353, blue: 0.290)
private let red = Color(red: 0.765, green: 0.149, blue: 0.165)

private func daysText(_ e: DarumaEntry) -> String {
  guard let left = e.daysLeft else { return e.name }
  if left > 0 { return L.daysLeft(left) }
  if left == 0 { return L.today }
  return L.daysPassed(-left)
}

private func subText(_ e: DarumaEntry) -> String {
  if e.daysLeft != nil {
    return e.label.isEmpty ? L.defaultLabel : e.label
  }
  return L.dayN(e.dayNumber)
}

struct NanakorobiWidgetView: View {
  @Environment(\.widgetFamily) var family
  let entry: DarumaEntry

  var body: some View {
    switch family {
    case .accessoryCircular:
      ZStack {
        AccessoryWidgetBackground()
        VStack(spacing: 0) {
          if let left = entry.daysLeft {
            Text("\(left)").font(.system(size: 22, weight: .bold))
            Text(L.daysUnit).font(.system(size: 9))
          } else {
            Text(entry.name).font(.system(size: 14, weight: .bold)).minimumScaleFactor(0.6)
          }
        }
      }
    case .accessoryRectangular:
      HStack(spacing: 6) {
        VStack(alignment: .leading, spacing: 2) {
          Text(subText(entry)).font(.caption)
          Text(daysText(entry)).font(.headline)
          if entry.doneToday { Text(L.done).font(.caption2) }
        }
        Spacer(minLength: 0)
      }
    default:
      homeView
    }
  }

  private var homeView: some View {
    Group {
      if !entry.has {
        VStack(spacing: 6) {
          Text(L.empty).font(.headline).foregroundStyle(ink)
          Text("ナナコロビ").font(.caption).foregroundStyle(inkDim)
        }
      } else if family == .systemMedium {
        HStack(spacing: 8) {
          darumaImage
          VStack(alignment: .leading, spacing: 4) {
            Text(subText(entry)).font(.caption).foregroundStyle(inkDim)
            Text(daysText(entry)).font(.title2.bold()).foregroundStyle(ink).minimumScaleFactor(0.6)
            if entry.doneToday {
              Text(L.done).font(.caption2).foregroundStyle(red)
            }
          }
          Spacer(minLength: 0)
        }
      } else {
        VStack(spacing: 2) {
          darumaImage
          Text(daysText(entry)).font(.headline).foregroundStyle(ink).minimumScaleFactor(0.6).lineLimit(1)
          Text(subText(entry)).font(.caption2).foregroundStyle(inkDim).lineLimit(1)
          if entry.doneToday {
            Text(L.done).font(.caption2).foregroundStyle(red)
          }
        }
      }
    }
    .padding(8)
    .containerBackground(for: .widget) { paper }
  }

  private var darumaImage: some View {
    Group {
      if let image = entry.image {
        Image(uiImage: image).resizable().scaledToFit()
      } else {
        Color.clear
      }
    }
  }
}

struct NanakorobiWidget: Widget {
  /// Flutter 側の HomeWidget.updateWidget(iOSName:) と同じ名前。
  let kind = "NanakorobiWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DarumaProvider()) { entry in
      NanakorobiWidgetView(entry: entry)
    }
    .configurationDisplayName("ナナコロビ")
    .description(L.description)
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
  }
}

@main
struct NanakorobiWidgetBundle: WidgetBundle {
  var body: some Widget {
    NanakorobiWidget()
  }
}
