
// services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../remiderModel.dart';


class DatabaseService {
  static Database? _database;
  static const String tableName = 'reminders';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'reminders.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        dateTime INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL,
        priority TEXT NOT NULL
      )
    ''');
  }

  static Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert(tableName, reminder.toMap());
  }

  static Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'dateTime ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  static Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      tableName,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  static Future<void> deleteReminder(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Reminder>> getUpcomingReminders() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'dateTime > ? AND isCompleted = 0',
      whereArgs: [now],
      orderBy: 'dateTime ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }
}

