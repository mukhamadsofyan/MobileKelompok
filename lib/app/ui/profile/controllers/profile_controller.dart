import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthController>();

  RxString email = "".obs;
  RxString role = "".obs;

  @override
  void onInit() {
    super.onInit();

    email.value = auth.supabase.auth.currentUser?.email ?? '-';
    role.value = auth.userRole.value;
  }

  bool get isAdmin => role.value == "admin";
}
