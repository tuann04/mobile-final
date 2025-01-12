import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class StepCounterScreen extends StatefulWidget {
  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'Đứng yên';
  int _steps = 0;
  int _initialSteps = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    loadSavedSteps();
  }

  void loadSavedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _initialSteps = prefs.getInt('initialSteps') ?? 0;
      _steps = prefs.getInt('steps') ?? 0;
    });
  }

  void saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', _steps);
    await prefs.setInt('initialSteps', _initialSteps);
  }

  void onStepCount(StepCount event) {
    setState(() {
      if (!_isInitialized) {
        _initialSteps = event.steps;
        _isInitialized = true;
      }
      _steps = event.steps - _initialSteps;
    });
    saveSteps();
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status == 'walking' ? 'Đang đi bộ' : 'Đứng yên';
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Không thể phát hiện trạng thái';
    });
  }

  void onStepCountError(error) {
    print('Lỗi đếm bước: $error');
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }

  void resetSteps() {
    setState(() {
      _steps = 0;
      _isInitialized = false;
    });
    saveSteps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đếm Bước Chân'),
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
                      _status == 'Đang đi bộ'
                          ? Icons.directions_walk
                          : Icons.accessibility_new,
                      color: _status == 'Đang đi bộ'
                          ? Colors.green
                          : Colors.orange,
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
              child: Text('Đặt Lại'),
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
