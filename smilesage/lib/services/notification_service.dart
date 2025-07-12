import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void Function(String?)? _onNotificationTap;
  bool _tzInitialized = false;

  void setOnNotificationTap(void Function(String?)? callback) {
    _onNotificationTap = callback;
  }

  /// Initialize notifications and permissions
  Future<void> init() async {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      _tzInitialized = true;
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (_onNotificationTap != null) {
          _onNotificationTap!(response.payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          (NotificationResponse response) async {},
    );
    // Request permissions
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
    if (Platform.isAndroid && await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Schedule a daily notification at a specific time in Africa/Maputo timezone
  Future<void> scheduleDailyNotification({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      _tzInitialized = true;
    }
    final location = tz.getLocation('Africa/Maputo');
    final now = tz.TZDateTime.now(location);
    var firstTime = tz.TZDateTime(
        location, now.year, now.month, now.day, time.hour, time.minute);
    if (firstTime.isBefore(now)) {
      firstTime = firstTime.add(const Duration(days: 1));
    }
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
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      firstTime,
      details,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancel a scheduled notification by id
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Schedule a quick test notification for 10 seconds from now
  Future<void> scheduleQuickTestNotification() async {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      _tzInitialized = true;
    }
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
    await flutterLocalNotificationsPlugin.zonedSchedule(
      123,
      'Quick Test',
      'This should appear in 10 seconds!',
      testTime,
      details,
      payload: null,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
