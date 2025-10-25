import 'package:get/get.dart';
import '../controllers/struktur_controller.dart';

class StrukturBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StrukturalController>(() => StrukturalController());
  }
}
