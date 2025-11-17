import 'package:get/get.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_controller.dart';

class ProgramKerjaBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProgramKerjaSupabaseController(), permanent: true);
  }
}
