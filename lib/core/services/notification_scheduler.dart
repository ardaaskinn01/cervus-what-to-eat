import 'package:flutter/material.dart';
import '../../data/models/history_model.dart';
import 'notification_service.dart';

class NotificationScheduler {
  /// Analyzes the past usage times and schedules a daily notification
  static Future<void> scheduleSmartMealNotification(List<HistoryEntry> history, BuildContext context) async {
    if (history.isEmpty) {
      // Default time 12:30
      _scheduleDaily(12, 30);
      return;
    }

    // Try to find the most frequent eating/suggesting hour
    Map<int, int> hourCounts = {};
    for (var entry in history) {
      final h = entry.date.hour;
      hourCounts[h] = (hourCounts[h] ?? 0) + 1;
    }

    // Sort to find the most frequent hour
    var sorted = hourCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final bestHour = sorted.first.key;

    // Suppose we remind them 30 mins before their usual meal time
    int reminderHour = bestHour;
    int reminderMinute = 0;
    
    if (bestHour > 0) {
      reminderHour = bestHour - 1;
      reminderMinute = 30; // Remind half an hour early
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bildirimi kişiselleştirdik: ${reminderHour.toString().padLeft(2,'0')}:${reminderMinute.toString().padLeft(2,'0')}\'da hatırlatacağız 🔔')),
    );

    // Normally we use android_alarm_manager or timezone to schedule daily
    // For MVP, we will just send an instant notification test or setup a dummy schedule
    // NotificationService.instance.scheduleDaily(...)
    
    // Test for now
    NotificationService.instance.showInstantNotification(
      'Öğle vakti yaklaşıyor!',
      'Bugün ne yiyeceğine karar verdin mi? Hemen öneri al!',
    );
  }

  static void _scheduleDaily(int hour, int minute) {
    // Requires timezone package in flutter_local_notifications. Mocked for MVP.
  }
}
