import 'package:get/get.dart';
import 'package:orgtrack/app/data/models/KeuanganModel.dart';
import '../../../data/db/db_helper.dart';

class KeuanganController extends GetxController {
  var keuanganList = <Keuanganmodel>[].obs;
  final DBHelper db = DBHelper();

  @override
  void onInit() {
    super.onInit();
    loadKeuangan();
  }

  // --- Ambil semua data dari database ---
  Future<void> loadKeuangan() async {
    final data = await db.getKeuangan();
    keuanganList.assignAll(data);
  }

  // --- Tambah data baru ---
  Future<void> addKeuangan(Keuanganmodel k) async {
    await db.insertKeuangan(k);
    await loadKeuangan();
  }

  // --- Update data lama (disimpan ke database juga) ---
  Future<void> updateKeuangan(Keuanganmodel k) async {
    await db.updateKeuangan(k);
    await loadKeuangan();
  }

  // --- Hapus data (opsional jika nanti mau ditambah) ---
  Future<void> deleteKeuangan(int id) async {
    await db.deleteKeuangan(id);
    await loadKeuangan();
  }

  // --- Hitung total saldo ---
  double totalSaldo() {
    double masuk = totalByType('Pemasukan');
    double keluar = totalByType('Pengeluaran');
    return masuk - keluar;
  }

  // --- Hitung total berdasarkan tipe ---
  double totalByType(String type) {
    return keuanganList
        .where((k) => k.type == type)
        .fold(0.0, (a, b) => a + b.amount);
  }

  // --- Data grafik per bulan ---
  Map<String, List<double>> generateMonthlyDataByType() {
    final now = DateTime.now();
    List<double> pemasukan = List.filled(12, 0.0);
    List<double> pengeluaran = List.filled(12, 0.0);

    for (var k in keuanganList) {
      if (k.date.year == now.year) {
        int monthIndex = k.date.month - 1;
        if (k.type == 'Pemasukan') {
          pemasukan[monthIndex] += k.amount;
        } else if (k.type == 'Pengeluaran') {
          pengeluaran[monthIndex] += k.amount;
        }
      }
    }

    return {
      'Pemasukan': pemasukan,
      'Pengeluaran': pengeluaran,
    };
  }

  // --- Refresh manual dari UI ---
  Future<void> refreshData() async {
    await loadKeuangan();
    update();
  }
}
