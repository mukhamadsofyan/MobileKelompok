import 'package:get/get.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_controller.dart';

class ProgramKerjaBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan hanya di-initialize sekali
    if (!Get.isRegistered<ProgramController>()) {
      Get.put<ProgramController>(ProgramController());
    }
  }
}
