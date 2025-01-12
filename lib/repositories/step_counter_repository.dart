import 'package:health_app/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    logger.i('${data.toMap()}');
  }

  // Lấy số bước trong ngày
  Future<StepData> getTodaySteps() async {
    // log ra database
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'STEPS',
      where: "date = ?",
      whereArgs: [DateTime.now().toIso8601String().substring(0, 10)],
    );

    logger.i('${maps}');

    if (maps.isNotEmpty) {
      return StepData.fromMap(maps.first);
    } else {
      return StepData(
        id: DateTime.now().toIso8601String(),
        steps: 0,
        date: DateTime.now(),
      );
    }
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
    await db.delete('STEPS');
    db = null;
    logger.i('Deleted table steps');
  }

  // recreate table
  Future<void> recreateTable() async {
    Database? db = await database;
    await db.execute('DROP TABLE IF EXISTS STEPS');
    await db.execute('''
      CREATE TABLE STEPS (
        id TEXT PRIMARY KEY,
        steps INTEGER NOT NULL,
        date TEXT NOT NULL,
        distance REAL,
        calories REAL
      )
    ''');
    db = null;
    logger.i('Recreated table steps');
  }
}
