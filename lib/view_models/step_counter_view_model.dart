import 'dart:async';
import 'package:flutter/material.dart';

import '../repositories/step_counter_repository.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/step_data.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class StepCounterViewModel extends Model {
  final StepCounterRepository _repository = StepCounterRepository.instance;

  // State variables
  StepData? _todayStepData;
  StepData? get todaySteps => _todayStepData;

  List<StepData>? _monthlySteps = [];
  List<StepData>? get monthlySteps => _monthlySteps;

  Map<int, int>? _yearlySteps = {};
  Map<int, int>? get yearlySteps => _yearlySteps;

  StepCounterViewModel() {
    fetchStepData();
  }

  void fetchStepData() async {
    loadTodaySteps();
    loadMonthlySteps(DateTime.now().year, DateTime.now().month);
    loadYearlySteps(DateTime.now().year);
  }

  Future<void> saveTodaySteps(int steps) async {
    final now = DateTime.now();
    final stepData = StepData(
      id: now.toIso8601String().substring(0, 10),
      steps: steps,
      date: now,
    );
    await _repository.saveSteps(stepData);
  }

  // Lấy số bước trong ngày
  Future<void> loadTodaySteps() async {
    _todayStepData = await _repository.getTodaySteps();
    notifyListeners();
  }

  // Lấy dữ liệu trong tháng, trả về List<StepData>
  Future<void> loadMonthlySteps(int year, int month) async {
    _monthlySteps = await _repository.getMonthlySteps(year, month);
    notifyListeners();
  }

  // Lấy dữ liệu trong năm, trả về Map<int, int>
  Future<void> loadYearlySteps(int year) async {
    _yearlySteps = await _repository.getYearlySteps(year);
    notifyListeners();
  }
}
