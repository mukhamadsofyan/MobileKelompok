import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:orgtrack/app/data/models/fetch_record.dart';
import 'package:orgtrack/app/data/models/program_kerja_api.dart';
import 'dart:convert';

class ProgramControllerHttp extends GetxController {
  final base = 'https://api-production-a54a.up.railway.app/api/programKerja'; // ganti dengan API kamu jika beda
  var programList = <Programker>[].obs;
  var loadingProgram = false.obs;
  var lastFetchMs = 0.obs;
  var fetchHistory = <int>[].obs;
  var records = <FetchRecord>[].obs;

  int get averageFetchMs =>
      fetchHistory.isEmpty ? 0 : (fetchHistory.reduce((a, b) => a + b) ~/ fetchHistory.length);

  Future<void> fetchProgramByBidang(int bidangId) async {
    loadingProgram.value = true;
    final sw = DateTime.now();

    try {
      // Panggil API
      final res = await http.get(Uri.parse('$base/$bidangId'));

      // Cek statusCode
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        programList.assignAll(data.map((e) => Programker.fromMap(e)).toList());
      } else {
        Get.snackbar('Error', 'HTTP error: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan HTTP: $e');
    } finally {
      // Hitung waktu fetch
      lastFetchMs.value = DateTime.now().difference(sw).inMilliseconds;
      fetchHistory.add(lastFetchMs.value);
      loadingProgram.value = false;

      // Tambahkan record history
      records.add(FetchRecord(
        endpoint: '/api/programKerja/$bidangId',
        lastMs: lastFetchMs.value,
        averageMs: averageFetchMs,
        mode: 'HTTP',
      ));
    }
  }
}
