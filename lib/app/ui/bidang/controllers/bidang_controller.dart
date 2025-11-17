import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orgtrack/app/data/models/bidang_model.dart';

class BidangControllerSupabase extends GetxController {
  final client = Supabase.instance.client;

  RxList<BidangModel> bidangList = <BidangModel>[].obs;
  RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBidang();
  }

  Future<void> fetchBidang() async {
    try {
      loading.value = true;

      final data = await client
          .from('bidang')
          .select()
          .order('nama', ascending: true);

      bidangList.value =
          data.map<BidangModel>((e) => BidangModel.fromMap(e)).toList();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat bidang: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<void> addBidang(String nama) async {
    try {
      await client.from('bidang').insert({'nama': nama});
      fetchBidang();
      Get.snackbar("Sukses", "Bidang berhasil ditambahkan");
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah bidang: $e");
    }
  }

  Future<void> updateBidang(int id, String nama) async {
    try {
      await client.from('bidang').update({'nama': nama}).eq('id', id);
      fetchBidang();
      Get.snackbar("Sukses", "Bidang berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Error", "Gagal mengupdate bidang: $e");
    }
  }

  Future<void> deleteBidang(int id) async {
    try {
      await client.from('bidang').delete().eq('id', id);
      fetchBidang();
      Get.snackbar("Sukses", "Bidang berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus bidang: $e");
    }
  }
}
