import 'package:flutter/services.dart' show rootBundle;

String getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month];
}

Future<String> loadSqlFile(String path) async {
  return await rootBundle.loadString(path);
}

// from seconds to "1hr2m3s"
String formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${hours > 0 ? '${hours}hr' : ''}${minutes > 0 ? '${minutes}m' : ''}${remainingSeconds > 0 ? '${remainingSeconds}s' : ''}';
}

// from meters to "1.22"
String formatDistance(double meters) {
  return (meters / 1000).toStringAsFixed(2);
}

String formatCalories(double calories) {
  return calories.toStringAsFixed(2);
}

int roundToNearestTen(int number) {
  if (number < 50) return 50;
  if (number < 100) return 100;
  if (number < 1000) return (number / 100).ceil() * 100;
  if (number < 10000) return (number / 1000).ceil() * 1000;
  return (number / 10000).ceil() * 10000;
}
