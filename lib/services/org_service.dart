import 'package:dio/dio.dart';
import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:orgtrack/app/data/models/program_kerja_api.dart';

class OrgService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<BidangMo>> fetchBidang() async {
    try {
      final response = await _dio.get('$baseUrl/bidang');
      return (response.data as List).map((e) => BidangMo.fromMap(e)).toList();
    } catch (e) {
      print("Error fetch bidang: $e");
      return [];
    }
  }

  Future<List<Programker>> fetchProgramKerja(int bidangId) async {
    try {
      final response = await _dio.get('$baseUrl/programKerja/$bidangId');
      return (response.data as List)
          .map((e) => Programker.fromMap(e))
          .toList();
    } catch (e) {
      print("Error fetch program kerja: $e");
      return [];
    }
  }
}
