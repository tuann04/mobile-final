import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:health_app/db/database_helper.dart';
import 'package:health_app/models/step_data.dart';
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
  String _status = 'Stopped';
  bool _isStarted = false;
  int _steps = 0;
  int _initialSteps = 0;
  bool _isInitialized = false;
  late StepData _todayStepData = widget.viewModel.todaySteps;

  @override
  void initState() {
    super.initState();
    _steps = _todayStepData.steps;
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    if (_isStarted) {
      setState(() {
        if (!_isInitialized) {
          _initialSteps = event.steps - _steps;
          _isInitialized = true;
        }
        _steps = event.steps - _initialSteps;
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

  @override
  Widget build(BuildContext context) {
    return Center(
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
            style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
          ),
          Text(
            'Steps',
            style: TextStyle(fontSize: 20, color: Colors.grey),
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
                    color: _status == 'Walking' ? Colors.green : Colors.orange,
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
              onPressed: () {
                setState(() {
                  if (_isStarted) {
                    _isStarted = false;
                    _isInitialized = false;
                  } else {
                    _isStarted = true;
                  }
                });
              },
              child: Icon(
                _isStarted ? Icons.stop : Icons.play_arrow,
                size: 40,
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.viewModel.saveTodaySteps(_steps);
    logger.d('Dispose step counter widget steps: $_steps');
  }
}

// class CircleProgressPainter extends CustomPainter {
//   final double progress;
//   final Color color;

//   CircleProgressPainter({
//     required this.progress,
//     required this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = math.min(size.width / 2, size.height / 2) - 30;
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 15
//       ..strokeCap = StrokeCap.round;

//     // Background circle
//     paint.color = Colors.grey[800]!;
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       -math.pi / 2,
//       2 * math.pi,
//       false,
//       paint,
//     );

//     // Progress arc
//     paint.color = color;
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       -math.pi / 2,
//       2 * math.pi * progress,
//       false,
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
