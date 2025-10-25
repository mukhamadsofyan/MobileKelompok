import 'package:get/get.dart';
import '../../../controllers/org_controller.dart';

class OrgBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan controller agar bisa diakses di seluruh bagian yang butuh OrgController
    Get.lazyPut(() => OrgController());
  }
}
