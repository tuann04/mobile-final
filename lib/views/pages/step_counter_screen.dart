import 'package:flutter/material.dart';
import 'package:health_app/models/step_data.dart';
import 'package:health_app/utils/utils.dart';
import 'package:health_app/view_models/step_counter_view_model.dart';
import 'package:health_app/views/widgets/step_counter_monthly.dart';
import 'package:health_app/views/widgets/step_counter_widget.dart';
import 'package:health_app/views/widgets/step_counter_yearly.dart';
import 'package:provider/provider.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:logger/logger.dart';

final logger = Logger();

class StepCounterScreen extends StatefulWidget {
  @override
  StepCounterScreenState createState() => StepCounterScreenState();
}

class StepCounterScreenState extends State<StepCounterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StepCounterViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Step Counter'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              StepCounterWidget(key: const ValueKey('today_tab')),
              StepCounterMonthlyTab(
                key: const ValueKey('monthly_tab'),
                monthlyStepData: viewModel.monthlySteps,
              ),
              StepCounterYearlyTab(
                key: const ValueKey('yearly_tab'),
                yearlyStepData: viewModel.yearlySteps,
                getMonthName: getMonthName,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
