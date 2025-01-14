import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// logger
import 'package:logger/logger.dart';

final logger = Logger();

class DatabaseHelper {
  static final _databaseName = "appDatabase.db";
  static final _databaseVersion = 1;

  static final tableSteps = 'STEPS';
  // Thêm tên các bảng khác ở đây

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnAge = 'age';
  static final columnSteps = 'steps';
  static final columnDate = 'date';
  static final columnDistance = 'distance';
  static final columnCalories = 'calories';
  // Thêm các cột khác ở đây

  // make this a singleton class
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  factory DatabaseHelper() => instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tạo bảng steps
    await db.execute('''
      CREATE TABLE $tableSteps (
        $columnId TEXT PRIMARY KEY,
        $columnSteps INTEGER NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnDistance REAL,
        $columnCalories REAL
      )
    ''');

    // Tạo các bảng khác ở đây
    // await db.execute('''
    //   CREATE TABLE $tableActivities (
    //     ...
    //   )
    // ''');
  }
}
