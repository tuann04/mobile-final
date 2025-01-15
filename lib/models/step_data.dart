class StepData {
  String id;
  int steps;
  DateTime date;
  int duration; // in seconds
  double distance;
  double calories;

  StepData({
    required this.id,
    required this.steps,
    required this.date,
    required this.duration,
    required this.distance,
    required this.calories,
  });

  // Use sqlite to store data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'steps': steps,
      'date': date.toIso8601String().substring(0, 10),
      'duration': duration,
      'distance': distance,
      'calories': calories,
    };
  }

  // Use sqlite to retrieve data
  factory StepData.fromMap(Map<String, dynamic> map) {
    return StepData(
      id: map['id'].toString(),
      steps: map['steps'],
      date: DateTime.parse(map['date']),
      duration: map['duration'] ?? 0,
      distance: map['distance'] ?? 0,
      calories: map['calories'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'StepData{id: $id, steps: $steps, date: $date, duration: $duration, distance: $distance, calories: $calories}';
  }
}
