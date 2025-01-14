import 'package:flutter/material.dart';
import 'package:health_app/models/step_data.dart';
import 'package:health_app/utils/utils.dart';
import 'package:health_app/view_models/step_counter_view_model.dart';
import 'package:health_app/views/widgets/step_counter_weekly_tab.dart';
import 'package:health_app/views/widgets/step_counter_yearly.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class StepCounterScreen extends StatefulWidget {
  final StepCounterViewModel viewModel;

  StepCounterScreen({required Key key, required this.viewModel})
      : super(key: key);

  @override
  StepCounterScreenState createState() => StepCounterScreenState();
}

class StepCounterScreenState extends State<StepCounterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'Stopped';
  int _steps = 0;
  int _initialSteps = 0;
  bool _isInitialized = false;
  late StepData _todayStepData;
  late List<StepData> _monthlyStepData;
  late Map<int, int> _yearlyStepData;
  final double goalSteps = 10000;
  final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<bool> weeklyGoals = [true, false, true, true, false, false, true];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initPlatformState();
    fetchStepData();
  }

  Future<void> fetchStepData() async {
    _todayStepData = widget.viewModel.todaySteps!;
    _monthlyStepData = widget.viewModel.monthlySteps!;
    _yearlyStepData = widget.viewModel.yearlySteps!;
    setState(() {
      _steps = _todayStepData.steps;
    });
  }

  void onStepCount(StepCount event) {
    setState(() {
      if (!_isInitialized) {
        _initialSteps = event.steps;
        _isInitialized = true;
      }
      _steps = event.steps - _initialSteps;
    });
  }

  void resetSteps() async {
    setState(() {
      _steps = 0;
      _initialSteps = 0;
      _isInitialized = false;
    });
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

  Widget _buildDailyTab() {
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
            onPressed: resetSteps,
            child: Text('Reset'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Counter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Today'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          StepCounterMonthlyTab(monthlyStepData: _monthlyStepData),
          StepCounterYearlyTab(
            yearlyStepData: _yearlyStepData,
            getMonthName: getMonthName,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    widget.viewModel.saveTodaySteps(_steps);
  }
}
