import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  LocalDatabaseService({
    DatabaseFactory? databaseFactoryInstance,
    String? databasePath,
  })  : _databaseFactoryInstance = databaseFactoryInstance,
        _databasePath = databasePath;

  static final LocalDatabaseService instance = LocalDatabaseService();

  static const String _databaseName = 'incident_management.db';
  static const int _databaseVersion = 2;

  final DatabaseFactory? _databaseFactoryInstance;
  final String? _databasePath;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final factory = _databaseFactoryInstance ?? databaseFactory;
    final path = _databasePath ??
        join(
          await getDatabasesPath(),
          _databaseName,
        );

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE incidents (
        id TEXT PRIMARY KEY,
        incident_code TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        sap_order TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        department_at TEXT NOT NULL,
        resolution_type TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        deleted_at TEXT,
        deleted_reason TEXT,
        deleted_by TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE incident_logs (
        id TEXT PRIMARY KEY,
        incident_id TEXT NOT NULL,
        action_type TEXT NOT NULL,
        description TEXT NOT NULL,
        old_status TEXT,
        new_status TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE incident_logs (
          id TEXT PRIMARY KEY,
          incident_id TEXT NOT NULL,
          action_type TEXT NOT NULL,
          description TEXT NOT NULL,
          old_status TEXT,
          new_status TEXT,
          created_by TEXT NOT NULL,
          created_at TEXT NOT NULL,
          sync_status TEXT NOT NULL
        )
      ''');
    }
  }
}
