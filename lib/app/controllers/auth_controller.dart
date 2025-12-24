import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  // ============================
  // STATE
  // ============================
  var isLoading = false.obs;
  var userRole = "member".obs;
  var username = "".obs; // ✅ USERNAME STATE

  // ============================
  // GETTER
  // ============================
  bool get isAdmin => userRole.value == "admin";
  bool get isMember => userRole.value == "member";
  bool get isLoggedIn => supabase.auth.currentSession != null;

  /// Dipakai untuk pembatasan absensi
  String get userId => supabase.auth.currentUser?.id ?? "";

  String get currentUsername => username.value;

  // ============================
  // INIT → SYNC SESSION
  // ============================
  @override
  void onInit() {
    super.onInit();
    _syncFromSession();
  }

  void _syncFromSession() {
    final session = supabase.auth.currentSession;
    final metadata = session?.user.userMetadata ?? {};

    userRole.value =
        (metadata['role'] ?? 'member').toString().toLowerCase().trim();

    username.value =
        (metadata['username'] ?? '').toString().trim();
  }

  // ============================
  // REGISTER (USERNAME + EMAIL + PASSWORD)
  // ============================
  Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      isLoading.value = true;

      final cleanEmail = email.trim().toLowerCase();
      final cleanUsername = username.trim();

      if (cleanUsername.length < 3) {
        throw "Username minimal 3 karakter";
      }

      final res = await supabase.auth.signUp(
        email: cleanEmail,
        password: password.trim(),
        data: {
          "role": "member",
          "username": cleanUsername, // ✅ SIMPAN USERNAME
        },
      );

      if (res.user == null) {
        throw "Registrasi gagal";
      }

      Get.snackbar(
        "Sukses",
        "Registrasi berhasil. Silakan login.",
      );

      Get.offAllNamed('/login');
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll("Exception: ", ""),
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

      final metadata = res.session?.user.userMetadata ?? {};

      userRole.value =
          (metadata['role'] ?? 'member').toString().toLowerCase().trim();

      username.value =
          (metadata['username'] ?? '').toString().trim();

      Get.snackbar(
        "Sukses",
        "Login sebagai ${userRole.value}",
      );

      Get.offAllNamed('/home');
      return true;
    } catch (e) {
      Get.snackbar(
        "Login Gagal",
        e.toString().replaceAll("Exception: ", ""),
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

    userRole.value = "member";
    username.value = "";
    isLoading.value = false;

    Get.offAllNamed('/login');
  }
}
