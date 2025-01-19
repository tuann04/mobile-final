import 'package:health_app/utils/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class DatabaseHelper {
  final _databaseName = "appDatabase.db";
  final _databaseVersion = 1;

  final initialScript = [
    '''
    CREATE TABLE steps (
      id TEXT PRIMARY KEY,
      steps INTEGER NOT NULL,
      date DATE NOT NULL,
      duration INTEGER NOT NULL,
      distance REAL,
      calories REAL
    );
    ''',
    // 1 step = 0.75 meters = calories 0.05
    // steps around 800-1200
    '''
    INSERT INTO steps (id, steps, date, duration, distance, calories)
    VALUES
      ('2025-01-01', 100, '2025-01-01', 300, 75.0, 5.0),
      ('2025-01-02', 95, '2025-01-02', 270, 71.25, 4.75),
      ('2025-01-03', 105, '2025-01-03', 310, 78.75, 5.25),
      ('2025-01-04', 110, '2025-01-04', 330, 82.5, 5.5),
      ('2025-01-05', 120, '2025-01-05', 360, 90.0, 6.0),
      ('2025-01-06', 80, '2025-01-06', 240, 60.0, 4.0),
      ('2025-01-07', 95, '2025-01-07', 285, 71.25, 4.75),
      ('2025-01-08', 100, '2025-01-08', 300, 75.0, 5.0),
      ('2025-01-09', 105, '2025-01-09', 315, 78.75, 5.25),
      ('2025-01-10', 110, '2025-01-10', 330, 82.5, 5.5),
      ('2025-01-11', 120, '2025-01-11', 360, 90.0, 6.0),
      ('2025-01-12', 80, '2025-01-12', 240, 60.0, 4.0),
      ('2025-01-13', 95, '2025-01-13', 285, 71.25, 4.75),
      ('2025-01-14', 100, '2025-01-14', 300, 75.0, 5.0),
      ('2025-01-15', 90, '2025-01-15', 290, 74.5, 4.55),
      ('2025-01-16', 105, '2025-01-16', 305, 75.0, 5.0),
      ('2025-01-17', 95, '2025-01-17', 295, 74.5, 4.95),
      ('2025-01-18', 100, '2025-01-18', 300, 75.0, 5.0),
      ('2025-01-19', 105, '2025-01-19', 315, 78.75, 5.25);
    ''',
  ];

  // make this a singleton class
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  factory DatabaseHelper() => instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      logger.i("_database is null, initializing");
      _database = await _initDatabase();
    }

    logger.i("_database is not null, returning");
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    logger.i("_initDatabase working");
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database database, int version) async {
        logger.i("Creating database");
        await database.execute(initialScript[0]);
        await database.execute(initialScript[1]);
        // log data
        logAllData();
      },
    );
  }

  // log the database
  static Future<void> logAllData() async {
    logger.i("database helper Logging all data");
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('steps');
    for (var map in maps) {
      logger.i(map);
    }
  }

  // reset the database
  static Future<void> deleteAppDatabase() async {
    logger.i("Deleting database");
    String path = join(await getDatabasesPath(), instance._databaseName);
    await deleteDatabase(path);
    _database = await instance._initDatabase();
  }
}
