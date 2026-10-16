import 'package:crypto_mobile/core/api_endpoints.dart';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class CoinService {

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );


  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: query,
      );

      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['error'] != null) {
        throw ApiException(data['error'].toString());
      }

      throw ApiException(
        'Cannot reach the server. Check your connection and try again.',
      );
    }
  }


  Future<dynamic> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
      );

      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['error'] != null) {
        throw ApiException(data['error'].toString());
      }

      throw ApiException(
        'Cannot reach the server. Check your connection and try again.',
      );
    }
  }


  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);

      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['error'] != null) {
        throw ApiException(data['error'].toString());
      }

      throw ApiException('Failed to delete data.');
    }
  }
}