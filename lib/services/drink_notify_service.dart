import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrinkNotificationService {
  final FlutterLocalNotificationsPlugin drinkLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/drink.png');
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await drinkLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Handle notification response
        if (true) {
          await scheduleNextDayDrinkNotification(notificationResponse);
        }
      },
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // iOS permissions
    await drinkLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android permissions (if needed)
    await drinkLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  Future<void> showNotification({int id = 0, String? title, String? body, String? payload}) async {
    return drinkLocalNotificationsPlugin.show(
      id, title, body,
      await notificationDetails(),
    );
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'drink_channel', // ID of the notification channel
        'Drink Notifications', // Name of the notification channel
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleDrinkNotifications({
    int numberOfDrinks = 3,
    required DateTime startTime,
    required DateTime endTime,
    String? payload,
  }) async {
    // nếu startTime > endTime thì không schedule
    if (startTime.isAfter(endTime)) {
      return;
    }
    // nếu startTime không phải trong tương lai thì dời lại 1 ngày
    if (startTime.isBefore(DateTime.now())) {
      startTime = startTime.add(const Duration(days: 1));
      endTime = endTime.add(const Duration(days: 1));
    }

    final int intervalMinutes = ((endTime.difference(startTime).inMinutes) / numberOfDrinks).round();
    DateTime scheduledTime = startTime;

    for (int i = 0; i < numberOfDrinks; i++) {
      await drinkLocalNotificationsPlugin.zonedSchedule(
        i,
        'Drink Reminder',
        'It\'s time to drink water!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        await notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      scheduledTime = scheduledTime.add(Duration(minutes: intervalMinutes));
    }

    // use Toast to show the notification schedule
    Fluttertoast.showToast(
      msg: 'Scheduled $numberOfDrinks drink notifications from ${DateFormat('HH:mm').format(startTime)} to ${DateFormat('HH:mm').format(endTime)}, every $intervalMinutes minutes',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    await saveDrinkSchedule(numberOfDrinks, startTime, endTime);
  }

  Future<void> saveDrinkSchedule(int numberOfDrinks, DateTime startTime, DateTime endTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('numberOfDrinks', numberOfDrinks);
    await prefs.setString('startTime', startTime.toIso8601String());
    await prefs.setString('endTime', endTime.toIso8601String());
  }

  Future<Map<String, dynamic>?> getDrinkSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final int? numberOfDrinks = prefs.getInt('numberOfDrinks');
    final String? startTimeString = prefs.getString('startTime');
    final String? endTimeString = prefs.getString('endTime');

    if (numberOfDrinks != null && startTimeString != null && endTimeString != null) {
      final DateTime startTime = DateTime.parse(startTimeString);
      final DateTime endTime = DateTime.parse(endTimeString);
      return {
        'numberOfDrinks': numberOfDrinks,
        'startTime': startTime,
        'endTime': endTime,
      };
    }
    return null;
  }

  Future<void> scheduleNextDayDrinkNotification(NotificationResponse response) async {
    // log the response payload
    print('Notification payload: ${response.payload}');
    final DateTime nextDay = DateTime.now().add(const Duration(days: 1));
    final String? title = "Drink reminder"; // Replace with actual title if payload has one
    final String? body = response.payload; // Assume payload contains body text
    // Schedule notification for the same time next day
    await scheduleDrinkNotifications(
      numberOfDrinks: 3, // Example value, replace with actual logic if needed
      startTime: DateTime(nextDay.year, nextDay.month, nextDay.day, nextDay.hour, nextDay.minute),
      endTime: DateTime(nextDay.year, nextDay.month, nextDay.day, nextDay.hour + 3, nextDay.minute), // Example value, replace with actual logic if needed
    );
  }
}