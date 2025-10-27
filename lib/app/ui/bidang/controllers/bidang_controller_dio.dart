import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:orgtrack/app/data/models/fetch_record.dart';

class BidangControllerDio extends GetxController {
  // Base konfigurasi Dio
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api-production-a54a.up.railway.app/api/bidang', // endpoint utama
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Reactive variables
  var bidangList = <BidangMo>[].obs;
  var loadingBidang = false.obs;
  var lastFetchMs = 0.obs;
  var fetchHistory = <int>[].obs;
  var records = <FetchRecord>[].obs;

  // Constructor dengan interceptor logging
  BidangControllerDio() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(" Request [${options.method}] => ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(" Response [${response.statusCode}] => ${response.data}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(" Error: ${e.type} | ${e.message}");
          if (e.response != null) {
            print("Response Data: ${e.response?.data}");
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Hitung rata-rata waktu fetch
  int get averageFetchMs =>
      fetchHistory.isEmpty ? 0 : (fetchHistory.reduce((a, b) => a + b) ~/ fetchHistory.length);

  /// === Fungsi utama untuk fetch data Bidang ===
  ///
  /// [testMode] bisa kamu isi:
  /// - `null` → normal
  /// - `'404'` → simulasi endpoint salah
  /// - `'timeout'` → simulasi koneksi lambat
  /// - `'badurl'` → simulasi domain salah
  Future<void> fetchBidang({String? testMode}) async {
    loadingBidang.value = true;
    final sw = DateTime.now();

    // Mode uji error
    String endpoint = '/';
    if (testMode == '404') endpoint = '/tidak_ada'; // Endpoint palsu
    if (testMode == 'badurl') dio.options.baseUrl = 'https://domain-tidak-ada.com';
    if (testMode == 'timeout') dio.options.connectTimeout = const Duration(milliseconds: 1);

    try {
      final res = await dio.get(endpoint);

      // Jika status 200
      if (res.statusCode == 200) {
        if (res.data is List) {
          bidangList.assignAll((res.data as List).map((e) => BidangMo.fromMap(e)).toList());
          Get.snackbar(
            'Sukses',
            'Berhasil ambil data bidang (${bidangList.length})',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE0FFE0),
            colorText: const Color(0xFF000000),
          );
        } else {
          Get.snackbar(
            'Error',
            'DIO error: Data tidak berbentuk list',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFE0E0),
            colorText: const Color(0xFF000000),
          );
        }
      } else {
        // Kalau status bukan 200 (misal 404, 500, dsb)
        Get.snackbar(
          'Error',
          'DIO error: ${res.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF000000),
        );
      }
    } on DioException catch (e) {
      // Tangkap semua error dari Dio
      String message = "Terjadi kesalahan DIO: ${e.message}";
      if (e.type == DioExceptionType.connectionTimeout) message = "Timeout koneksi ke server!";
      if (e.type == DioExceptionType.receiveTimeout) message = "Timeout menerima respons!";
      if (e.type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode ?? 0;
        message = "Server mengembalikan status $code (${_statusMeaning(code)})";
      }
      if (e.type == DioExceptionType.unknown) message = "Gagal terhubung ke server";

      Get.snackbar(
        'Error DIO (${e.type.name})',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF000000),
      );
    } catch (e) {
      // Error non-Dio (misal parsing JSON)
      Get.snackbar(
        'Error Umum',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF000000),
      );
    } finally {
      // Catat waktu fetch
      loadingBidang.value = false;
      lastFetchMs.value = DateTime.now().difference(sw).inMilliseconds;
      fetchHistory.add(lastFetchMs.value);

      records.add(FetchRecord(
        endpoint: '/api/bidang',
        lastMs: lastFetchMs.value,
        averageMs: averageFetchMs,
        mode: 'DIO',
      ));

      // Reset setting Dio ke default
      dio.options
        ..baseUrl = 'https://api-production-a54a.up.railway.app/api/bid'
        ..connectTimeout = const Duration(seconds: 5)
        ..receiveTimeout = const Duration(seconds: 5);
    }
  }

  // Helper untuk menjelaskan status HTTP
  String _statusMeaning(int code) {
    switch (code) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      default:
        return 'Unknown Error';
    }
  }
}
