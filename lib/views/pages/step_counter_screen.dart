import 'package:flutter/material.dart';
import 'package:health_app/models/step_data.dart';
import 'package:health_app/utils/utils.dart';
import 'package:health_app/view_models/step_counter_view_model.dart';
import 'package:health_app/views/widgets/debug_screen.dart';
import 'package:health_app/views/widgets/step_counter_monthly.dart';
import 'package:health_app/views/widgets/step_counter_widget.dart';
import 'package:health_app/views/widgets/step_counter_yearly.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:logger/logger.dart';

final logger = Logger();

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

  late StepData _todayStepData;
  late List<StepData> _weeklyStepData;
  late List<StepData> _monthlyStepData;
  late Map<int, int> _yearlyStepData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _todayStepData = widget.viewModel.todayStepsData;
    _weeklyStepData = widget.viewModel.weeklyStepsData;
    _monthlyStepData = widget.viewModel.monthlyStepsData;
    _yearlyStepData = widget.viewModel.yearlyStepsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Today'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
                Tab(
                  text: 'Debug',
                )
              ],
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StepCounterWidget(
            viewModel: widget.viewModel,
          ),
          StepCounterMonthlyTab(monthlyStepData: _monthlyStepData),
          StepCounterYearlyTab(
            yearlyStepData: _yearlyStepData,
            getMonthName: getMonthName,
          ),
          DebugScreen()
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    logger.d("step counter screen disposed ${_todayStepData.steps}");
    super.dispose();
  }
}
