import 'package:dio/dio.dart';

class OrgService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:3000/api'; // emulator Android

  Future<List<dynamic>> fetchBidang() async {
    try {
      final response = await _dio.get('$baseUrl/bidang');
      return response.data;
    } catch (e) {
      print("Error fetch bidang: $e");
      return [];
    }
  }
}
