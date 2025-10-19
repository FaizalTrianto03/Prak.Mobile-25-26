import 'package:dio/dio.dart';
import '../models/country_model.dart';

// Service untuk API Call pakai Dio
// Dio ini lebih canggih dari package http biasa:
// - Ada interceptors buat logging, auth token, dll
// - Error handling lebih detail
// - Bisa track progress download/upload
// - Bisa cancel request
// - Setting timeout lebih gampang
class DioService {
  late final Dio _dio;
  static const String baseUrl = 'https://restcountries.com/v3.1';
  
  DioService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Kita tambahin interceptor buat logging request/response (buat debugging)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }
  
  // Fetch semua negara - sama konsepnya kayak http service tapi pakai Dio
  Future<List<Country>> getAllCountries() async {
    try {
      // Dio GET request - query parameters bisa di-pass terpisah, lebih rapi
      final response = await _dio.get(
        '/all',
        queryParameters: {'fields': 'name'},
      );
      
      // Enak pakai Dio, response.data udah otomatis di-decode jadi List
      final List<dynamic> jsonData = response.data;
      return jsonData.map((json) => Country.fromJson(json)).toList();
      
    } on DioException catch (e) {
      // Error handling Dio lebih spesifik, bisa tau jenis errornya
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('Connection timeout');
        case DioExceptionType.receiveTimeout:
          throw Exception('Receive timeout');
        case DioExceptionType.badResponse:
          throw Exception('Bad response: ${e.response?.statusCode}');
        case DioExceptionType.cancel:
          throw Exception('Request cancelled');
        default:
          throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  // Search negara by name
  Future<List<Country>> searchCountryByName(String name) async {
    try {
      final response = await _dio.get(
        '/name/$name',
        queryParameters: {'fields': 'name'},
      );
      
      final List<dynamic> jsonData = response.data;
      return jsonData.map((json) => Country.fromJson(json)).toList();
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Not found
      }
      throw Exception('Search error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  // Fitur spesial Dio: bisa track progress download
  // Berguna kalau download file besar atau mau kasih loading bar
  Future<List<Country>> getAllCountriesWithProgress({
    Function(int, int)? onProgress,
  }) async {
    try {
      final response = await _dio.get(
        '/all',
        queryParameters: {'fields': 'name'},
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            onProgress(received, total);
          }
        },
      );
      
      final List<dynamic> jsonData = response.data;
      return jsonData.map((json) => Country.fromJson(json)).toList();
      
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    }
  }
  
  // Fitur cancel request - berguna kalau user pindah halaman sebelum request selesai
  CancelToken createCancelToken() {
    return CancelToken();
  }
}
