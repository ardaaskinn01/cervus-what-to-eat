import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // Don't ask immediately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  Future<void> scheduleDailySuggestion(String name, String time) async {
    // Basic show for demonstration, would normally use TZDateTime for scheduling
    await showInstantNotification(
      'Yemek Vakti! 🍽️',
      'Merhaba $name! Bugün ne yemek istersin? Senin için harika önerilerim var.',
    );
  }

  Future<void> showInstantNotification(String title, String body) async {
    const androidDet = AndroidNotificationDetails(
      'whattoeat_channel', 
      'WhatToEat Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDet = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDet, iOS: iosDet);

    await _plugin.show(
      0, 
      title, 
      body, 
      details,
    );
  }
}
