import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'smilesage_channel',
      'SmileSage Reminders',
      channelDescription: 'Reminders for daily tips and brushing',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final location = tz.getLocation('Africa/Maputo');
    final now = tz.TZDateTime.now(location);
    var firstTime = tz.TZDateTime(
        location, now.year, now.month, now.day, time.hour, time.minute);
    if (firstTime.isBefore(now)) {
      firstTime = firstTime.add(const Duration(days: 1));
    }
    print(
        'Scheduling notification (id: $id) for: $firstTime (firstTime.toLocal(): ${firstTime.toLocal()}) (local now: ${tz.TZDateTime.now(location)}) (firstTime location: ${firstTime.location})');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      firstTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleQuickTestNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'smilesage_channel',
      'SmileSage Reminders',
      channelDescription: 'Reminders for daily tips and brushing',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    final location = tz.getLocation('Africa/Maputo');
    final now = tz.TZDateTime.now(location);
    final testTime = now.add(const Duration(seconds: 10));
    print(
        'Scheduling quick test notification for: $testTime (local now: $now) (testTime location: ${testTime.location})');
    await flutterLocalNotificationsPlugin.zonedSchedule(
      123,
      'Quick Test',
      'This should appear in 10 seconds!',
      testTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: null,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
