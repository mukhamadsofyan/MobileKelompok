import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  // ============================
  // STATE
  // ============================
  var isLoading = false.obs;
  var userRole = "member".obs;

  // ============================
  // GETTER
  // ============================
  bool get isAdmin => userRole.value == "admin";
  bool get isMember => userRole.value == "member";
  bool get isLoggedIn => supabase.auth.currentSession != null;

  /// 🔑 PENTING
  /// Dipakai untuk membatasi absensi:
  /// user hanya bisa absensi dirinya sendiri
  String get userId => supabase.auth.currentUser?.id ?? "";

  // ============================
  // INIT → SYNC ROLE FROM SESSION
  // ============================
  @override
  void onInit() {
    super.onInit();
    _loadRoleFromSession();
  }

  void _loadRoleFromSession() {
    final session = supabase.auth.currentSession;
    final role = session?.user.userMetadata?['role'] ?? 'member';
    userRole.value = role.toLowerCase().trim();
  }

  // ============================
  // REGISTER
  // ============================
  Future<bool> register(String email, String password) async {
    try {
      isLoading.value = true;

      final cleanEmail = email.trim().toLowerCase();

      final res = await supabase.auth.signUp(
        email: cleanEmail,
        password: password.trim(),
        data: {
          "role": "member", // default role
        },
      );

      if (res.user == null) throw "Registrasi gagal";

      Get.snackbar(
        "Sukses",
        "Registrasi berhasil. Silakan login.",
      );
      Get.offAllNamed('/login');

      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // LOGIN
  // ============================
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final role =
          res.session?.user.userMetadata?['role'] ?? 'member';

      userRole.value = role.toLowerCase().trim();

      Get.snackbar(
        "Sukses",
        "Login sebagai ${userRole.value}",
      );
      Get.offAllNamed('/home');

      return true;
    } catch (e) {
      Get.snackbar(
        "Login Gagal",
        e.toString(),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    await supabase.auth.signOut();

    // reset state
    userRole.value = "member";
    isLoading.value = false;

    Get.offAllNamed('/login');
  }
}
