import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:orgtrack/app/data/models/fetch_record.dart';

class BidangControllerDio extends GetxController {
  // ============================================================
  // KONFIGURASI DIO
  // ============================================================
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api-production-a54a.up.railway.app/api/bidang',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // ============================================================
  // STATE
  // ============================================================
  var bidangList = <BidangModel>[].obs;
  var loadingBidang = false.obs;
  var lastFetchMs = 0.obs;
  var fetchHistory = <int>[].obs;
  var records = <FetchRecord>[].obs;

  // ============================================================
  // INTERCEPTOR (LOG)
  // ============================================================
  BidangControllerDio() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint("➡️ REQUEST [${options.method}] ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint("✅ RESPONSE [${response.statusCode}]");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint("❌ ERROR ${e.type} | ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  // ============================================================
  // HITUNG RATA-RATA FETCH
  // ============================================================
  int get averageFetchMs =>
      fetchHistory.isEmpty
          ? 0
          : (fetchHistory.reduce((a, b) => a + b) ~/ fetchHistory.length);

  // ============================================================
  // FETCH DATA BIDANG
  // ============================================================
  Future<void> fetchBidang({String? testMode}) async {
    loadingBidang.value = true;
    final sw = DateTime.now();

    // ===== MODE TEST =====
    String endpoint = '/';
    if (testMode == '404') endpoint = '/tidak_ada';
    if (testMode == 'badurl') {
      dio.options.baseUrl = 'https://domain-tidak-ada.com';
    }
    if (testMode == 'timeout') {
      dio.options.connectTimeout = const Duration(milliseconds: 1);
    }

    try {
      final res = await dio.get(endpoint);

      // ================= SUCCESS =================
      if (res.statusCode == 200 && res.data is List) {
        bidangList.assignAll(
          (res.data as List)
              .map((e) => BidangModel.fromMap(e))
              .toList(),
        );

        // 🔥 NOTIFIKASI YANG SAMA — PINDAH KE ATAS
        Get.snackbar(
          'Sukses',
          'Berhasil ambil data bidang (${bidangList.length})',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
          backgroundColor: const Color(0xFFE0FFE0),
          colorText: Colors.black,
        );
      } else {
        Get.snackbar(
          'Error',
          'DIO error: ${res.statusCode}',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: Colors.black,
        );
      }
    }

    // ================= ERROR DIO =================
    on DioException catch (e) {
      String message = "Terjadi kesalahan DIO";

      if (e.type == DioExceptionType.connectionTimeout) {
        message = "Timeout koneksi ke server!";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = "Timeout menerima respons!";
      } else if (e.type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode ?? 0;
        message = "Server mengembalikan status $code (${_statusMeaning(code)})";
      } else if (e.type == DioExceptionType.unknown) {
        message = "Gagal terhubung ke server";
      }

      Get.snackbar(
        'Error DIO',
        message,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: Colors.black,
      );
    }

    // ================= ERROR UMUM =================
    catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: Colors.black,
      );
    }

    // ================= FINALLY =================
    finally {
      loadingBidang.value = false;
      lastFetchMs.value = DateTime.now().difference(sw).inMilliseconds;
      fetchHistory.add(lastFetchMs.value);

      records.add(
        FetchRecord(
          endpoint: '/api/bidang',
          lastMs: lastFetchMs.value,
          averageMs: averageFetchMs,
          mode: 'DIO',
        ),
      );

      // 🔧 RESET KONFIGURASI (BUG FIX)
      dio.options
        ..baseUrl = 'https://api-production-a54a.up.railway.app/api/bidang'
        ..connectTimeout = const Duration(seconds: 5)
        ..receiveTimeout = const Duration(seconds: 5);
    }
  }

  // ============================================================
  // HELPER STATUS HTTP
  // ============================================================
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
