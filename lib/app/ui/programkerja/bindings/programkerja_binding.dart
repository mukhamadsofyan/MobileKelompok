import 'package:get/get.dart';
import '../controllers/programkerja_controller.dart';
import '../controllers/programkerja_dio.dart';
import '../controllers/program_kerja_mode.dart';

class ProgramKerjaBinding extends Bindings {
  @override
  void dependencies() {
    // Jika controller belum diinisialisasi, akan dipasang
    Get.lazyPut<ProgramControllerHttp>(() => ProgramControllerHttp());
    Get.lazyPut<ProgramControllerDio>(() => ProgramControllerDio());
    Get.lazyPut<ModeController>(() => ModeController());
  }
}
