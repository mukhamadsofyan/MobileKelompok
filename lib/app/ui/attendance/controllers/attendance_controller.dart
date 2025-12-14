import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import '../../../data/models/AgendaModel.dart';
import '../../../data/models/StrukturalModel.dart';

class AttendanceController extends GetxController {
  final SupabaseDB db = SupabaseDB();
  final AgendaOrganisasi agenda;

  AttendanceController({required this.agenda});

  var strukturalList = <Struktural>[].obs;
  var attendanceMap = <int, bool>{}.obs;
  var loading = true.obs;
  var isLocked = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔐 GUARD WAJIB (FIX CRASH)
    if (agenda.id == null) {
      Get.back();
      Get.snackbar(
        "Error",
        "Agenda tidak memiliki ID",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    loadAttendanceData();
  }

  /// 🔄 Load data absensi
  Future<void> loadAttendanceData() async {
    if (agenda.id == null) return;

    loading.value = true;

    // Ambil struktural
    final list = await db.getStruktural();
    strukturalList.assignAll(list);

    // Ambil absensi
    final rows = await db.getAttendanceByAgenda(agenda.id!);

    final map = <int, bool>{};
    for (var row in rows) {
      final sid = row['struktural_id'];
      if (sid != null) {
        map[sid as int] =
            (row['present'] == 1 || row['present'] == true);
      }
    }

    attendanceMap.assignAll(map);

    // Default false
    for (var s in strukturalList) {
      if (s.id != null) {
        attendanceMap.putIfAbsent(s.id!, () => false);
      }
    }

    // Auto lock jika lewat tanggal
    isLocked.value = agenda.date.isBefore(DateTime.now());

    loading.value = false;
  }

  /// 🔁 Refresh
  Future<void> refreshData() async {
    await loadAttendanceData();
  }

  /// 👆 Toggle hadir
  Future<void> toggleAttendance(int? strukturalId) async {
    if (isLocked.value) return;
    if (strukturalId == null || agenda.id == null) return;

    final current = attendanceMap[strukturalId] ?? false;
    attendanceMap[strukturalId] = !current;

    await db.markAttendance(
      agenda.id!,
      strukturalId,
      !current,
    );
  }

  /// 🔐 Kunci absensi
  void lockAttendance() {
    isLocked.value = true;

    Get.snackbar(
      'Absensi Dikunci',
      'Data kehadiran telah dikunci.',
      backgroundColor: Colors.teal.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.lock, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// 🔓 Admin buka kunci
  Future<void> unlockAttendance() async {
    isLocked.value = false;
    await refreshData();

    Get.snackbar(
      'Kunci Dibuka',
      'Absensi bisa diedit kembali.',
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.lock_open, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
