import 'package:get/get.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import 'package:orgtrack/app/data/models/program_kerja.dart';

class ProgramController extends GetxController {
  var programList = <ProgramKerja>[].obs;
  final DBHelper db = DBHelper();

  @override
  void onInit() {
    super.onInit();
    loadPrograms();
  }

  // Load semua program dari database
  Future<void> loadPrograms() async {
    final data = await db.getProgramKerja();
    programList.assignAll(data);
  }

  // Tambah program ke database
  Future<void> addProgram(ProgramKerja program) async {
    await db.insertProgramKerja(program);
    await loadPrograms();
  }

  // Update program di database
  Future<void> updateProgram(ProgramKerja program) async {
    await db.updateProgramKerja(program);
    await loadPrograms();
  }

  // Hapus program dari database
  Future<void> deleteProgram(int id) async {
    await db.deleteProgramKerja(id);
    await loadPrograms();
  }

  // Filter berdasarkan bidang
  List<ProgramKerja> getByBidang(int bidangId) {
    return programList.where((p) => p.bidangId == bidangId).toList();
  }
}
