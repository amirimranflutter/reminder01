import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DbHelper{
  static late Database  _db;
  static Future<void> initDb() async
  {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
        join(dbPath, 'reminderS.db'),
        onCreate: (db, version) async {
          await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          isActive INTEGER,
          remindersTime TEXT,
          category TEXT
        )
            ''');
        },
        version: 1
    );
  }
    static Future<List<Map<String,dynamic>>> getReminder() async{
      return await _db.query('reminders');
}
static Future<Map<String,dynamic>?> getReminderById(int id) async{
    final List<Map<String,dynamic>> results=await _db.query('reminders',where: 'id=?',whereArgs: [id]);
    if(results.isNotEmpty){
      return results.first;
    }
    return null;
}
static Future<int> addReminder(Map<String,dynamic> reminder) async{
    return _db.insert('reminders' , reminder);
}
  static Future<int> updateReminder(int id,Map<String,dynamic> reminder) async{
    return _db.update('reminders' ,reminder, where: 'id=?',whereArgs: [id]);
  }
  static Future<int> deleteReminder(int id) async{
    return _db.delete('reminders' ,where:'id=?',whereArgs: [id]);
  }
  static Future<int> toggleReminder(int id , bool isActive) async{
    return _db.update('reminders' , {'isActive':isActive?1:0},where: 'id=?',whereArgs: [id]);
  }
}