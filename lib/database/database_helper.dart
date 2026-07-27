import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// مدیریت اتصال و ساخت جدول‌های SQLite.
/// طراحی به گونه‌ای است که هر عملیات از طریق Repository انجام می‌شود،
/// بنابراین مهاجرت بعدی به Postgres فقط نیازمند تعویض لایه‌ی Repository است
/// و مدل‌ها و بقیه‌ی اپ دست‌نخورده باقی می‌مانند.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mindload.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE loops (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT,
        project TEXT,
        person TEXT,
        due_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        ai_summary TEXT,
        source TEXT NOT NULL,
        attachments TEXT,
        metadata TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_loops_type ON loops(type)');
    await db.execute('CREATE INDEX idx_loops_status ON loops(status)');
    await db.execute('CREATE INDEX idx_loops_due_date ON loops(due_date)');
    await db.execute('CREATE INDEX idx_loops_category ON loops(category)');

    // برای چت با دستیار هوشمند (تاریخچه مکالمه)
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
