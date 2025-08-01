import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initilizeNotification() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSetting = InitializationSettings(
      android: androidSettings,
    );
    // await _notificationsPlugin.initialize(initializationSetting);
    await _notificationPlugin.initialize(initializationSetting);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      "Reminder",
      description: "channel for Reminder notification",
      importance: Importance.high,
      playSound: true,
    );
    await _notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    String category,
    DateTime scheduledTime,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      "Reminder",

      importance: Importance.high,
      playSound: true,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    if (scheduledTime.isBefore(DateTime.now())) {
      //do nothing
    } else {
      await _notificationPlugin.zonedSchedule(
        id,
        title,
        category,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uilocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
        //     .absoluteTime
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationPlugin.cancel(id);
  }
  static Future<void> showNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }
}
