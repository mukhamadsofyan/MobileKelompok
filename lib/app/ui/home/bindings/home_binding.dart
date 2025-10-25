import 'package:get/get.dart';
import '../../../../app/controllers/org_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrgController());
    Get.lazyPut(() => HomeController());
  }
}
