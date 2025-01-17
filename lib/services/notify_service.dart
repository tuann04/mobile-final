import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


// import Toast library
class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Handle notification response
        if (true) {
          await scheduleNextDayNotification(notificationResponse);
        }
      },
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // iOS permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android permissions (if needed)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  Future<void> showNotification({int id = 0, String? title, String? body, String? payload}) async {
    return flutterLocalNotificationsPlugin.show(
      id, title, body,
      await notificationDetails(),
    );
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id', // ID of the notification channel
        'channel_name', // Name of the notification channel
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
    required DateTime scheduledNotificationDateTime}) async {
    // nếu scheduledNotificationDateTime không phải trong tương lai thì dời lại 1 ngày
    if (scheduledNotificationDateTime.isBefore(DateTime.now())) {
      scheduledNotificationDateTime = scheduledNotificationDateTime.add(const Duration(days: 1));
    }
    // print('Scheduled notification for: $scheduledNotificationDateTime');
    String formattedTime = DateFormat('hh:mm a').format(scheduledNotificationDateTime);
    Fluttertoast.showToast(
      msg: 'Set sleep time to: $formattedTime',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    return flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledNotificationDateTime,
        tz.local,
      ),
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    // save scheduled time to shared preferences
    await saveScheduledTime(scheduledNotificationDateTime);
  }

  Future<void> scheduleNextDayNotification(NotificationResponse response) async {
    // log the response payload
    print('Notification payload: ${response.payload}');
    final DateTime nextDay = DateTime.now().add(const Duration(days: 1));
    final String? title = "Sleep reminder"; // Replace with actual title if payload has one
    final String? body = response.payload; // Assume payload contains body text
    // Schedule notification for the same time next day
    await scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title: title ?? "Notification",
      body: body ?? "Scheduled sleep reminder for the next day",
      scheduledNotificationDateTime: DateTime(nextDay.year, nextDay.month, nextDay.day, nextDay.hour, nextDay.minute),
    );
  }

  Future<DateTime?> getScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('scheduledTime');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  saveScheduledTime(DateTime scheduledNotificationDateTime) {
    final prefs = SharedPreferences.getInstance();
    prefs.then((value) {
      value.setString('scheduledTime', scheduledNotificationDateTime.toIso8601String());
    });
  }

  Future<void> saveSleepStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sleepStreak', streak);
  }

  Future<int> getSleepStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('sleepStreak') ?? 0;
  }
}