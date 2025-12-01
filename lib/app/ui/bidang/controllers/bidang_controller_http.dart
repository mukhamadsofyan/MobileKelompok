import 'package:flutter/material.dart'; //  wajib untuk Color & Snackbar style
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:orgtrack/app/data/models/fetch_record.dart';
import 'dart:convert';
import 'dart:async';


class BidangControllerHttp extends GetxController {
  final base = 'https://api-production-a54a.up.railway.app/api/bidang';
  var bidangList = <BidangModel>[].obs;
  var loadingBidang = false.obs;
  var lastFetchMs = 0.obs;
  var fetchHistory = <int>[].obs;
  var records = <FetchRecord>[].obs;

  int get averageFetchMs => fetchHistory.isEmpty
      ? 0
      : (fetchHistory.reduce((a, b) => a + b) ~/ fetchHistory.length);

  /// Tambahkan [testMode] untuk uji error seperti versi Dio
  Future<void> fetchBidang({String? testMode}) async {
    loadingBidang.value = true;
    final sw = DateTime.now();

    // Ganti URL berdasarkan mode uji
    String endpoint = base;
    if (testMode == '404') endpoint = '$base/salah'; // endpoint salah -> error 404
    if (testMode == 'badurl') endpoint = 'https://domain-tidak-ada.com';
    if (testMode == 'timeout') endpoint = 'https://10.255.255.1'; // IP dummy -> timeout

    try {
      final res = await http.get(Uri.parse(endpoint)).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        bidangList.assignAll(data.map((e) => BidangModel.fromMap(e)).toList());
        Get.snackbar(
          'Sukses',
          'Berhasil ambil data bidang (${bidangList.length})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      } else {
        // tampilkan kode error
        Get.snackbar(
          'HTTP Error',
          'Server mengembalikan status ${res.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.black,
        );
      }
    } on http.ClientException catch (e) {
      // error karena koneksi gagal (URL tidak valid)
      Get.snackbar(
        'Client Error',
        'Gagal konek ke server: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } on TimeoutException {
      // error karena timeout
      Get.snackbar(
        'Timeout',
        ' Permintaan ke server terlalu lama',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.yellow.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      // error umum (misal parsing JSON)
      Get.snackbar(
        'Error',
        'Terjadi kesalahan HTTP: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
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
