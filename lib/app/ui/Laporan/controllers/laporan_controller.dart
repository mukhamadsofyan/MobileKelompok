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
  void tambahLaporan(
    String judul,
    String tanggal,
    String deskripsi,
  ) {
    final newReport = Report(
      judul: judul,
      tanggal: tanggal,
      deskripsi: deskripsi,
    );

    _box.add(newReport);
    reports.assignAll(_box.values);
  }

  // ===============================
  //         EDIT LAPORAN
  // ===============================
  void editLaporan(
    int index,
    String judul,
    String tanggal,
    String deskripsi,
  ) {
    final key = _box.keyAt(index);

    final updated = Report(
      judul: judul,
      tanggal: tanggal,
      deskripsi: deskripsi,
    );

    _box.put(key, updated);
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
