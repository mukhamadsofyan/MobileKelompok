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

  // ================= STATE =================
  final strukturalList = <Struktural>[].obs;
  final attendanceMap = <int, bool>{}.obs;

  final loading = true.obs;
  final isLocked = true.obs;

  // ================= COUNTER =================
  final hadirCount = 0.obs;
  final tidakCount = 0.obs;
  final totalCount = 0.obs;

  bool get isAdmin =>
      Get.find<AuthController>().userRole.value.toLowerCase().trim() == "admin";

  bool get isExpired => agenda.date.isBefore(DateTime.now());

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();

    if (agenda.id == null) {
      // ❌ TIDAK ADA NOTIF DI CONTROLLER
      return;
    }

    ever(attendanceMap, (_) => _recalculateStats());
    loadAttendanceData();
  }

  // ================= LOAD DATA =================
  Future<void> loadAttendanceData() async {
    loading.value = true;

    // ambil anggota
    final list = await db.getStruktural();
    strukturalList.assignAll(list);

    // ambil absensi
    final rows = await db.getAttendanceByAgenda(agenda.id!);

    final Map<int, bool> tempMap = {};

    for (final row in rows) {
      final sid = row['struktural_id'];
      final present = row['present'];

      if (sid != null) {
        tempMap[sid as int] = (present == true || present == 1);
      }
    }

    // default false untuk anggota tanpa data
    for (final s in strukturalList) {
      if (s.id != null) {
        tempMap.putIfAbsent(s.id!, () => false);
      }
    }

    // assign SEKALI
    attendanceMap.value = tempMap;

    // lock jika expired / sudah ada data
    isLocked.value = isExpired || rows.isNotEmpty;

    _recalculateStats();
    loading.value = false;
  }

  // ================= STATS =================
  void _recalculateStats() {
    final total = strukturalList.length;
    final hadir = attendanceMap.values.where((v) => v).length;

    totalCount.value = total;
    hadirCount.value = hadir;
    tidakCount.value = total - hadir;
  }

  // ================= TOGGLE =================
  void toggleAttendance(int strukturalId, bool value) {
    if (!isAdmin || isLocked.value || isExpired) return;

    attendanceMap[strukturalId] = value;
    attendanceMap.refresh();
  }

  // ================= SIMPAN (UPSERT) =================
  /// return true = sukses
  /// return false = gagal
  Future<bool> saveAttendance() async {
    if (!isAdmin || isExpired) return false;

    try {
      loading.value = true;

      for (final entry in attendanceMap.entries) {
        await db.markAttendance(agenda.id!, entry.key, entry.value);
      }

      isLocked.value = true;
      return true;
    } catch (e) {
      return false;
    } finally {
      loading.value = false;
    }
  }

  // ================= EDIT ULANG =================
  void confirmEditAttendance() {
    if (!isAdmin || isExpired) return;

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Absensi?"),
        content: const Text(
          "Absensi yang sudah disimpan akan diubah.\n\nLanjutkan?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(Get.overlayContext!).pop(); // ✅ TUTUP DIALOG
            },
            child: const Text("Batal"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(Get.overlayContext!).pop(); // ✅ TUTUP DIALOG DULU
              Future.microtask(() {
                isLocked.value = false; // baru ubah state
              });
            },
            child: const Text("Ya, Edit"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
