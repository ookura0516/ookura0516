// ナナコロビのウィジェット（WidgetKit）。小・中・ロック画面（円形・横長）。
//
// アプリ（home_widget）が App Group の UserDefaults に書く JSON（キー nanakorobi_snapshot）を読み、
// 14日分のタイムラインを各日の 0 時（端末のタイムゾーン）で切り替える。記録はしない。タップはアプリを開くだけ。
// Xcode での組み込み手順は docs/WIDGETS.md。

import SwiftUI
import WidgetKit

// MARK: - JSON

struct Snapshot: Decodable {
    struct Look: Decodable {
        let text: String
        let colorId: Int
        let seed: Int
        let strokes: Int
        let goldLines: Int
        let eyes: String
        let firstEye: String
        let fallen: Bool
        let recordedToday: Bool

        enum CodingKeys: String, CodingKey {
            case text, seed, strokes, eyes, fallen
            case colorId = "color_id"
            case goldLines = "gold_lines"
            case firstEye = "first_eye"
            case recordedToday = "recorded_today"
        }
    }

    struct Day: Decodable {
        let date: String
        let daysLeft: Int?
        let nextWaypointName: String?
        let nextWaypointDays: Int?
    }

    let look: Look
    let name: String
    let deadlineName: String?
    let timeline: [Day]

    enum CodingKeys: String, CodingKey {
        case look, name, timeline
        case deadlineName = "deadline_name"
    }
}

// MARK: - Timeline

struct Entry: TimelineEntry {
    let date: Date
    let snapshot: Snapshot?
    let day: Snapshot.Day?

    /// その日の記録があるか。アプリが書いた時点の今日だけ分かる。翌日以降は未記録として薄く描く。
    let recorded: Bool
}

struct Provider: TimelineProvider {
    static let groupId = "group.com.ookura.nanakorobi"
    static let key = "nanakorobi_snapshot"

    func load() -> Snapshot? {
        guard let json = UserDefaults(suiteName: Self.groupId)?.string(forKey: Self.key),
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), snapshot: nil, day: nil, recorded: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let s = load()
        completion(Entry(date: Date(), snapshot: s, day: s?.timeline.first, recorded: s?.look.recordedToday ?? false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        guard let s = load() else {
            completion(Timeline(entries: [Entry(date: Date(), snapshot: nil, day: nil, recorded: false)], policy: .never))
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")

        var entries: [Entry] = []
        for (i, day) in s.timeline.enumerated() {
            guard let midnight = formatter.date(from: day.date) else { continue }
            // 最初のエントリは今。以降は各日の 0 時で切り替える。
            let at = i == 0 ? Date() : midnight
            if i > 0 && at < Date() { continue }
            entries.append(Entry(date: at, snapshot: s, day: day, recorded: i == 0 && s.look.recordedToday))
        }
        if entries.isEmpty {
            entries.append(Entry(date: Date(), snapshot: s, day: s.timeline.last, recorded: false))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Views

struct NanakorobiWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: Entry

    var body: some View {
        Group {
            if let s = entry.snapshot, let day = entry.day {
                content(s, day)
            } else {
                Text("だるまを作る").font(.caption).foregroundColor(.secondary)
            }
        }
        .widgetURL(URL(string: "nanakorobi://home"))
    }

    @ViewBuilder
    private func content(_ s: Snapshot, _ day: Snapshot.Day) -> some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                if #available(iOSApplicationExtension 16.0, *) { AccessoryWidgetBackground() }
                if let d = day.daysLeft {
                    VStack(spacing: 0) {
                        Text("\(d)").font(.title2.bold()).minimumScaleFactor(0.6)
                        Text("日").font(.caption2)
                    }
                } else {
                    Text("\(s.look.strokes)筆").font(.caption.bold())
                }
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(s.deadlineName ?? s.name).font(.headline).lineLimit(1)
                if let d = day.daysLeft {
                    Text("あと\(d)日").font(.title3.bold())
                } else {
                    Text("\(s.look.strokes)筆・起き上がり\(s.look.goldLines)回").font(.caption)
                }
            }
        case .systemMedium:
            HStack(spacing: 12) {
                DarumaShape(look: s.look, recorded: entry.recorded)
                    .frame(width: 92, height: 115)
                VStack(alignment: .leading, spacing: 4) {
                    Text(s.name).font(.headline)
                    if let d = day.daysLeft, let n = s.deadlineName {
                        Text("\(n)まで あと\(d)日").font(.title3.bold()).minimumScaleFactor(0.7)
                    }
                    if let w = day.nextWaypointName, let wd = day.nextWaypointDays {
                        Text("次：\(w) あと\(wd)日").font(.caption).foregroundColor(.secondary)
                    }
                    Text("\(s.look.strokes)筆・起き上がり\(s.look.goldLines)回").font(.caption)
                    if s.look.fallen {
                        Text("転んでいます").font(.caption2).foregroundColor(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
        default:
            VStack(spacing: 4) {
                DarumaShape(look: s.look, recorded: entry.recorded)
                    .frame(width: 72, height: 90)
                if let d = day.daysLeft {
                    Text("あと\(d)日").font(.caption.bold())
                } else {
                    Text("\(s.look.strokes)筆").font(.caption.bold())
                }
            }
            .padding(8)
        }
    }
}

/// アプリの DarumaPainter と同じ 100×125 の箱で描く簡略版（体・顔・目・眉とひげの本数・腹の文字・台座の金の筋）。
struct DarumaShape: View {
    let look: Snapshot.Look
    let recorded: Bool

    static let bodies: [Color] = [
        Color(red: 0.78, green: 0.24, blue: 0.18), Color(red: 0.96, green: 0.94, blue: 0.89), Color(red: 0.17, green: 0.16, blue: 0.18),
        Color(red: 0.91, green: 0.73, blue: 0.19), Color(red: 0.24, green: 0.55, blue: 0.35), Color(red: 0.18, green: 0.38, blue: 0.66),
        Color(red: 0.43, green: 0.29, blue: 0.62), Color(red: 0.90, green: 0.54, blue: 0.65), Color(red: 0.79, green: 0.64, blue: 0.15),
        Color(red: 0.88, green: 0.46, blue: 0.18), Color(red: 0.12, green: 0.16, blue: 0.36), Color(red: 0.48, green: 0.29, blue: 0.16),
    ]
    static let gold = Color(red: 0.79, green: 0.64, blue: 0.15)
    static let ink = Color(red: 0.11, green: 0.10, blue: 0.12)
    static let lightIds: Set<Int> = [1, 3, 7, 8]

    var body: some View {
        Canvas { context, size in
            let s = min(size.width / 100, size.height / 125)
            let dx = (size.width - 100 * s) / 2
            let dy = (size.height - 125 * s) / 2
            context.translateBy(x: dx, y: dy)
            context.scaleBy(x: s, y: s)

            // 台座と金の筋（転ぶほど金になる）
            let base = Path(roundedRect: CGRect(x: 20, y: 108, width: 60, height: 13), cornerRadius: 4)
            context.fill(base, with: .color(Color(red: 0.23, green: 0.16, blue: 0.12)))
            let lines = min(look.goldLines, 10)
            if lines > 0 {
                let gap = 56.0 / Double(lines + 1)
                for i in 0..<lines {
                    var p = Path()
                    let x = 22 + gap * Double(i + 1)
                    p.move(to: CGPoint(x: x, y: 112))
                    p.addLine(to: CGPoint(x: x, y: 119.5))
                    context.stroke(p, with: .color(Self.gold), lineWidth: 1.1)
                }
            }

            var body = context
            if look.fallen {
                body.translateBy(x: 50, y: 57)
                body.rotate(by: .degrees(look.firstEye == "left" ? 86 : -86))
                body.translateBy(x: -50, y: -57)
            }
            body.opacity = recorded ? 1 : 0.6

            let colorId = max(0, min(11, look.colorId))
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: 50, y: 6))
            bodyPath.addCurve(to: CGPoint(x: 94, y: 66), control1: CGPoint(x: 78, y: 6), control2: CGPoint(x: 94, y: 36))
            bodyPath.addCurve(to: CGPoint(x: 72, y: 108), control1: CGPoint(x: 94, y: 86), control2: CGPoint(x: 86, y: 104))
            bodyPath.addLine(to: CGPoint(x: 28, y: 108))
            bodyPath.addCurve(to: CGPoint(x: 6, y: 66), control1: CGPoint(x: 14, y: 104), control2: CGPoint(x: 6, y: 86))
            bodyPath.addCurve(to: CGPoint(x: 50, y: 6), control1: CGPoint(x: 6, y: 36), control2: CGPoint(x: 22, y: 6))
            bodyPath.closeSubpath()
            body.fill(bodyPath, with: .color(Self.bodies[colorId]))
            if look.strokes >= 100 {
                body.stroke(bodyPath, with: .color(Self.gold), lineWidth: 2.2)
            }

            var face = Path()
            face.move(to: CGPoint(x: 50, y: 17))
            face.addCurve(to: CGPoint(x: 76, y: 44), control1: CGPoint(x: 68, y: 17), control2: CGPoint(x: 76, y: 30))
            face.addCurve(to: CGPoint(x: 50, y: 72), control1: CGPoint(x: 76, y: 60), control2: CGPoint(x: 66, y: 70))
            face.addCurve(to: CGPoint(x: 24, y: 44), control1: CGPoint(x: 34, y: 70), control2: CGPoint(x: 24, y: 60))
            face.addCurve(to: CGPoint(x: 50, y: 17), control1: CGPoint(x: 24, y: 30), control2: CGPoint(x: 32, y: 17))
            face.closeSubpath()
            body.fill(face, with: .color(Color(red: 0.96, green: 0.90, blue: 0.79)))

            // 目：left はだるまの左目＝向かって右（x=62）
            for (side, x) in [("left", 62.0), ("right", 38.0)] {
                let open = look.eyes == "both" || (look.eyes == "one" && look.firstEye == side)
                let c = CGPoint(x: x, y: 42)
                body.fill(Path(ellipseIn: CGRect(x: c.x - 7.2, y: c.y - 7.2, width: 14.4, height: 14.4)), with: .color(.white))
                body.stroke(Path(ellipseIn: CGRect(x: c.x - 7.2, y: c.y - 7.2, width: 14.4, height: 14.4)),
                            with: .color(Self.ink.opacity(open ? 1 : 0.35)), lineWidth: open ? 1.3 : 0.9)
                if open {
                    body.fill(Path(ellipseIn: CGRect(x: c.x - 5, y: c.y - 5, width: 10, height: 10)), with: .color(Self.ink))
                }
            }

            // 眉（最大7筆）とひげ（最大14筆）。本数だけ合わせる。
            let brows = min(look.strokes, 7)
            for i in 0..<brows {
                var p = Path()
                if i < 2 {
                    let m = i == 0 ? -1.0 : 1.0
                    p.move(to: CGPoint(x: 50 + m * 8, y: 34))
                    p.addCurve(to: CGPoint(x: 50 + m * 29, y: 33), control1: CGPoint(x: 50 + m * 16, y: 28), control2: CGPoint(x: 50 + m * 24, y: 28))
                    body.stroke(p, with: .color(Self.ink), lineWidth: 2.6)
                } else {
                    let k = i - 2
                    let m = k % 2 == 0 ? -1.0 : 1.0
                    let n = Double(k / 2)
                    let x = 50 + m * (13 + n * 5.5)
                    let y = 30.5 - n * 0.6
                    p.move(to: CGPoint(x: x, y: y))
                    p.addQuadCurve(to: CGPoint(x: x + m * 5.5, y: y - 5.5), control: CGPoint(x: x + m * 2.5, y: y - 3.5))
                    body.stroke(p, with: .color(Self.ink), lineWidth: 1.8)
                }
            }
            let beard = max(0, min(look.strokes - 7, 14))
            for i in 0..<beard {
                let m = i % 2 == 0 ? -1.0 : 1.0
                let n = Double(i / 2)
                var p = Path()
                let sx = 50 + m * (7 + n * 0.9), sy = 50 + n * 2.4
                p.move(to: CGPoint(x: sx, y: sy))
                p.addQuadCurve(to: CGPoint(x: 50 + m * (15 + n * 2.4), y: 55 + n * 3.0), control: CGPoint(x: sx + m * 6, y: sy - 1.5))
                body.stroke(p, with: .color(Self.ink), lineWidth: 1.8)
            }

            // 鼻と口
            var nose = Path()
            nose.move(to: CGPoint(x: 50, y: 48))
            nose.addQuadCurve(to: CGPoint(x: 50, y: 55), control: CGPoint(x: 51.5, y: 52))
            body.stroke(nose, with: .color(Self.ink), lineWidth: 1.4)
            var mouth = Path()
            mouth.move(to: CGPoint(x: 45.5, y: 60))
            mouth.addQuadCurve(to: CGPoint(x: 54.5, y: 60), control: CGPoint(x: 50, y: 62.5))
            body.stroke(mouth, with: .color(Self.ink), lineWidth: 1.5)

            // 腹の文字（縦書き）。50筆で金。明るい体は濃い金。
            let chars = Array(look.text)
            if !chars.isEmpty {
                let fontSize: Double = chars.count <= 2 ? 13 : (chars.count == 3 ? 10.5 : (chars.count == 4 ? 8.5 : 7))
                let lineHeight = fontSize * 1.05
                let total = lineHeight * Double(chars.count)
                var y = 88 - total / 2
                let textColor: Color = look.strokes >= 50
                    ? (Self.lightIds.contains(colorId) ? Color(red: 0.60, green: 0.48, blue: 0.08) : Self.gold)
                    : (Self.lightIds.contains(colorId) ? Self.ink : Color(red: 0.97, green: 0.94, blue: 0.87))
                for ch in chars {
                    let text = Text(String(ch)).font(.system(size: fontSize, weight: .heavy)).foregroundColor(textColor)
                    body.draw(text, at: CGPoint(x: 50, y: y + lineHeight / 2), anchor: .center)
                    y += lineHeight
                }
            }
            if look.strokes > 21 {
                let ring = Path(ellipseIn: CGRect(x: 33, y: 68, width: 34, height: 40))
                let count = min(look.strokes - 21, 29)
                let dash = ring.trimmedPath(from: 0, to: CGFloat(count) / 29)
                let ringColor = look.strokes >= 50 ? Self.gold : (Self.lightIds.contains(colorId) ? Self.ink : Color(red: 0.95, green: 0.91, blue: 0.82))
                body.stroke(dash, with: .color(ringColor), style: StrokeStyle(lineWidth: 1.5, dash: [3.4, 1.6]))
            }
        }
    }
}

// MARK: - Widget

struct NanakorobiWidget: Widget {
    var families: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular]
        }
        return [.systemSmall, .systemMedium]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NanakorobiWidget", provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                NanakorobiWidgetView(entry: entry)
                    .containerBackground(for: .widget) { Color(red: 0.97, green: 0.95, blue: 0.90) }
            } else {
                NanakorobiWidgetView(entry: entry)
                    .background(Color(red: 0.97, green: 0.95, blue: 0.90))
            }
        }
        .configurationDisplayName("ナナコロビ")
        .description("だるまと、本番までの残り日数")
        .supportedFamilies(families)
    }
}

@main
struct NanakorobiWidgetBundle: WidgetBundle {
    var body: some Widget {
        NanakorobiWidget()
    }
}
