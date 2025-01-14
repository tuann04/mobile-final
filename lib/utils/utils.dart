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
