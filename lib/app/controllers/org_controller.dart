import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orgtrack/app/data/models/bidang_model.dart';

class OrgController extends GetxController {
  var bidangList = <BidangMo>[].obs;
  var loadingBidang = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBidang();
  }

  Future<void> fetchBidang() async {
    loadingBidang.value = true;
    try {
      final response = await http.get(Uri.parse('https://api.example.com/bidang'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        bidangList.assignAll(data.map((e) => BidangMo.fromMap(e)).toList());
      } else {
        Get.snackbar('Error', 'Gagal mengambil data bidang');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      loadingBidang.value = false;
    }
  }
}
