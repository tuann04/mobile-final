import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NguyenScreen extends StatefulWidget {
  const NguyenScreen({Key? key}) : super(key: key);

  @override
  _NguyenScreenState createState() => _NguyenScreenState();
}

class _NguyenScreenState extends State<NguyenScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _scheduleNotification(picked);
    }
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    final now = DateTime.now();
    final selectedDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.schedule(
      0,
      'Time Alert',
      'The selected time has arrived!',
      selectedDateTime,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep and Drink'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Sleep'),
            Tab(text: 'Drink'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Selected time: ${_selectedTime.format(context)}', style: TextStyle(fontSize: 24)),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time'),
                ),
              ],
            ),
          ),
          Center(
            child: Text('Drink tab content', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}