import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';

import '../../../data/models/AgendaModel.dart';
import '../../../data/models/StrukturalModel.dart';
import '../../../controllers/auth_controller.dart';

class AttendanceController extends GetxController {
  final SupabaseDB db = SupabaseDB();
  final AgendaOrganisasi agenda;

  AttendanceController({required this.agenda});

  final strukturalList = <Struktural>[].obs;
  final attendanceMap = <int, bool>{}.obs;
  final loading = true.obs;
  final isLocked = false.obs;

  bool get isAdmin =>
      Get.find<AuthController>().userRole.value.toLowerCase().trim() == "admin";

  @override
  void onInit() {
    super.onInit();

    if (agenda.id == null) {
      // jangan bikin user "gabisa buka" tanpa alasan jelas
      Get.snackbar(
        "Error",
        "Agenda tidak valid",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    loadAttendanceData();
  }

  Future<void> loadAttendanceData() async {
    if (agenda.id == null) return;

    loading.value = true;

    final list = await db.getStruktural();
    strukturalList.assignAll(list);

    final rows = await db.getAttendanceByAgenda(agenda.id!);

    final map = <int, bool>{};
    for (final row in rows) {
      final sid = row['struktural_id'];
      if (sid != null) {
        map[sid as int] = (row['present'] == true || row['present'] == 1);
      }
    }

    attendanceMap.assignAll(map);

    for (final s in strukturalList) {
      if (s.id != null) {
        attendanceMap.putIfAbsent(s.id!, () => false);
      }
    }

    // auto lock kalau agenda sudah lewat
    isLocked.value = agenda.date.isBefore(DateTime.now());

    loading.value = false;
  }

  Future<void> toggleAttendance(int? strukturalId) async {
    // 🔒 USER READ ONLY (fix utama)
    if (!isAdmin) return;

    if (isLocked.value) return;
    if (strukturalId == null || agenda.id == null) return;

    final current = attendanceMap[strukturalId] ?? false;
    attendanceMap[strukturalId] = !current;

    await db.markAttendance(agenda.id!, strukturalId, !current);
  }

  void lockAttendance() {
    if (!isAdmin) return;

    isLocked.value = true;
    Get.snackbar(
      "Absensi Dikunci",
      "Data absensi telah dikunci",
      backgroundColor: Colors.teal.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.lock, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> unlockAttendance() async {
    if (!isAdmin) return;

    isLocked.value = false;
    await loadAttendanceData();

    Get.snackbar(
      "Kunci Dibuka",
      "Absensi bisa diedit kembali",
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.lock_open, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
