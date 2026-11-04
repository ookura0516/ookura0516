# ウィジェットの実装手順（iOS WidgetKit・Android Glance）

Dart 側はできています。この環境では Xcode と Android Studio を動かせないので、ネイティブ側はここに手順と参考コードを残します。上から順に進めてください。

## 1. Dart 側がしていること

- 保存のたびに `DarumaActions.syncOutside()` が `WidgetSyncService.sync(WidgetSnapshot)` を呼ぶ（`lib/state/daruma_actions.dart`）
- `HomeWidgetSyncService`（`lib/services/widget_sync_service.dart`）が home_widget を使って、App Group `group.com.ookura.nanakorobi`（iOS）と `HomeWidgetPreferences`（Android）のキー `nanakorobi_snapshot` に次の JSON を書き、`NanakorobiWidget`（iOS）／`NanakorobiWidgetReceiver`（Android）の更新を要求する
- だるまがいないときは `nanakorobi_snapshot` を消す

```json
{
  "look": {
    "daruma_id": "…", "text": "合格", "color_id": 0, "seed": 123456,
    "strokes": 12, "gold_lines": 2, "first_eye": "left", "eyes": "one",
    "size_rank": 1, "fallen": false, "status": "active",
    "opened_on": "2027-01-01", "completed_on": null,
    "days_left": 15, "deadline_name": "共通テスト",
    "streak": 3, "recorded_today": true, "days_since_opened": 12
  },
  "name": "合格",
  "deadline_name": "共通テスト",
  "timeline": [
    {"date": "2027-01-01", "daysLeft": 15, "nextWaypointName": "模試", "nextWaypointDays": 4},
    {"date": "2027-01-02", "daysLeft": 14, "nextWaypointName": "模試", "nextWaypointDays": 3}
  ],
  "generated_at": "2027-01-01T20:00:00.000",
  "style": "paper"
}
```

- `timeline` は今日から14日分。各日の 0 時（端末のタイムゾーン）にその日のエントリへ切り替える。日数はアプリを開かなくても進む
- `look.recorded_today` は書いた時点の値。翌日以降のエントリでは「未記録」として薄い輪郭で描く
- ウィジェットからは記録しない。タップはアプリを開くだけ

## 2. iOS（WidgetKit）

1. Xcode で Runner に Widget Extension を追加する。名前 `NanakorobiWidget`、Bundle ID `com.ookura.nanakorobi.NanakorobiWidget`
2. Runner と NanakorobiWidget の両方で Signing & Capabilities → App Groups に `group.com.ookura.nanakorobi` を付ける
3. `ios/Runner/Info.plist` に home_widget のための `NSUserActivityTypes`（`INSendMessageIntent` 不要。ディープリンクを使うなら `CFBundleURLTypes` に `nanakorobi` スキーム）を足す
4. 下の Swift を `NanakorobiWidget/NanakorobiWidget.swift` に置く。家族は `.systemSmall`、`.systemMedium`、`.accessoryCircular`、`.accessoryRectangular`
5. `WidgetSnapshot` の JSON を `UserDefaults(suiteName: "group.com.ookura.nanakorobi")` の `nanakorobi_snapshot` から読む（home_widget はこのキー名のまま保存する）
6. Timeline は `timeline` の各日について「その日の 0 時」をエントリの日時にし、`.atEnd` で切り替える。14日目の末尾で再要求される
7. だるまの絵は SwiftUI の Path で簡略に描く（体の色、顔、目の状態、眉の本数 ≤7、ひげの本数 ≤14、台座の金の筋）。アプリと同じ `DarumaLook` から描くので、筆の数が合う
8. 複数のだるま（プラス）：初版は「設定 → ウィジェットに出すだるま」でアプリ側が選んだ1体を書く。AppIntent による設定は次版

```swift
import WidgetKit
import SwiftUI

struct Snapshot: Decodable {
    struct Look: Decodable {
        let text: String
        let colorId: Int
        let strokes: Int
        let goldLines: Int
        let eyes: String
        let fallen: Bool
        let recordedToday: Bool
        enum CodingKeys: String, CodingKey {
            case text, strokes, eyes, fallen
            case colorId = "color_id", goldLines = "gold_lines", recordedToday = "recorded_today"
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
    enum CodingKeys: String, CodingKey { case look, name, timeline, deadlineName = "deadline_name" }
}

struct Entry: TimelineEntry {
    let date: Date
    let snapshot: Snapshot?
    let day: Snapshot.Day?
}

struct Provider: TimelineProvider {
    static let groupId = "group.com.ookura.nanakorobi"
    static let key = "nanakorobi_snapshot"

    func load() -> Snapshot? {
        guard let json = UserDefaults(suiteName: Self.groupId)?.string(forKey: Self.key),
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }

    func placeholder(in context: Context) -> Entry { Entry(date: Date(), snapshot: nil, day: nil) }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let s = load()
        completion(Entry(date: Date(), snapshot: s, day: s?.timeline.first))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        guard let s = load() else {
            completion(Timeline(entries: [Entry(date: Date(), snapshot: nil, day: nil)], policy: .never))
            return
        }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        // 各日の 0 時（端末のタイムゾーン）で切り替える。最初のエントリは今。
        var entries: [Entry] = []
        for (i, day) in s.timeline.enumerated() {
            guard let midnight = f.date(from: day.date) else { continue }
            entries.append(Entry(date: i == 0 ? Date() : midnight, snapshot: s, day: day))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct NanakorobiWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: Entry

    var body: some View {
        if let s = entry.snapshot, let day = entry.day {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    if let d = day.daysLeft { Text("\(d)").font(.title2.bold()) } else { Text("筆\(s.look.strokes)") }
                }
            case .accessoryRectangular:
                VStack(alignment: .leading) {
                    Text(s.deadlineName ?? s.name).font(.headline)
                    if let d = day.daysLeft { Text("あと\(d)日").font(.title3.bold()) }
                }
            case .systemMedium:
                HStack {
                    DarumaShape(look: s.look, recorded: entry.date.timeIntervalSinceNow > -60 && s.look.recordedToday)
                        .frame(width: 96, height: 120)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.name).font(.headline)
                        if let d = day.daysLeft, let n = s.deadlineName { Text("\(n)まで あと\(d)日").font(.title3.bold()) }
                        if let w = day.nextWaypointName, let wd = day.nextWaypointDays { Text("次：\(w) あと\(wd)日").font(.caption) }
                        Text("\(s.look.strokes)筆・起き上がり\(s.look.goldLines)回").font(.caption)
                    }
                }
                .padding()
            default:
                VStack {
                    DarumaShape(look: s.look, recorded: s.look.recordedToday).frame(width: 80, height: 100)
                    if let d = day.daysLeft { Text("あと\(d)日").font(.caption.bold()) }
                }
                .padding()
            }
        } else {
            Text("だるまを作る").font(.caption)
        }
    }
}

/// アプリの DarumaPainter と同じ 100×125 の箱で描く簡略版。
struct DarumaShape: View {
    let look: Snapshot.Look
    let recorded: Bool

    static let colors: [Color] = [
        Color(red: 0.78, green: 0.24, blue: 0.18), Color(red: 0.96, green: 0.94, blue: 0.89), Color(red: 0.17, green: 0.16, blue: 0.18),
        Color(red: 0.91, green: 0.73, blue: 0.19), Color(red: 0.24, green: 0.55, blue: 0.35), Color(red: 0.18, green: 0.38, blue: 0.66),
        Color(red: 0.43, green: 0.29, blue: 0.62), Color(red: 0.90, green: 0.54, blue: 0.65), Color(red: 0.79, green: 0.64, blue: 0.15),
        Color(red: 0.88, green: 0.46, blue: 0.18), Color(red: 0.12, green: 0.16, blue: 0.36), Color(red: 0.48, green: 0.29, blue: 0.16),
    ]

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / 100, geo.size.height / 125)
            ZStack {
                // 台座と金の筋
                RoundedRectangle(cornerRadius: 4 * s).fill(Color(red: 0.23, green: 0.16, blue: 0.12))
                    .frame(width: 60 * s, height: 13 * s).offset(y: 52 * s)
                ForEach(0..<min(look.goldLines, 10), id: \.self) { i in
                    Rectangle().fill(Color(red: 0.79, green: 0.64, blue: 0.15)).frame(width: 1.2 * s, height: 8 * s)
                        .offset(x: (-28 + CGFloat(i + 1) * 56 / CGFloat(min(look.goldLines, 10) + 1)) * s, y: 52 * s)
                }
                // 体・顔・目
                Group {
                    Ellipse().fill(Self.colors[max(0, min(11, look.colorId))]).frame(width: 88 * s, height: 102 * s)
                    Ellipse().fill(Color(red: 0.96, green: 0.90, blue: 0.79)).frame(width: 52 * s, height: 55 * s).offset(y: -18 * s)
                    eye(x: -12, open: look.eyes == "both", s: s)
                    eye(x: 12, open: look.eyes != "none", s: s)
                    Text(look.text).font(.system(size: 11 * s, weight: .heavy)).foregroundColor(look.strokes >= 50 ? Color(red: 0.79, green: 0.64, blue: 0.15) : .black)
                        .offset(y: 26 * s)
                }
                .rotationEffect(.degrees(look.fallen ? 86 : 0))
                .opacity(recorded ? 1 : 0.55)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    func eye(x: CGFloat, open: Bool, s: CGFloat) -> some View {
        ZStack {
            Circle().fill(.white).frame(width: 14 * s, height: 14 * s)
            Circle().stroke(.black.opacity(open ? 1 : 0.3), lineWidth: s).frame(width: 14 * s, height: 14 * s)
            if open { Circle().fill(.black).frame(width: 10 * s, height: 10 * s) }
        }
        .offset(x: x * s, y: -20 * s)
    }
}

@main
struct NanakorobiWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NanakorobiWidget", provider: Provider()) { entry in
            NanakorobiWidgetView(entry: entry)
        }
        .configurationDisplayName("ナナコロビ")
        .description("だるまと残り日数")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
```

確認すること：

- [ ] 0 時をまたいで、アプリを開かずに残り日数が1減る（端末の時刻を進めて確認）
- [ ] 記録のある日とない日で、だるまの濃さが変わる
- [ ] ロック画面の円形と横長が出る（iOS 16 以降）
- [ ] だるまを納めたあと、「だるまを作る」の表示になる

## 3. Android（Glance）

1. `android/app/build.gradle.kts` に `androidx.glance:glance-appwidget:1.1.1` と `androidx.glance:glance-material3:1.1.1` を足す。`minSdk` は 24 以上
2. `android/app/src/main/AndroidManifest.xml` に receiver を足す。name は `com.ookura.nanakorobi.NanakorobiWidgetReceiver`（Dart 側の `androidQualifiedName` と一致させる）
3. `res/xml/nanakorobi_widget_info.xml` で `minWidth`/`minHeight`（小 2×2、中 4×2）、`updatePeriodMillis="0"`（更新はアプリと AlarmManager から）
4. home_widget は `HomeWidgetPreferences` という SharedPreferences にキー `nanakorobi_snapshot` で JSON を書く。`HomeWidgetGlanceStateDefinition` でそのまま読める
5. 0 時更新：`AlarmManager.setAndAllowWhileIdle` で次の 0 時（端末のタイムゾーン）に受信して `updateAll` する。Doze で遅れても狂わないよう、表示は「現在時刻の日付」に対応する `timeline` のエントリを選ぶ（前日分の JSON のままでも日付で正しい行を取れる）
6. 端末の再起動で Alarm が消えるので、`BOOT_COMPLETED` の receiver で再登録する

```kotlin
package com.ookura.nanakorobi

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.layout.Column
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import org.json.JSONObject
import java.time.LocalDate

class NanakorobiWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = NanakorobiWidget()
}

class NanakorobiWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val prefs = currentState<HomeWidgetGlanceState>().preferences
            val json = prefs.getString("nanakorobi_snapshot", null)
            Content(json)
        }
    }

    @Composable
    private fun Content(json: String?) {
        if (json == null) {
            Text("だるまを作る")
            return
        }
        val root = JSONObject(json)
        val look = root.getJSONObject("look")
        val name = root.getString("name")
        val deadlineName = root.optString("deadline_name", "")
        // 今日の日付に合う行を選ぶ（前日分の JSON のままでも狂わない）
        val today = LocalDate.now().toString()
        val timeline = root.getJSONArray("timeline")
        var daysLeft: Int? = null
        for (i in 0 until timeline.length()) {
            val day = timeline.getJSONObject(i)
            if (day.getString("date") == today && !day.isNull("daysLeft")) daysLeft = day.getInt("daysLeft")
        }
        Column(modifier = GlanceModifier.padding(12.dp)) {
            // だるまは Canvas 相当がないので、初版は色付きの丸と文字で簡略表示。
            Text(look.getString("text"), style = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold))
            Text(name)
            if (daysLeft != null) Text("${deadlineName}まで あと${daysLeft}日", style = TextStyle(fontWeight = FontWeight.Bold))
            Text("${look.getInt("strokes")}筆・起き上がり${look.getInt("gold_lines")}回")
            if (look.getBoolean("fallen")) Text("転んでいます")
        }
    }
}
```

0 時の更新（`MidnightReceiver`）：

```kotlin
class MidnightReceiver : android.content.BroadcastReceiver() {
    override fun onReceive(context: Context, intent: android.content.Intent) {
        kotlinx.coroutines.runBlocking { NanakorobiWidget().updateAll(context) }
        schedule(context)
    }

    companion object {
        fun schedule(context: Context) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            val next = java.time.LocalDate.now().plusDays(1).atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
            val pi = android.app.PendingIntent.getBroadcast(
                context, 0, android.content.Intent(context, MidnightReceiver::class.java),
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
            )
            am.setAndAllowWhileIdle(android.app.AlarmManager.RTC, next + 1000, pi)
        }
    }
}
```

確認すること：

- [ ] アプリで記録すると、数秒以内にウィジェットの筆の数が増える
- [ ] 0 時をまたいで残り日数が減る。Doze 中でも、次に画面を見たとき日付が合っている
- [ ] 再起動後も 0 時の更新が続く
- [ ] だるまがいないとき「だるまを作る」になる

## 4. ウィジェットから記録しない理由

記録はアプリ内だけで行う。「ウィジェットで便利になりすぎて開かれないアプリ」を避け、評価依頼（7日目と両目の直後）と購入導線（2体目、7日目の共有、両目の直後）の機会を残すため。ウィジェットのタップはアプリを開くだけにする。
