import 'package:get/get.dart';
import '../../../controllers/programkerja_controller.dart';

class ProgramKerjaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProgramKerjaController());
  }
}
