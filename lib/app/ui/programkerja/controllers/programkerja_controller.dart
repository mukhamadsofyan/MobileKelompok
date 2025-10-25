import 'package:get/get.dart';
import '../../../data/db/db_helper.dart';
import '../../../data/models/program_kerja.dart';


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
      programList.assignAll(await _db.getProgramKerja());
    } finally {
      loading.value = false;
    }
  }

  Future<void> addProgram(ProgramKerja p) async {
    await _db.insertProgramKerja(p);
    await loadPrograms();
  }

  Future<void> deleteProgram(int id) async {
    await _db.deleteProgramKerja(id);
    await loadPrograms();
  }
}
