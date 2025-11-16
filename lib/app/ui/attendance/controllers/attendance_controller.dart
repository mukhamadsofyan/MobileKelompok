import 'package:get/get.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import '../../../data/models/AgendaModel.dart';
import '../../../data/models/StrukturalModel.dart';
import 'package:flutter/material.dart';

class AttendanceController extends GetxController {
  final SupabaseDB db = SupabaseDB();     // <-- FIX: gunakan SupabaseDB
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

  /// 🔄 Muat ulang data absensi dari Supabase
  Future<void> loadAttendanceData() async {
    loading.value = true;

    // Ambil semua data struktural dari Supabase
    final list = await db.getStruktural();
    strukturalList.assignAll(list);

    // Ambil data absensi berdasarkan ID agenda
    final rows = await db.getAttendanceByAgenda(agenda.id!);

    final map = <int, bool>{};
    for (var row in rows) {
      map[row['struktural_id'] as int] =
          (row['present'] == 1 || row['present'] == true);
    }

    attendanceMap.assignAll(map);

    // Default: kalau belum ada → false
    for (var s in strukturalList) {
      attendanceMap.putIfAbsent(s.id!, () => false);
    }

    // Auto-lock kalau tanggal sudah lewat
    final now = DateTime.now();
    if (agenda.date.isBefore(now)) {
      isLocked.value = true;
    }

    loading.value = false;
  }

  /// 🔁 Refresh manual
  Future<void> refreshData() async {
    await loadAttendanceData();
  }

  /// 👆 Toggle hadir / tidak hadir
  Future<void> toggleAttendance(int strukturalId) async {
    if (isLocked.value) return;

    final current = attendanceMap[strukturalId] ?? false;
    attendanceMap[strukturalId] = !current;

    // Simpan ke Supabase
    await db.markAttendance(agenda.id!, strukturalId, !current);

    // Refresh agar sinkron
    Future.delayed(const Duration(milliseconds: 250), () async {
      await refreshData();
    });
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

  /// 🔓 Admin buka kunci absensi
  Future<void> unlockAttendance() async {
    isLocked.value = false;
    await refreshData();

    Get.snackbar(
      'Kunci Dibuka',
      'Absensi sudah bisa diedit kembali.',
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.lock_open, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
