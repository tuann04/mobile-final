import 'package:pedometer/pedometer.dart';

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();

  factory StepCounterService() => _instance;

  StepCounterService._internal();

  Stream<StepCount> get stepCountStream => Pedometer.stepCountStream;
  Stream<PedestrianStatus> get pedestrianStatusStream =>
      Pedometer.pedestrianStatusStream;

  Future<bool> checkPermission() async {
    try {
      await Pedometer.pedestrianStatusStream.first;
      return true;
    } catch (e) {
      return false;
    }
  }
}
