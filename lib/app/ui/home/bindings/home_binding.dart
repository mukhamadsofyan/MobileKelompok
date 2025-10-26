import 'package:get/get.dart';
import '../../../controllers/org_controller_backup.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrgController());
    Get.lazyPut(() => HomeController());
  }
}
