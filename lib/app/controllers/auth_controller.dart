import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var userRole = "member".obs;

  bool get isAdmin => userRole.value == "admin";
  bool get isMember => userRole.value == "member";

  // ============================
  //  REGISTER RETURN BOOL
  // ============================
  Future<bool> register(String email, String password) async {
    try {
      isLoading.value = true;

      final cleanEmail = email.trim().replaceAll(' ', '').toLowerCase();

      final res = await supabase.auth.signUp(
        email: cleanEmail,
        password: password.trim(),
        data: {"role": "member"},
      );

      if (res.user == null) throw "Registrasi gagal";

      Get.snackbar("Sukses", "Registrasi berhasil. Silakan login.");
      Get.offAllNamed('/login');

      return true; // ✔ sukses
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false; // ✔ gagal
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  //  LOGIN RETURN BOOL
  // ============================
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final role = res.session?.user.userMetadata?['role'] ?? 'member';
      userRole.value = role;

      Get.snackbar("Sukses", "Login sebagai $role");
      Get.offAllNamed('/home');

      return true; // ✔ sukses
    } catch (e) {
      Get.snackbar("Login Gagal", e.toString());
      return false; // ✔ gagal → SHAKE ANIMATION AKTIF
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login');
  }

  bool get isLoggedIn => supabase.auth.currentSession != null;
}
