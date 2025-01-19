import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/notify_service.dart';
import '../../services/drink_notify_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime scheduleTime = DateTime.now();

class NguyenScreen extends StatefulWidget {
  const NguyenScreen({Key? key}) : super(key: key);

  @override
  _NguyenScreenState createState() => _NguyenScreenState();
}

class _NguyenScreenState extends State<NguyenScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> isTimeChanged = ValueNotifier<bool>(false);
  int sleepStreak = 0;
  int numberOfDrinks = 3;
  int bestStreak = 0;
  DateTime drinkStartTime = DateTime.now();
  DateTime drinkEndTime = DateTime.now().add(Duration(hours: 3));
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadScheduledTime();
    _loadSleepStreak();
    _loadBestStreak();
    _startTimeController.text = TimeOfDay.fromDateTime(drinkStartTime).format(context);
    _endTimeController.text = TimeOfDay.fromDateTime(drinkEndTime).format(context);
  }

  Future<void> _loadBestStreak() async {
    final streak = await NotificationService().getBestStreak();
    setState(() {
      bestStreak = streak;
    });
  }

  Future<void> _loadScheduledTime() async {
    final savedTime = await NotificationService().getScheduledTime();
    if (savedTime != null) {
      setState(() {
        scheduleTime = savedTime;
      });
    }
  }

  Future<void> _loadSleepStreak() async {
    final streak = await NotificationService().getSleepStreak();
    setState(() {
      sleepStreak = streak;
    });
  }

  void _increaseSleepStreak() async {
    setState(() {
      sleepStreak++;
      if (sleepStreak > bestStreak) {
        bestStreak = sleepStreak;
        NotificationService().saveBestStreak(bestStreak);
      }
    });
    await NotificationService().saveSleepStreak(sleepStreak);
  }

  void _resetSleepStreak() async {
    setState(() {
      sleepStreak = 0;
    });
    await NotificationService().saveSleepStreak(sleepStreak);
  }

  void _scheduleDrinkNotifications() async {
    await DrinkNotificationService().scheduleDrinkNotifications(
      numberOfDrinks: numberOfDrinks,
      startTime: drinkStartTime,
      endTime: drinkEndTime,
      payload: 'drink water!',
    );
    Fluttertoast.showToast(
      msg: 'Drink notifications scheduled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showNumberOfDrinksDialog() {
    TextEditingController controller = TextEditingController(text: numberOfDrinks.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter number of drinks', style: TextStyle(fontSize: 16)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(fontSize: 14)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK', style: TextStyle(fontSize: 14)),
              onPressed: () {
                setState(() {
                  numberOfDrinks = int.tryParse(controller.text) ?? 3;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? drinkStartTime : drinkEndTime),
    );
    if (picked != null) {
      setState(() {
        final DateTime newTime = DateTime(
          drinkStartTime.year,
          drinkStartTime.month,
          drinkStartTime.day,
          picked.hour,
          picked.minute,
        );
        if (isStartTime) {
          drinkStartTime = newTime;
          controller.text = picked.format(context);
        } else {
          drinkEndTime = newTime;
          controller.text = picked.format(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep and Drink', style: TextStyle(fontSize: 18)),
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
                Text('Selected time: ${TimeOfDay.fromDateTime(scheduleTime).format(context)}', style: const TextStyle(fontSize: 18)),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduleTime),
                    );
                    if (picked != null) {
                      setState(() {
                        DateTime newTime = DateTime(
                          scheduleTime.year,
                          scheduleTime.month,
                          scheduleTime.day,
                          picked.hour,
                          picked.minute,
                        );
                        isTimeChanged.value = newTime != scheduleTime;
                        scheduleTime = newTime;
                      });
                    }
                  },
                  child: Text('Select Time', style: TextStyle(fontSize: 14)),
                ),
                SizedBox(height: 30),
                ValueListenableBuilder<bool>(
                  valueListenable: isTimeChanged,
                  builder: (context, value, child) {
                    return ElevatedButton(
                      onPressed: value
                          ? () {
                        NotificationService().scheduleNotification(
                          title: 'Sleep Reminder',
                          body: 'It\'s time to go to sleep!',
                          scheduledNotificationDateTime: scheduleTime,
                          payload: 'sleep reminder',
                        );
                      }
                          : null,
                      child: const Text('Schedule Sleep Notification', style: TextStyle(fontSize: 14)),
                    );
                  },
                ),
                SizedBox(height: 30),
                const Divider(
                  color: Colors.grey,
                  height: 20,
                  thickness: 2,
                  indent: 0,
                  endIndent: 0,
                ),
                SizedBox(height: 30),
                Text('Sleep Streak: $sleepStreak', style: const TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Best Streak: $bestStreak', style: const TextStyle(fontSize: 18)),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _increaseSleepStreak,
                  child: Text('Increase Streak', style: TextStyle(fontSize: 14)),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _resetSleepStreak,
                  child: Text('Reset Streak', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute evenly
                  children: [
                    Text(
                      'Number of Drinks: $numberOfDrinks',
                      style: const TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: _showNumberOfDrinksDialog,
                      child: Text(
                        'Change',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Start Time TextField
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 4.0), // Padding on sides
                        child: TextField(
                          controller: _startTimeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _selectTime(context, _startTimeController, true),
                        ),
                      ),
                    ),
                    // Separator
                    Container(
                      width: 1, // Thin line
                      height: 48, // Matches TextField height
                      color: Colors.grey, // Thin separator color
                    ),
                    // End Time TextField
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 8.0), // Padding on sides
                        child: TextField(
                          controller: _endTimeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _selectTime(context, _endTimeController, false),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _scheduleDrinkNotifications,
                  child: Text('Schedule Drink Notifications', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}