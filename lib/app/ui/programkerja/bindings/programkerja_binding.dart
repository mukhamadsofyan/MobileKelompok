import 'package:get/get.dart';
import '../controllers/programkerja_controller.dart';
import '../controllers/programkerja_dio.dart';
import '../controllers/program_kerja_mode.dart';

class ProgramKerjaBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProgramControllerHttp());
    Get.put(ProgramControllerDio());
    Get.put(ModeController());
  }
}

