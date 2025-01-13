class StepData {
  String id;
  int steps;
  DateTime date;
  double distance;
  double calories;

  StepData({
    required this.id,
    required this.steps,
    required this.date,
    this.distance = 0,
    this.calories = 0,
  });

  // Use sqlite to store data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'steps': steps,
      'date': date.toIso8601String().substring(0, 10),
      'distance': distance,
      'calories': calories,
    };
  }

  // Use sqlite to retrieve data
  factory StepData.fromMap(Map<String, dynamic> map) {
    return StepData(
      id: map['id'],
      steps: map['steps'],
      date: DateTime.parse(map['date']),
      distance: map['distance'],
      calories: map['calories'],
    );
  }
}
