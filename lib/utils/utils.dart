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

// from seconds to "1hr2m"
String formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return '${hours > 0 ? '$hours hr ' : ''}${minutes > 0 ? '$minutes m' : ''}';
}

// from meters to "1.22"
String formatDistance(double meters) {
  return (meters / 1000).toStringAsFixed(2);
}
