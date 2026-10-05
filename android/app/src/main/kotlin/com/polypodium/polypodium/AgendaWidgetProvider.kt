package com.polypodium.polypodium

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONObject

/**
 * Home-screen widget with the agenda's tasks for today. The content is a
 * JSON snapshot computed and localized by the Dart side
 * (lib/features/agenda/data/home_widget_service.dart); this class only draws
 * it and, once the snapshot's day is over, asks Dart for a fresh one.
 */
class AgendaWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val snapshot = widgetData.getString(SNAPSHOT_KEY, null)?.let {
            try {
                JSONObject(it)
            } catch (e: Exception) {
                null
            }
        }
        if (snapshot != null) refreshIfStale(context, widgetData, snapshot)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, buildViews(context, snapshot))
        }
    }

    /** Asks Dart to recompute a snapshot left over from a previous day, once a day. */
    private fun refreshIfStale(context: Context, widgetData: SharedPreferences, snapshot: JSONObject) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        if (snapshot.optString("day") == today) return
        if (widgetData.getString(REFRESH_REQUESTED_KEY, null) == today) return
        widgetData.edit().putString(REFRESH_REQUESTED_KEY, today).apply()
        try {
            HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("polypodium://refresh")).send()
        } catch (e: PendingIntent.CanceledException) {
            // Next periodic update or app launch refreshes it.
        }
    }

    private fun buildViews(context: Context, snapshot: JSONObject?): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.agenda_widget)
        views.setOnClickPendingIntent(
            R.id.agenda_widget_root,
            launch(context, "polypodium://agenda"),
        )

        if (snapshot == null) {
            views.setViewVisibility(R.id.agenda_widget_empty, View.VISIBLE)
            return views
        }
        views.setTextViewText(R.id.agenda_widget_header, snapshot.optString("header"))

        val rows = snapshot.optJSONArray("rows")
        for ((index, ids) in ROW_IDS.withIndex()) {
            val row = rows?.optJSONObject(index)
            if (row == null) {
                views.setViewVisibility(ids.row, View.GONE)
                continue
            }
            val plantId = Uri.encode(row.optString("plantId"))
            views.setViewVisibility(ids.row, View.VISIBLE)
            views.setTextViewText(ids.emoji, row.optString("emoji"))
            views.setTextViewText(ids.name, row.optString("name"))
            views.setTextViewText(ids.status, row.optString("status"))
            views.setOnClickPendingIntent(ids.row, launch(context, "polypodium://plant?id=$plantId"))
            if (row.optBoolean("water")) {
                views.setViewVisibility(ids.water, View.VISIBLE)
                views.setOnClickPendingIntent(
                    ids.water,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("polypodium://water?id=$plantId"),
                    ),
                )
            } else {
                views.setViewVisibility(ids.water, View.GONE)
            }
        }

        val more = snapshot.optString("more")
        views.setTextViewText(R.id.agenda_widget_more, more)
        views.setViewVisibility(
            R.id.agenda_widget_more,
            if (more.isEmpty()) View.GONE else View.VISIBLE,
        )
        return views
    }

    private fun launch(context: Context, uri: String): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(uri))

    private data class RowIds(val row: Int, val emoji: Int, val name: Int, val status: Int, val water: Int)

    companion object {
        /** Written by PlatformHomeWidgetGateway in Dart. */
        private const val SNAPSHOT_KEY = "agenda_snapshot"
        private const val REFRESH_REQUESTED_KEY = "agenda_refresh_requested"

        private val ROW_IDS = listOf(
            RowIds(R.id.row_0, R.id.row_0_emoji, R.id.row_0_name, R.id.row_0_status, R.id.row_0_water),
            RowIds(R.id.row_1, R.id.row_1_emoji, R.id.row_1_name, R.id.row_1_status, R.id.row_1_water),
            RowIds(R.id.row_2, R.id.row_2_emoji, R.id.row_2_name, R.id.row_2_status, R.id.row_2_water),
            RowIds(R.id.row_3, R.id.row_3_emoji, R.id.row_3_name, R.id.row_3_status, R.id.row_3_water),
            RowIds(R.id.row_4, R.id.row_4_emoji, R.id.row_4_name, R.id.row_4_status, R.id.row_4_water),
        )
    }
}
