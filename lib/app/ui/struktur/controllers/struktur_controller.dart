import 'package:get/get.dart';
import '../../../data/db/db_helper.dart';
import '../../../data/models/StrukturalModel.dart';

class StrukturalController extends GetxController {
  final DBHelper _db = DBHelper();

  var list = <Struktural>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Memuat semua data struktural
  Future<void> loadAll() async {
    try {
      loading.value = true;
      final data = await _db.getStruktural();
      list.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data struktural: $e',
          snackPosition: SnackPosition.TOP);
    } finally {
      loading.value = false;
    }
  }

  /// Menambahkan data struktural baru
  Future<void> addStruktural(String name, String role) async {
    try {
      await _db.insertStruktural(Struktural(name: name, role: role));
      await loadAll(); // Auto refresh
      // Snackbar DIHAPUS supaya tidak dobel
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambah data: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Memperbarui data struktural
  Future<void> updateStruktural(Struktural s) async {
    try {
      await _db.updateStruktural(s);
      await loadAll(); // Auto refresh
      // Snackbar DIHAPUS supaya tidak dobel
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui data: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Menghapus data berdasarkan ID
  Future<void> deleteStrukturalById(int id) async {
    try {
      await _db.deleteStruktural(id);
      await loadAll(); // Auto refresh
      // Snackbar DIHAPUS supaya tidak dobel
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Fungsi manual refresh, misalnya untuk fitur pull-to-refresh
  Future<void> refreshData() async {
    await loadAll();
  }
}
