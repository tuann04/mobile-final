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
  StepData _todayStepData = StepData(
      id: '',
      steps: 0,
      date: DateTime.now(),
      duration: 0,
      distance: 0.0,
      calories: 0.0);
  StepData get todayStepsData => _todayStepData;

  List<StepData> _weeklyStepsData = [];
  List<StepData> get weeklyStepsData => _weeklyStepsData;

  List<StepData> _monthlyStepsData = [];
  List<StepData> get monthlyStepsData => _monthlyStepsData;

  Map<int, int> _yearlyStepsData = {};
  Map<int, int> get yearlyStepsData => _yearlyStepsData;

  StepCounterViewModel() {
    fetchTodayStepsData();
    fetchWeeklyStepsData();
    fetchMonthlyStepsData(DateTime.now().year, DateTime.now().month);
    fetchYearlyStepsData(DateTime.now().year);
  }

  saveTodayStepsData(StepData stepData) async {
    await _repository.saveStepsData(stepData);
    fetchTodayStepsData();
    fetchWeeklyStepsData();
    fetchMonthlyStepsData(DateTime.now().year, DateTime.now().month);
    fetchYearlyStepsData(DateTime.now().year);
  }

  // Lấy số bước trong ngày
  fetchTodayStepsData() async {
    _todayStepData = await _repository.getTodayStepsData();
    notifyListeners();
  }

  // Lấy dữ liệu trong tuần, trả về List<StepData>
  fetchWeeklyStepsData() async {
    _weeklyStepsData = await _repository.getWeeklyStepsData();
    notifyListeners();
  }

  // Lấy dữ liệu trong tháng, trả về List<StepData>
  fetchMonthlyStepsData(int year, int month) async {
    _monthlyStepsData = await _repository.getMonthlyStepsData(year, month);
    notifyListeners();
  }

  // Lấy dữ liệu trong năm, trả về Map<int, int>
  fetchYearlyStepsData(int year) async {
    _yearlyStepsData = await _repository.getYearlyStepsData(year);
    notifyListeners();
  }

  // Xóa bảng
  deleteTable() async {
    await _repository.deleteTable();
    fetchTodayStepsData();
    fetchWeeklyStepsData();
    fetchMonthlyStepsData(DateTime.now().year, DateTime.now().month);
    fetchYearlyStepsData(DateTime.now().year);
  }
}
