import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/activity.dart';
import '../models/member.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'orgtrack.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT,
        photoPath TEXT,
        completed INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE members(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        active INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activityId INTEGER,
        memberId INTEGER,
        present INTEGER,
        FOREIGN KEY(activityId) REFERENCES activities(id),
        FOREIGN KEY(memberId) REFERENCES members(id)
      )
    ''');
  }

  // Activities CRUD
  Future<int> insertActivity(Activity a) async {
    final client = await db;
    return client.insert('activities', a.toMap());
  }

  Future<List<Activity>> getActivities() async {
    final client = await db;
    final res = await client.query('activities', orderBy: 'date DESC');
    return res.map((m) => Activity.fromMap(m)).toList();
  }

  Future<int> updateActivity(Activity a) async {
    final client = await db;
    return client.update('activities', a.toMap(), where: 'id=?', whereArgs: [a.id]);
  }

  Future<int> deleteActivity(int id) async {
    final client = await db;
    await client.delete('attendance', where: 'activityId=?', whereArgs: [id]);
    return client.delete('activities', where: 'id=?', whereArgs: [id]);
  }

  // Members CRUD
  Future<int> insertMember(Member m) async {
    final client = await db;
    return client.insert('members', m.toMap());
  }

  Future<List<Member>> getMembers() async {
    final client = await db;
    final res = await client.query('members', orderBy: 'name');
    return res.map((m) => Member.fromMap(m)).toList();
  }

  Future<int> updateMember(Member m) async {
    final client = await db;
    return client.update('members', m.toMap(), where: 'id=?', whereArgs: [m.id]);
  }

  Future<int> deleteMember(int id) async {
    final client = await db;
    await client.delete('attendance', where: 'memberId=?', whereArgs: [id]);
    return client.delete('members', where: 'id=?', whereArgs: [id]);
  }

  // Attendance
  Future<int> markAttendance(int activityId, int memberId, bool present) async {
    final client = await db;
    // check if exists
    final res = await client.query('attendance',
        where: 'activityId=? AND memberId=?', whereArgs: [activityId, memberId]);
    if (res.isEmpty) {
      return client.insert('attendance', {
        'activityId': activityId,
        'memberId': memberId,
        'present': present ? 1 : 0,
      });
    } else {
      return client.update('attendance', {'present': present ? 1 : 0},
          where: 'activityId=? AND memberId=?', whereArgs: [activityId, memberId]);
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceForActivity(int activityId) async {
    final client = await db;
    final res = await client.rawQuery('''
      SELECT a.id as memberId, a.name, at.present
      FROM members a
      LEFT JOIN attendance at ON a.id = at.memberId AND at.activityId = ?
    ''', [activityId]);
    return res;
  }
}
