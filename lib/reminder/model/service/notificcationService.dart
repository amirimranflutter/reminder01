// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reminder/reminder/model/remiderModel.dart';

import 'package:timezone/timezone.dart' as tz;

import 'package:timezone/data/latest.dart' as tz;


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // static Future<void> initialize() async {
  //   tz.initializeTimeZones();
  //
  //   const AndroidInitializationSettings androidSettings =
  //   AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  //   const DarwinInitializationSettings iosSettings =
  //   DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //   );
  //
  //   const InitializationSettings settings = InitializationSettings(
  //     android: androidSettings,
  //     iOS: iosSettings,
  //   );
  //
  //   await _notifications.initialize(settings);
  // }

  static Future<void> scheduleNotification(Reminder reminder) async {
    if (reminder.id == null) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );



    const NotificationDetails details = NotificationDetails(
      android: androidDetails,

    );

    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notifications.zonedSchedule(
        reminder.id!,
        reminder.title,
        reminder.description,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        // UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi')); // ✅ Add this line

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');



    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,

    );

    await _notifications.initialize(settings);

    // ✅ TEST NOTIFICATION
    await _notifications.show(
      0,
      'Test Notification',
      'This is just to test if notifications are working.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),

      ),
    );
  }

}
