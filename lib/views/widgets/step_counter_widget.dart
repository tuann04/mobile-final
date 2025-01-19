import 'dart:ffi' as ffi;
import 'package:flutter/material.dart';
import 'package:health_app/constant/constant.dart';
import 'package:health_app/db/database_helper.dart';
import 'package:health_app/models/step_data.dart';
import 'package:health_app/utils/utils.dart';
import 'package:health_app/view_models/step_counter_view_model.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

final logger = Logger();

class StepCounterWidget extends StatefulWidget {
  final StepCounterViewModel viewModel;

  StepCounterWidget({required this.viewModel});

  @override
  StepCounterWidgetState createState() => StepCounterWidgetState();
}

class StepCounterWidgetState extends State<StepCounterWidget> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  Timer? _timer;

  String _status = 'Stopped';

  bool _isStarted = false;
  int _initialSteps = 0;
  bool _isInitialized = false;

  int _steps = 0;
  double _distance = 0.0;
  int _duration = 0;
  double _calories = 0.0;

  late StepData _todayStepData = widget.viewModel.todayStepsData;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _steps = _todayStepData.steps;
    _calories = _todayStepData.calories;
    _duration = _todayStepData.duration;
    _distance = _todayStepData.distance;
  }

  void updateStats() {
    setState(() {
      _calories = _steps * 0.05;
      _distance = _steps * 0.75;
    });
  }

  void handleStartStop() {
    setState(() {
      if (_isStarted) {
        _isStarted = false;
        _isInitialized = false;
        _timer?.cancel();
      } else {
        _isStarted = true;
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _duration++;
          });
        });
      }
    });
  }

  void onStepCount(StepCount event) {
    if (_isStarted) {
      setState(() {
        if (!_isInitialized) {
          _initialSteps = event.steps - _steps;
          _isInitialized = true;
        }
        _steps = event.steps - _initialSteps;
        updateStats();
      });
    }
  }

  // void resetSteps() async {
  //   setState(() {
  //     _steps = 0;
  //     _initialSteps = 0;
  //     _isInitialized = false;
  //   });
  // }

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
    logger.d('Step counter error: $error');
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }

  void disposePlatformState() {
    _stepCountStream.listen(null).onError(null);
    _pedestrianStatusStream.listen(null).onError(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pedometer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(300, 300),
                      painter: CircleProgressPainter(
                          progress: _steps / 200, // Assuming 200 steps goal
                          color: cyanColor),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: grayColor, // Màu nền xám
                        shape: BoxShape.circle, // Hình dạng vòng tròn
                      ),
                      padding: EdgeInsets.all(
                          16.0), // Khoảng cách giữa nội dung và viền
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _steps.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Steps',
                            style: TextStyle(
                              color: Colors.grey[300], // Màu chữ xám nhạt hơn
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      child: FloatingActionButton(
                        backgroundColor: Color(0xFFFF9800),
                        onPressed: () {
                          handleStartStop();
                        },
                        shape: CircleBorder(),
                        child: Icon(
                          _isStarted ? Icons.stop : Icons.play_arrow,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(
                      Icons.place,
                      formatDistance(_distance),
                      'Kilometer',
                      Colors.red,
                    ),
                    _buildStat(
                      Icons.access_time,
                      formatDuration(_duration),
                      'Times',
                      Colors.amber,
                    ),
                    _buildStat(
                      Icons.local_fire_department,
                      formatCalories(_calories),
                      'Calories',
                      Colors.red,
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // Text(
                //   'Weekly Goals',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 20),
                // _buildWeeklyGoals(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();

    disposePlatformState();
    widget.viewModel.saveTodayStepsData(StepData(
      id: _todayStepData.id,
      steps: _steps,
      date: _todayStepData.date,
      duration: _duration,
      distance: _distance,
      calories: _calories,
    ));
    logger.d('Dispose step counter widget steps: $_steps');
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 30;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    // Background circle
    paint.color = Colors.grey[800]!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      paint,
    );

    // Progress arc
    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
