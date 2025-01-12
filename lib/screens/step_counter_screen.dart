import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class StepCounterScreen extends StatefulWidget {
  @override
  StepCounterScreenState createState() => StepCounterScreenState();
}

class StepCounterScreenState extends State<StepCounterScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'Stopped';
  int _steps = 0;
  int _initialSteps = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    loadSavedSteps().then((_) {
      initPlatformState();
    });
  }

  // void loadSavedSteps() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _initialSteps = prefs.getInt('initialSteps') ?? 0;
  //     _steps = prefs.getInt('steps') ?? 0;
  //   });
  // }

  Future<void> loadSavedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    // Thêm key để track ngày
    final String today = DateTime.now().toIso8601String().split('T')[0];
    final String savedDate = prefs.getString('step_date') ?? '';

    if (today != savedDate) {
      // Ngày mới - reset số bước
      setState(() {
        _steps = 0;
        _initialSteps = 0;
        _isInitialized = false;
      });
      await prefs.setString('step_date', today);
    } else {
      // Cùng ngày - load số bước đã lưu
      setState(() {
        _initialSteps = prefs.getInt('initialSteps') ?? 0;
        _steps = prefs.getInt('steps') ?? 0;
        _isInitialized = prefs.getBool('isInitialized') ?? false;
      });
    }
  }

  // void saveSteps() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('steps', _steps);
  //   await prefs.setInt('initialSteps', _initialSteps);
  // }

  Future<void> saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T')[0];

    await prefs.setString('step_date', today);
    await prefs.setInt('steps', _steps);
    await prefs.setInt('initialSteps', _initialSteps);
    await prefs.setBool('isInitialized', _isInitialized);
  }

  // void onStepCount(StepCount event) {
  //   setState(() {
  //     if (!_isInitialized) {
  //       _initialSteps = event.steps;
  //       _isInitialized = true;
  //     }
  //     _steps = event.steps - _initialSteps;
  //   });
  //   saveSteps();
  // }

  void onStepCount(StepCount event) {
    setState(() {
      if (!_isInitialized) {
        _initialSteps = event.steps;
        _isInitialized = true;
      }
      _steps = event.steps - _initialSteps;
    });
    // Lưu ngay sau khi cập nhật
    saveSteps();
  }

  // void resetSteps() {
  //   setState(() {
  //     _steps = 0;
  //     _isInitialized = false;
  //   });
  //   saveSteps();
  // }

  void resetSteps() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _steps = 0;
      _initialSteps = 0;
      _isInitialized = false;
    });
    await saveSteps();
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status == 'walking' ? 'Walking' : 'Stopped';
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Unable to detect the status.';
    });
  }

  void onStepCountError(error) {
    print('Step counter error: $error');
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_walk,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 20),
            Text(
              '$_steps',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Bước',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _status == 'Walking'
                          ? Icons.directions_walk
                          : Icons.accessibility_new,
                      color:
                          _status == 'Walking' ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 10),
                    Text(
                      _status,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: resetSteps,
              child: Text('Reset'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
