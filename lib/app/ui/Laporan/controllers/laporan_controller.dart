import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:orgtrack/app/data/models/laporanModel.dart';

class LaporanController extends GetxController {
  late Box<Report> _box;
  var reports = <Report>[].obs;

  @override
  void onInit() {
    super.onInit();

    _box = Hive.box<Report>('reportsBox');

    reports.assignAll(_box.values);
  }

  // ===============================
  //        TAMBAH LAPORAN
  // ===============================
  void tambahLaporan(String judul, String tanggal) {
    final newReport = Report(judul: judul, tanggal: tanggal);

    _box.add(newReport);
    reports.assignAll(_box.values);
  }

  // ===============================
  //         EDIT LAPORAN
  // ===============================
  void editLaporan(int index, String judul, String tanggal) {
    final key = _box.keyAt(index);
    final updated = Report(judul: judul, tanggal: tanggal);

    _box.put(key, updated); // update Hive
    reports.assignAll(_box.values);
  }

  // ===============================
  //        DELETE LAPORAN
  // ===============================
  void hapusLaporan(int index) {
    final key = _box.keyAt(index);
    _box.delete(key);

    reports.assignAll(_box.values);
  }
}
