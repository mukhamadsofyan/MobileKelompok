import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:orgtrack/app/data/models/fetch_record.dart';
import 'dart:convert';

class BidangControllerHttp extends GetxController {
  final base = 'https://api-production-a54a.up.railway.app/api/bidang';
  var bidangList = <BidangMo>[].obs;
  var loadingBidang = false.obs;
  var lastFetchMs = 0.obs;
  var fetchHistory = <int>[].obs;
  var records = <FetchRecord>[].obs;

  int get averageFetchMs => fetchHistory.isEmpty
      ? 0
      : (fetchHistory.reduce((a, b) => a + b) ~/ fetchHistory.length);

  Future<void> fetchBidang() async {
    loadingBidang.value = true;
    final sw = DateTime.now();

    try {
      final res = await http.get(Uri.parse(base));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        bidangList.assignAll(data.map((e) => BidangMo.fromMap(e)).toList());
      } else {
        Get.snackbar('Error', 'HTTP error: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan HTTP: $e');
    } finally {
      loadingBidang.value = false;
      lastFetchMs.value = DateTime.now().difference(sw).inMilliseconds;
      fetchHistory.add(lastFetchMs.value);

      records.add(FetchRecord(
        endpoint: '/api/bidang',
        lastMs: lastFetchMs.value,
        averageMs: averageFetchMs,
        mode: 'HTTP',
      ));
    }
  }
}
