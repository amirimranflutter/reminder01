import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static late Database _db;

  static Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      // join(dbPath, 'reminders.db'),
      'reminders.db',
        version:2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          isActive INTEGER DEFAULT 1,
          reminderTime TEXT,
          category TEXT
        )
            ''');
      },
     // Increment this when schema changes
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE reminders ADD COLUMN isActive INTEGER DEFAULT 1',
          );
        }
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getReminder() async {
    return await _db.query('reminders');
  }

  static Future<Map<String, dynamic>?> getReminderById(int id) async {
    final List<Map<String, dynamic>> results = await _db.query(
      'reminders',
      where: 'id=?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  static Future<int> addReminder(Map<String, dynamic> reminder) async {
    print('reminder is =======>$reminder');
    return _db.insert('reminders', reminder);
  }

  static Future<int> updateReminder(
    int id,
    Map<String, dynamic> reminder,
  ) async {
    return _db.update('reminders', reminder, where: 'id=?', whereArgs: [id]);
  }
  static Future<int> deleteReminder(int id) async {
    return await _db.delete(
      'reminders',          // Your table name
      where: 'id = ?',      // WHERE condition
      whereArgs: [id],      // The actual value for the placeholder
    );
  }


















































  static Future<int> toggleReminder(int id, bool isActive) async {
    return _db.update(
      'reminders',
      {'isActive': isActive ? 1 : 0},
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
