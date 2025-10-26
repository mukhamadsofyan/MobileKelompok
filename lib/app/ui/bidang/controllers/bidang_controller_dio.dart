import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:orgtrack/app/data/models/fetch_record.dart';


class BidangControllerDio extends GetxController {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api-production-a54a.up.railway.app/api/bidang',
    // connectTimeout: 10000,
    // receiveTimeout: 10000,
  ));

  var bidangList = <BidangMo>[].obs;
  var loadingBidang = false.obs;
  var lastFetchMs = 0.obs;
  var fetchHistory = <int>[].obs;
  var records = <FetchRecord>[].obs;

  BidangControllerDio() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("Request [${options.method}] => ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("Response [${response.statusCode}] => ${response.data}");
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          print("Error: ${e.type} | ${e.message}");
          if (e.response != null) print("Response: ${e.response?.data}");
          return handler.next(e);
        },
      ),
    );
  }

  int get averageFetchMs =>
      fetchHistory.isEmpty ? 0 : (fetchHistory.reduce((a, b) => a + b) ~/ fetchHistory.length);

  Future<void> fetchBidang() async {
    loadingBidang.value = true;
    final sw = DateTime.now();

    try {
      final res = await dio.get('/'); // bisa juga '' atau '/'
      if (res.statusCode == 200) {
        if (res.data is List) {
          bidangList.assignAll((res.data as List).map((e) => BidangMo.fromMap(e)).toList());
        } else {
          Get.snackbar('Error', 'DIO error: Data tidak berbentuk list');
        }
      } else {
        Get.snackbar('Error', 'DIO error: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan DIO: $e');
    } finally {
      loadingBidang.value = false;
      lastFetchMs.value = DateTime.now().difference(sw).inMilliseconds;
      fetchHistory.add(lastFetchMs.value);

      records.add(FetchRecord(
        endpoint: '/api/bidang',
        lastMs: lastFetchMs.value,
        averageMs: averageFetchMs,
        mode: 'DIO',
      ));
    }
  }
}
