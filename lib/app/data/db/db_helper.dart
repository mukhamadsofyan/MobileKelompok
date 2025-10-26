import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/AgendaModel.dart';
import '../models/KeuanganModel.dart';
import '../models/StrukturalModel.dart';
import '../models/program_kerja.dart';
import '../models/activity.dart';

class DBHelper {
  static Database? _db;

  static const int _dbVersion = 4;
  static const String _dbName = 'orgtrack.db';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ================= CREATE DATABASE =================
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE program_kerja(
        id INTEGER PRIMARY KEY,
        bidangId INTEGER,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        tanggal TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS keuangan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS struktural (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS agenda_organisasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        agenda_id INTEGER NOT NULL,
        struktural_id INTEGER NOT NULL,
        present INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ================= UPGRADE DATABASE =================
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS program_kerja (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          deskripsi TEXT,
          tanggalMulai TEXT,
          tanggalSelesai TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS keuangan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          date TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS struktural (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          role TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS agenda_organisasi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          date TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          agenda_id INTEGER NOT NULL,
          struktural_id INTEGER NOT NULL,
          present INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  // ================= CRUD ACTIVITIES =================
  Future<List<Activity>> getActivities() async {
    final db = await database;
    final rows = await db.query('activities', orderBy: 'id DESC');
    return rows.map((r) => Activity.fromMap(r)).toList();
  }

  Future<int> insertActivity(Activity a) async {
    final db = await database;
    return await db.insert('activities', a.toMap());
  }

  // ================= CRUD PROGRAM KERJA =================
  Future<List<ProgramKerja>> getProgramKerja({int? bidangId}) async {
    final db = await database;
    List<Map<String, dynamic>> rows;
    if (bidangId != null) {
      rows = await db.query(
        'program_kerja',
        where: 'bidangId=?',
        whereArgs: [bidangId],
        orderBy: 'tanggalMulai DESC',
      );
    } else {
      rows = await db.query('program_kerja', orderBy: 'tanggal DESC');
    }
    return rows.map((r) => ProgramKerja.fromMap(r)).toList();
  }

  Future<int> insertProgramKerja(ProgramKerja p) async {
    final db = await database;
    return await db.insert('program_kerja', p.toMap());
  }

  Future<int> updateProgramKerja(ProgramKerja p) async {
    final db = await database;
    return await db.update(
      'program_kerja',
      p.toMap(),
      where: 'id=?',
      whereArgs: [p.id],
    );
  }

  Future<int> deleteProgramKerja(int id) async {
    final db = await database;
    return await db.delete('program_kerja', where: 'id=?', whereArgs: [id]);
  }

  // ================= CRUD KEUANGAN =================
  Future<List<Keuanganmodel>> getKeuangan() async {
    final db = await database;
    final rows = await db.query('keuangan', orderBy: 'date DESC');
    return rows.map((r) => Keuanganmodel.fromMap(r)).toList();
  }

  // --- Tambah data baru ---
  Future<int> insertKeuangan(Keuanganmodel k) async {
    final db = await database;
    return await db.insert('keuangan', k.toMap());
  }

  // --- Update data (buat fitur edit) ---
  Future<int> updateKeuangan(Keuanganmodel k) async {
    final db = await database;
    return await db.update(
      'keuangan',
      k.toMap(),
      where: 'id = ?',
      whereArgs: [k.id],
    );
  }

  // --- Hapus data berdasarkan id ---
  Future<int> deleteKeuangan(int id) async {
    final db = await database;
    return await db.delete('keuangan', where: 'id=?', whereArgs: [id]);
  }

  // ================= CRUD STRUKTURAL =================
  Future<List<Struktural>> getStruktural() async {
    final db = await database;
    final rows = await db.query('struktural', orderBy: 'id DESC');
    return rows.map((r) => Struktural.fromMap(r)).toList();
  }

  Future<int> insertStruktural(Struktural s) async {
    final db = await database;
    return await db.insert('struktural', s.toMap());
  }

  Future<int> updateStruktural(Struktural s) async {
    final db = await database;
    return await db
        .update('struktural', s.toMap(), where: 'id=?', whereArgs: [s.id]);
  }

  Future<int> deleteStruktural(int id) async {
    final db = await database;
    return await db.delete('struktural', where: 'id=?', whereArgs: [id]);
  }

  Future<Struktural> getStrukturalById(int id) async {
    final db = await database;
    final result = await db.query('struktural', where: 'id=?', whereArgs: [id]);
    return Struktural.fromMap(result.first);
  }

  // ================= CRUD AGENDA ORGANISASI =================
  Future<List<AgendaOrganisasi>> getAgendaOrganisasi() async {
    final db = await database;
    final result = await db.query('agenda_organisasi', orderBy: 'date DESC');
    return result.map((r) => AgendaOrganisasi.fromMap(r)).toList();
  }

  Future<int> insertAgenda(AgendaOrganisasi a) async {
    final db = await database;
    return await db.insert('agenda_organisasi', a.toMap());
  }

  Future<int> updateAgenda(AgendaOrganisasi a) async {
    final db = await database;
    return await db.update(
      'agenda_organisasi',
      a.toMap(),
      where: 'id=?',
      whereArgs: [a.id],
    );
  }

  Future<int> deleteAgenda(int id) async {
    final db = await database;
    // Hapus agenda dan sekaligus absensinya
    await deleteAttendanceByAgenda(id);
    return await db.delete('agenda_organisasi', where: 'id=?', whereArgs: [id]);
  }

  // ================= CRUD ABSENSI =================
  Future<List<Map<String, dynamic>>> getAttendanceByAgenda(int agendaId) async {
    final db = await database;
    final rows = await db
        .query('attendance', where: 'agenda_id=?', whereArgs: [agendaId]);
    return rows;
  }

  Future<int> markAttendance(
      int agendaId, int strukturalId, bool present) async {
    final db = await database;

    final existing = await db.query(
      'attendance',
      where: 'agenda_id=? AND struktural_id=?',
      whereArgs: [agendaId, strukturalId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'attendance',
        {'present': present ? 1 : 0},
        where: 'agenda_id=? AND struktural_id=?',
        whereArgs: [agendaId, strukturalId],
      );
    } else {
      return await db.insert('attendance', {
        'agenda_id': agendaId,
        'struktural_id': strukturalId,
        'present': present ? 1 : 0,
      });
    }
  }

  Future<int> deleteAttendanceByAgenda(int agendaId) async {
    final db = await database;
    return await db
        .delete('attendance', where: 'agenda_id=?', whereArgs: [agendaId]);
  }
}
