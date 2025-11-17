import 'package:get/get.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import 'package:orgtrack/app/data/models/program_kerja.dart';

class ProgramKerjaSupabaseController extends GetxController {
  final SupabaseDB db = SupabaseDB();

  var loading = false.obs;
  var programList = <ProgramKerja>[].obs;

  Future<void> fetchProgramKerja(int bidangId) async {
    try {
      loading.value = true;

      final data = await db.getProgramKerja(bidangId: bidangId);
      programList.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      loading.value = false;
    }
  }
}
