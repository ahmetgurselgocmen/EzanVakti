import 'dart:ui';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../services/prayer_time_service.dart';
import '../services/time_service.dart';
import '../main.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Notification ID reserved for persistent countdown
  static const int _persistentNotifId = 0;

  /// SharedPreferences key for persistent notification toggle
  static const String persistentNotifKey = 'persistent_notification';

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for ezan alerts with custom sound
    const ezanChannel = AndroidNotificationChannel(
      'ezan_sound_channel_v1',
      'Ezan Vakitleri (Sesli)',
      description: 'Namaz vakitlerinde sesli ezan bildirimi',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
    );

    // Create notification channel for persistent countdown
    const countdownChannel = AndroidNotificationChannel(
      'ezan_countdown_channel',
      'Vakit Sayacı',
      description: 'Bildirim çubuğunda sabit namaz vakitleri gösterimi',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(ezanChannel);
    await androidPlugin?.createNotificationChannel(countdownChannel);

    try {
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      // Ignore permission errors if already in progress
    }

    _initialized = true;
  }

  static void _onNotificationTapped(
      NotificationResponse notificationResponse) {
    // Handle notification tap - can navigate to specific screen
  }

  /// Check if persistent notification is enabled
  static Future<bool> isPersistentNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(persistentNotifKey) ?? true; // Default ON
  }

  /// Set persistent notification enabled/disabled
  static Future<void> setPersistentNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(persistentNotifKey, enabled);
    if (!enabled) {
      await cancelPersistentNotification();
    }
  }

  /// Schedule notifications for all prayer times
  static Future<void> schedulePrayerNotifications({
    required List<PrayerTimeInfo> prayerTimes,
    required Map<PrayerType, bool> notificationSettings,
  }) async {
    // Cancel scheduled notifications but preserve persistent notification
    await _cancelScheduledNotifications();

    for (int i = 0; i < prayerTimes.length; i++) {
      final prayer = prayerTimes[i];

      // Skip if notification is disabled for this prayer
      if (notificationSettings[prayer.type] == false) continue;

      // Skip sunrise - no ezan for sunrise
      if (prayer.type == PrayerType.sunrise) continue;

      // Skip if time has already passed
      if (prayer.time.isBefore(TimeService.now())) continue;

      await _scheduleNotification(
        id: i + 10, // Offset to avoid conflict with persistent (0)
        title: '🕌 ${prayer.type.turkishName} Vakti',
        body: '${prayer.type.turkishName} vakti girdi - ${prayer.formattedTime}',
        scheduledTime: prayer.time,
      );
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(TimeService.toDeviceTime(scheduledTime), tz.local);

    const androidDetails = AndroidNotificationDetails(
      'ezan_sound_channel_v1',
      'Ezan Vakitleri (Sesli)',
      channelDescription: 'Namaz vakitlerinde sesli ezan bildirimi',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan.mp3',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null, // One-time notification
    );
  }

  /// Cancel only scheduled notifications (preserve persistent)
  static Future<void> _cancelScheduledNotifications() async {
    // Cancel IDs 10-15 (scheduled prayer notifications)
    for (int i = 10; i <= 15; i++) {
      await _notifications.cancel(i);
    }
    // Also cancel test notification
    await _notifications.cancel(99);
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel only the persistent notification
  static Future<void> cancelPersistentNotification() async {
    if (Platform.isAndroid) {
      const platform = MethodChannel('com.ezanvakti.ezan_vakti/notification');
      try {
        await platform.invokeMethod('cancelCustomNotification');
      } catch (e) {
        // ignore
      }
    }
    await _notifications.cancel(_persistentNotifId);
  }

  /// Update persistent countdown notification with rich prayer time info
  static Future<void> updateCountdownNotification({
    required DateTime targetTime,
    required String prayerName,
    List<PrayerTimeInfo>? allPrayerTimes,
  }) async {
    // Check if persistent notification is enabled
    final enabled = await isPersistentNotificationEnabled();
    if (!enabled) return;

    // Build rich expanded view with all prayer times
    InboxStyleInformation? inboxStyle;
    if (allPrayerTimes != null) {
      final now = TimeService.now();
      final lines = <String>[];

      for (final p in allPrayerTimes) {
        if (p.type == PrayerType.sunrise) continue; // Skip sunrise

        final isPast = p.time.isBefore(now);
        final isNext = p.isNext;

        String prefix;
        if (isNext) {
          prefix = '► ';
        } else if (isPast) {
          prefix = '✓ ';
        } else {
          prefix = '    ';
        }

        final line = '$prefix${p.type.turkishName.padRight(12)} ${p.formattedTime}';
        lines.add(line);
      }

      inboxStyle = InboxStyleInformation(
        lines,
        contentTitle: '🕌 Günün Namaz Vakitleri',
        summaryText: '► Sonraki: $prayerName',
      );
    }

    if (Platform.isAndroid) {
      const platform = MethodChannel('com.ezanvakti.ezan_vakti/notification');
      try {
        await platform.invokeMethod('showCustomNotification', {
          'title': 'Ezan Vakti',
          'nextPrayer': 'Sıradaki Vakit: $prayerName',
          'targetTimeMillis': TimeService.toDeviceTime(targetTime).millisecondsSinceEpoch,
          'themeIndex': appSettings.themeIndex,
        });
      } catch (e) {
        // Fallback or ignore
      }
    } else {
      const iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      final details = NotificationDetails(iOS: iosDetails);

      await _notifications.show(
        _persistentNotifId,
        '🕌 $prayerName  ·  ${_formatTimeFromDateTime(targetTime)}',
        'Sonraki vakte geri sayım...',
        details,
      );
    }
  }

  /// Format DateTime to HH:mm string
  static String _formatTimeFromDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Send a test notification immediately
  static Future<void> sendTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'ezan_sound_channel_v1',
      'Ezan Vakitleri (Sesli)',
      channelDescription: 'Namaz vakitlerinde sesli ezan bildirimi',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      99,
      '🕌 Ezan Vakti',
      'Bildirimler aktif!',
      notificationDetails,
    );
  }

  /// Cancel all scheduled adhan notifications (removes active sound)
  static Future<void> cancelAdhanNotification() async {
    for (int i = 10; i < 16; i++) {
      try {
        await _notifications.cancel(i);
      } catch (_) {}
    }
  }
}
