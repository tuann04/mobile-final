import 'package:health_app/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/step_data.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class StepCounterRepository {
  static final StepCounterRepository instance = StepCounterRepository._();
  StepCounterRepository._();

  Future<Database> database = DatabaseHelper().database;

  // Lưu dữ liệu bước chân
  Future<void> saveSteps(StepData data) async {
    final db = await database;
    await db.insert(
      'STEPS',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    logger.i('Saved steps: ${data.steps}');
  }

  // Lấy số bước trong ngày
  Future<StepData> getTodaySteps() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'STEPS',
      where: "date = ?",
      whereArgs: [DateTime.now().toIso8601String().substring(0, 10)],
    );

    if (maps.isNotEmpty) {
      logger.i('Today steps: ${maps.first['steps']}');
      return StepData.fromMap(maps.first);
    } else {
      logger.i('No steps today');
      return StepData(
        id: DateTime.now().toIso8601String(),
        steps: 0,
        date: DateTime.now(),
      );
    }
  }

  // Lấy số bước trong tuần
  Future<List<StepData>> getWeeklySteps() async {
    // Lấy ngày đầu tuần (thứ 2)
    final db = await database;
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final startDate = now.subtract(Duration(days: dayOfWeek - 1));
    final endDate = startDate.add(Duration(days: 6));

    final List<Map<String, dynamic>> maps = await db.query(
      'STEPS',
      where: "date BETWEEN ? AND ?",
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: "date ASC",
    );

    // Tạo list đủ 7 ngày, điền 0 cho ngày chưa có data
    List<StepData> weeklySteps = List.generate(7, (index) {
      final date = startDate.add(Duration(days: index));
      final mapEntry = maps.firstWhere(
        (map) => map['date'] == date.toIso8601String().split('T')[0],
        orElse: () => {
          'id': -1,
          'date': date.toIso8601String().split('T')[0],
          'time': 0,
          'steps': 0,
          'goal_achieved': 0,
        },
      );
      return StepData.fromMap(mapEntry);
    });

    return weeklySteps;
  }

  // Lấy số bước trong tháng
  Future<List<StepData>> getMonthlySteps(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'STEPS',
      where: "strftime('%Y-%m', date) = ?",
      whereArgs: ['$year-${month.toString().padLeft(2, '0')}'],
    );

    return List.generate(maps.length, (i) => StepData.fromMap(maps[i]));
  }

  // Lấy tổng số bước trong năm theo từng tháng
  Future<Map<int, int>> getYearlySteps(int year) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT strftime('%m', date) as month, SUM(steps) as total
      FROM steps 
      WHERE strftime('%Y', date) = ?
      GROUP BY strftime('%m', date)
    ''', ['$year']);

    Map<int, int> yearlySteps = {};
    for (var row in result) {
      yearlySteps[int.parse(row['month'])] = row['total'];
    }
    return yearlySteps;
  }

  // Xóa bảng
  Future<void> deleteTable() async {
    Database? db = await database;
    await db.delete('steps');
    db = null;
    logger.d('Deleted table steps');
  }
}
