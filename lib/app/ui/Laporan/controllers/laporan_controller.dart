import 'package:get/get.dart';

class LaporanController extends GetxController {
  var reports = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // contoh data awal
    reports.addAll([
      {'judul': 'Laporan Keuangan Bulan Oktober', 'tanggal': '2025-10-20'},
      {'judul': 'Evaluasi Program Sosialisasi', 'tanggal': '2025-10-18'},
    ]);
  }

  void tambahLaporan() {
    reports.add({
      'judul': 'Laporan Baru (${reports.length + 1})',
      'tanggal': DateTime.now().toIso8601String().split('T').first,
    });
  }
}
