// main.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reminder/reminder01/database/database_helper.dart';
import 'package:reminder/reminder01/notification/notification_helper.dart';
import 'package:reminder/reminder01/screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Initializing DB...");
  await DbHelper.initDb();
  print("DB initialized.");

  print("Initializing Notifications...");
  await NotificationHelper.initilizeNotification();
  print("Notifications initialized.");

  print("Requesting notification permission...");
  await Permission.notification.request();
  print("Permission requested.");

  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // NotificationHelper.showNotification(
    //   // title: message.notification?.title ?? 'Notification',
    //   // body: message.notification?.body ?? '',
    // );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reminder App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: Home_Screen(),
    );
  }
}
