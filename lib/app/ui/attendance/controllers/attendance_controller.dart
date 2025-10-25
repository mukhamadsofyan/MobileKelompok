import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/db/db_helper.dart';
import '../../../data/models/AgendaModel.dart';
import '../../../data/models/StrukturalModel.dart';

class AttendanceController extends GetxController {
  final DBHelper db = DBHelper();
  final AgendaOrganisasi agenda;

  AttendanceController({required this.agenda});

  var strukturalList = <Struktural>[].obs;
  var attendanceMap = <int, bool>{}.obs;
  var loading = true.obs;
  var isLocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendanceData();
  }

  /// 🔄 Muat ulang data absensi dari database
  Future<void> loadAttendanceData() async {
    loading.value = true;

    final list = await db.getStruktural();
    strukturalList.assignAll(list);

    final rows = await db.getAttendanceByAgenda(agenda.id!);
    final map = <int, bool>{};
    for (var row in rows) {
      map[row['struktural_id'] as int] = (row['present'] as int) == 1;
    }
    attendanceMap.assignAll(map);

    // Default jika belum ada data
    for (var s in list) {
      attendanceMap.putIfAbsent(s.id!, () => false);
    }

    // Auto-lock jika tanggal agenda sudah lewat
    final now = DateTime.now();
    if (agenda.date != null && agenda.date!.isBefore(now)) {
      isLocked.value = true;
    }

    loading.value = false;
  }

  /// ✅ Toggle hadir/tidak hadir + auto-refresh
  Future<void> toggleAttendance(int strukturalId) async {
    if (isLocked.value) return; // Jika terkunci, tidak bisa ubah

    final current = attendanceMap[strukturalId] ?? false;
    attendanceMap[strukturalId] = !current;

    // Simpan ke database
    await db.markAttendance(agenda.id!, strukturalId, !current);

    // Auto-refresh data biar sinkron
    Future.delayed(const Duration(milliseconds: 250), () async {
      await refreshData();
    });
  }

  /// 🔁 Refresh manual atau otomatis
  Future<void> refreshData() async {
    await loadAttendanceData();
  }

  /// 🔐 Kunci absensi (simpan & nonaktifkan)
  void lockAttendance() {
    isLocked.value = true;
    Get.snackbar(
      'Absensi Dikunci',
      'Data kehadiran sudah disimpan dan dikunci.',
      backgroundColor: Colors.teal.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.lock_rounded, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 🔓 Buka kunci absensi (admin override)
  void unlockAttendance() async {
    isLocked.value = false;

    // 🔁 Auto-refresh setelah buka kunci agar UI langsung aktif
    await refreshData();

    Get.snackbar(
      'Kunci Dibuka',
      'Admin berhasil membuka absensi. Sekarang data bisa diedit kembali.',
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
