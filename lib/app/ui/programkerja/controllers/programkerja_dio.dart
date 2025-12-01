import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:orgtrack/app/data/models/fetch_record.dart';
import 'package:orgtrack/app/data/models/program_kerja_api.dart';

class ProgramControllerDio extends GetxController {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://api-production-a54a.up.railway.app/api/programKerja'));
  var programList = <Programker>[].obs;
  var loadingProgram = false.obs;
  var lastFetchMs = 0.obs;
  var fetchHistory = <int>[].obs;

  var records = <FetchRecord>[].obs;

  ProgramControllerDio() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("Request [${options.method}] => ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("response [${response.statusCode}] => ${response.data}");
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

  Future<void> fetchProgramByBidang(int bidangId) async {
    loadingProgram.value = true;
    final sw = DateTime.now();

    try {
      final res = await dio.get('/$bidangId');
      if (res.statusCode == 200) {
        final List data = res.data;
        programList.assignAll(data.map((e) => Programker.fromMap(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan DIO: $e');
    } finally {
      loadingProgram.value = false;
      lastFetchMs.value = DateTime.now().difference(sw).inMilliseconds;
      fetchHistory.add(lastFetchMs.value);

      // Tambahkan record untuk tabel/graph
      records.add(FetchRecord(
        endpoint: '/api/programKerja/$bidangId',
        lastMs: lastFetchMs.value,
        averageMs: averageFetchMs,
        mode: 'DIO',
      ));
    }
  }
}
