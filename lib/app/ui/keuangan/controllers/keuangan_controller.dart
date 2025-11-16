import 'package:get/get.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import 'package:orgtrack/app/data/models/KeuanganModel.dart';

class KeuanganController extends GetxController {
  final SupabaseDB db = SupabaseDB();   

  var keuanganList = <Keuanganmodel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadKeuangan();
  }

  /// Ambil semua data keuangan dari Supabase
  Future<void> loadKeuangan() async {
    try {
      final data = await db.getKeuangan();
      keuanganList.assignAll(data);
    } catch (e) {
      print("Error load keuangan: $e");
    }
  }

  /// Tambah data baru
  Future<void> addKeuangan(Keuanganmodel k) async {
    await db.insertKeuangan(k);
    await loadKeuangan();
  }

  /// Update data lama
  Future<void> updateKeuangan(Keuanganmodel k) async {
    if (k.id == null) {
      print("Error: ID keuangan null");
      return;
    }

    await db.updateKeuangan(k);
    await loadKeuangan();
  }

  /// Hapus berdasarkan ID
  Future<void> deleteKeuangan(int id) async {
    await db.deleteKeuangan(id);
    await loadKeuangan();
  }

  /// Hitung total saldo
  double totalSaldo() {
    double pemasukan = totalByType('Pemasukan');
    double pengeluaran = totalByType('Pengeluaran');
    return pemasukan - pengeluaran;
  }

  /// Hitung total berdasarkan jenis
  double totalByType(String type) {
    return keuanganList
        .where((k) => k.type == type)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Data grafik per bulan (1 tahun)
  Map<String, List<double>> generateMonthlyDataByType() {
    final now = DateTime.now();
    List<double> pemasukan = List.filled(12, 0.0);
    List<double> pengeluaran = List.filled(12, 0.0);

    for (var item in keuanganList) {
      if (item.date.year == now.year) {
        int i = item.date.month - 1;
        if (item.type == 'Pemasukan') {
          pemasukan[i] += item.amount;
        } else if (item.type == 'Pengeluaran') {
          pengeluaran[i] += item.amount;
        }
      }
    }

    return {
      'Pemasukan': pemasukan,
      'Pengeluaran': pengeluaran,
    };
  }

  Future<void> refreshData() async {
    await loadKeuangan();
    update();
  }
}
