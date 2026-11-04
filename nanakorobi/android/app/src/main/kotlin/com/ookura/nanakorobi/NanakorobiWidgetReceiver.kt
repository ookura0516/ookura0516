package com.ookura.nanakorobi

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/**
 * ホーム画面ウィジェットの受け口。アプリ（home_widget）が updateWidget を呼ぶと、
 * ここ経由で [NanakorobiWidget] が描き直される。0 時の更新は home_widget の
 * scheduleWidgetUpdates（AlarmManager）で予約し、HomeWidgetScheduledUpdateReceiver が受ける。
 */
class NanakorobiWidgetReceiver : HomeWidgetGlanceWidgetReceiver<NanakorobiWidget>() {
    override val glanceAppWidget = NanakorobiWidget()
}
