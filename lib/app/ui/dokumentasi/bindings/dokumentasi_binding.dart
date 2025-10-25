import 'package:get/get.dart';
import '../controllers/dokumentasi_controller.dart';

class DokumentasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokumentasiController>(() => DokumentasiController());
  }
}
