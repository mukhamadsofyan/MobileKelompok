import 'package:get/get.dart';
import '../data/db/db_helper.dart';
import '../data/models/program_kerja.dart';

class ProgramKerjaController extends GetxController {
  final DBHelper _db = DBHelper();

  var programList = <ProgramKerja>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    loading.value = true;
    try {
      final db = await _db.database;
      final result = await db.query('program_kerja', orderBy: 'tanggalMulai DESC');
      programList.assignAll(result.map((e) => ProgramKerja.fromMap(e)).toList());
    } catch (e) {
      print('Error load programs: $e');
    } finally {
      loading.value = false;
    }
  }

Future<void> addProgram(ProgramKerja p) async {
  final db = await _db.database;
  await db.insert('program_kerja', p.toMap());
  await loadPrograms();
}

Future<void> updateProgram(ProgramKerja p) async {
  final db = await _db.database;
  await db.update(
    'program_kerja',
    p.toMap(),
    where: 'id = ?',
    whereArgs: [p.id],
  );
  await loadPrograms();
}


  Future<void> deleteProgram(int id) async {
    final db = await _db.database;
    await db.delete('program_kerja', where: 'id = ?', whereArgs: [id]);
    await loadPrograms();
  }
}
