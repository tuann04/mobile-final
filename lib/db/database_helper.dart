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
      times INTEGER NOT NULL,
      distance REAL,
      calories REAL
    );
    ''',
    // 1 step = 0.75 meters = calories 0.05
    // steps around 800-1200
    '''
    INSERT INTO steps (id, steps, date, times, distance, calories)
    VALUES
      ('2025-01-01', 1000, '2025-01-01', 3000, 750.0, 50.0),
      ('2025-01-02', 950, '2025-01-02', 2700, 712.5, 47.5),
      ('2025-01-03', 1050, '2025-01-03', 3100, 787.5, 52.5),
      ('2025-01-04', 1100, '2025-01-04', 3300, 825.0, 55.0),
      ('2025-01-05', 1200, '2025-01-05', 3600, 900.0, 60.0),
      ('2025-01-06', 800, '2025-01-06', 2400, 600.0, 40.0),
      ('2025-01-07', 950, '2025-01-07', 2850, 712.5, 47.5),
      ('2025-01-08', 1000, '2025-01-08', 3000, 750.0, 50.0),
      ('2025-01-09', 1050, '2025-01-09', 3150, 787.5, 52.5),
      ('2025-01-10', 1100, '2025-01-10', 3300, 825.0, 55.0),
      ('2025-01-11', 1200, '2025-01-11', 3600, 900.0, 60.0),
      ('2025-01-12', 800, '2025-01-12', 2400, 600.0, 40.0),
      ('2025-01-13', 950, '2025-01-13', 2850, 712.5, 47.5),
      ('2025-01-14', 1000, '2025-01-14', 3000, 750.0, 50.0),
      ('2025-01-15', 900, '2025-01-15', 2900, 745.0, 45.5);
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
