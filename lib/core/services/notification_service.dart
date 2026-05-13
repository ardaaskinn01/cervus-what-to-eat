import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
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
