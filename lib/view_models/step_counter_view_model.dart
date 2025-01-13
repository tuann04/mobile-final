import 'dart:async';
import '../repositories/step_counter_repository.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/step_data.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class StepCounterViewModel extends Model {
  final _repository = StepCounterRepository.instance;

  // State variables
  List<StepData> monthlySteps = [];
  Map<int, int> yearlySteps = {};

  Future<void> saveTodaySteps(int steps) async {
    final now = DateTime.now();
    final stepData = StepData(
      id: now.toIso8601String().substring(0, 10),
      steps: steps,
      date: now,
    );
    await _repository.saveSteps(stepData);
  }

  // Future<void> resetSteps() async {
  //   // todaySteps = 0;
  //   // _initialSteps = 0;
  //   // _isInitialized = false;
  //   notifyListeners();
  //   await saveTodaySteps();
  // }

  // Lấy số bước trong ngày
  Future<StepData> loadTodaySteps() async {
    final stepData = await _repository.getTodaySteps();
    notifyListeners();
    return stepData;
  }

  // Lấy dữ liệu trong tháng, trả về List<StepData>
  Future<List<StepData>> loadMonthlySteps(int year, int month) async {
    monthlySteps = await _repository.getMonthlySteps(year, month);
    notifyListeners();
    return monthlySteps;
  }

  // Lấy dữ liệu trong năm, trả về Map<int, int>
  Future<Map<int, int>> loadYearlySteps(int year) async {
    yearlySteps = await _repository.getYearlySteps(year);
    notifyListeners();
    return yearlySteps;
  }

  // Xóa bảng
  Future<void> deleteTable() async {
    await _repository.recreateTable();
  }
}
