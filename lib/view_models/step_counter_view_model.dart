import 'dart:async';
import 'package:flutter/material.dart';

import '../repositories/step_counter_repository.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/step_data.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class StepCounterViewModel extends ChangeNotifier {
  final StepCounterRepository _repository = StepCounterRepository.instance;

  // State variables
  StepData _todayStepData = StepData(id: '', steps: 0, date: DateTime.now());
  StepData get todaySteps => _todayStepData;

  List<StepData> _weeklySteps = [];
  List<StepData> get weeklySteps => _weeklySteps;

  List<StepData> _monthlySteps = [];
  List<StepData> get monthlySteps => _monthlySteps;

  Map<int, int> _yearlySteps = {};
  Map<int, int> get yearlySteps => _yearlySteps;

  StepCounterViewModel() {
    fetchTodaySteps();
    fetchWeeklySteps();
    fetchMonthlySteps(DateTime.now().year, DateTime.now().month);
    fetchYearlySteps(DateTime.now().year);
  }

  saveTodaySteps(int steps) async {
    final now = DateTime.now();
    final stepData = StepData(
      id: now.toIso8601String().substring(0, 10),
      steps: steps,
      date: now,
    );
    await _repository.saveSteps(stepData);
    fetchTodaySteps();
    fetchWeeklySteps();
    fetchMonthlySteps(DateTime.now().year, DateTime.now().month);
    fetchYearlySteps(DateTime.now().year);
  }

  // Lấy số bước trong ngày
  fetchTodaySteps() async {
    _todayStepData = await _repository.getTodaySteps();
    notifyListeners();
  }

  // Lấy dữ liệu trong tuần, trả về List<StepData>
  fetchWeeklySteps() async {
    _weeklySteps = await _repository.getWeeklySteps();
    notifyListeners();
  }

  // Lấy dữ liệu trong tháng, trả về List<StepData>
  fetchMonthlySteps(int year, int month) async {
    _monthlySteps = await _repository.getMonthlySteps(year, month);
    notifyListeners();
  }

  // Lấy dữ liệu trong năm, trả về Map<int, int>
  fetchYearlySteps(int year) async {
    _yearlySteps = await _repository.getYearlySteps(year);
    notifyListeners();
  }

  // Xóa bảng
  deleteTable() async {
    await _repository.deleteTable();
    fetchTodaySteps();
    fetchWeeklySteps();
    fetchMonthlySteps(DateTime.now().year, DateTime.now().month);
    fetchYearlySteps(DateTime.now().year);
  }
}
