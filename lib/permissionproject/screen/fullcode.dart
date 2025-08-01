// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize notifications
  await NotificationService.initialize();

  runApp(NotificationDemoApp());
}

class NotificationDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: NotificationDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotificationDemoScreen extends StatefulWidget {
  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  DateTime selectedDateTime = DateTime.now().add(Duration(minutes: 1));
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = "Demo Notification";
    bodyController.text = "This is a test notification!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Notification Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Permission Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📱 Permission Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder<bool>(
                      future: NotificationService.areNotificationsEnabled(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Row(
                            children: [
                              Icon(
                                snapshot.data! ? Icons.check_circle : Icons.error,
                                color: snapshot.data! ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                snapshot.data!
                                    ? 'Notifications Enabled'
                                    : 'Notifications Disabled',
                                style: TextStyle(
                                  color: snapshot.data! ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await NotificationService.requestPermissions();
                        setState(() {}); // Refresh permission status
                      },
                      child: Text('Request Permissions'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Instant Notifications Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ Instant Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: () => NotificationService.showSimpleNotification(),
                      icon: Icon(Icons.notifications),
                      label: Text('Simple Notification'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),

                    SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () => NotificationService.showNotificationWithSound(),
                      icon: Icon(Icons.volume_up),
                      label: Text('Notification with Sound'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),

                    SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () => NotificationService.showBigTextNotification(),
                      icon: Icon(Icons.text_fields),
                      label: Text('Big Text Notification'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Scheduled Notifications Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏰ Scheduled Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Notification Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),

                    SizedBox(height: 10),

                    TextField(
                      controller: bodyController,
                      decoration: InputDecoration(
                        labelText: 'Notification Body',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                      ),
                      maxLines: 2,
                    ),

                    SizedBox(height: 15),

                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Scheduled Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${selectedDateTime.toString().substring(0, 16)}'),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _selectDateTime,
                            child: Text('Select Time'),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              NotificationService.scheduleNotification(
                                titleController.text,
                                bodyController.text,
                                selectedDateTime,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Notification scheduled for ${selectedDateTime.toString().substring(0, 16)}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: Icon(Icons.schedule),
                            label: Text('Schedule'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Schedule for 5 seconds from now
                              final quickTime = DateTime.now().add(Duration(seconds: 5));
                              NotificationService.scheduleNotification(
                                "Quick Test",
                                "This notification was scheduled 5 seconds ago!",
                                quickTime,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Quick notification scheduled for 5 seconds!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                            icon: Icon(Icons.flash_on),
                            label: Text('5 Sec Test'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Repeating Notifications Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔄 Repeating Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: () {
                        NotificationService.scheduleDailyNotification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Daily notification scheduled for 9:00 AM')),
                        );
                      },
                      icon: Icon(Icons.repeat),
                      label: Text('Daily at 9:00 AM'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Cancel Notifications Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '❌ Cancel Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              NotificationService.cancelAllNotifications();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('All notifications cancelled'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            icon: Icon(Icons.clear_all),
                            label: Text('Cancel All'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
}

// Notification Service Class
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );

    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    // Android 13+ notification permission
    await Permission.notification.request();

    // Android 12+ exact alarm permission
    await Permission.scheduleExactAlarm.request();

    // iOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<bool> areNotificationsEnabled() async {
    return await Permission.notification.isGranted;
  }

  // Simple notification
  static Future<void> showSimpleNotification() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'simple_channel',
        'Simple Notifications',
        channelDescription: 'Basic notification channel',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      1,
      'Simple Notification',
      'This is a basic notification without sound',
      details,
    );
  }

  // Notification with sound
  static Future<void> showNotificationWithSound() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'sound_channel',
        'Sound Notifications',
        channelDescription: 'Notifications with sound',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
      ),
    );

    await _notifications.show(
      2,
      '🔊 Sound Notification',
      'This notification plays sound and vibrates!',
      details,
    );
  }

  // Big text notification
  static Future<void> showBigTextNotification() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'big_text_channel',
        'Big Text Notifications',
        channelDescription: 'Notifications with expandable text',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          'This is a very long notification text that will be expanded when the user swipes down. '
              'It can contain multiple lines and detailed information about the notification content. '
              'This is perfect for showing detailed messages or instructions.',
        ),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      3,
      '📝 Big Text Notification',
      'Tap to expand this notification...',
      details,
    );
  }

  // Scheduled notification
  static Future<void> scheduleNotification(
      String title,
      String body,
      DateTime scheduledTime,
      ) async {
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Cannot schedule notification in the past!');
      return;
    }

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription: 'Notifications scheduled for later',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title,
      body,
      scheduledTZ,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Daily repeating notification
  static Future<void> scheduleDailyNotification() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel',
        'Daily Notifications',
        channelDescription: 'Daily repeating notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      999, // Fixed ID for daily notification
      '🌅 Good Morning!',
      'Time to start your day with a positive attitude!',
      _nextInstanceOfTime(9, 0), // 9:00 AM
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}