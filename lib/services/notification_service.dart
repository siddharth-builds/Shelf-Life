import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter/foundation.dart'; 

class NotificationService {
  // Singleton instance instantiation
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'expiry_alerts_channel';
  static const String _channelName = 'Asset Expiration Alerts';
  static const String _channelDescription = 'Triggers notifications when item warranties or dates lapse.';

  /// Configures settings for Android/iOS and mounts the timezone map database
  Future<void> initialize() async {
    if (kIsWeb) return; 

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

   // Correct v18+ syntax: the parameter is named 'settings'
    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
    
    // Request Android 13+ Notification & Android 12+ Exact Alarm Permissions
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  /// System-level interactive runtime dialogue permission query
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false; // 2. Guard against web crash before platform checks evaluate

    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? grantedNotification = await androidImplementation?.requestNotificationsPermission();
      final bool? grantedExactAlarm = await androidImplementation?.requestExactAlarmsPermission();
      return (grantedNotification ?? false) && (grantedExactAlarm ?? false);
    } else if (Platform.isIOS) {
      final iOSImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final bool? granted = await iOSImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

 /// Registers an absolute, timezone-aware notification target on the OS queue
  Future<void> scheduleExpiryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return; 
    
    // 1. Explicitly grab your local timezone
    final location = tz.getLocation('Asia/Kolkata');

    // 2. Calculate 10 seconds from exactly NOW in your local time
    tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, location);
    tzScheduledDate = tz.TZDateTime(
      location, 
      tzScheduledDate.year, 
      tzScheduledDate.month, 
      tzScheduledDate.day, 
      10, 0, // 10 AM
    );

    // 3. CRITICAL: Android ignores alarms set in the past. Skip if the date already passed.
    if (tzScheduledDate.isBefore(tz.TZDateTime.now(location))) {
      return; 
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      // iOS: iOSDetails, (Add this back if you are using iOS)
    );

    // 3. Schedule the alarm using the corrected timezone
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
 /// Flushes a specific scheduled task from the system queue by its ID mapping
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return; 
    // v18+ Syntax: id is now a named parameter
    await _notificationsPlugin.cancel(id: id);
  }
}
