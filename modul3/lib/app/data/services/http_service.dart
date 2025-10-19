import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country_model.dart';

// Service untuk API Call pakai package HTTP
// Package http ini simpel dan gampang dipake, cocok buat kebutuhan dasar
class HttpService {
  static const String baseUrl = 'https://restcountries.com/v3.1';
  
  // Method untuk ambil semua negara dari API
  // Perhatikan: ini adalah async function yang return Future
  // async = function yang butuh waktu (network request)
  // await = tunggu sampai selesai baru lanjut
  Future<List<Country>> getAllCountries() async {
    try {
      // Kita filter cuma ambil field 'name' aja biar responsenya gak terlalu besar
      final url = Uri.parse('$baseUrl/all?fields=name');
      
      // GET request ke API - await disini tunggu sampai dapat response
      final response = await http.get(url);
      
      // Cek status code, 200 artinya sukses
      if (response.statusCode == 200) {
        // Parse JSON string jadi List
        final List<dynamic> jsonData = json.decode(response.body);
        
        // Convert tiap item jadi object Country
        return jsonData.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      // Catch error kalau misal internet mati atau ada masalah
      throw Exception('Error fetching countries: $e');
    }
  }
  
  // Search negara by name - sama seperti getAllCountries tapi dengan parameter
  Future<List<Country>> searchCountryByName(String name) async {
    try {
      final url = Uri.parse('$baseUrl/name/$name?fields=name');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Country.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // 404 = tidak ketemu, return list kosong
        return [];
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching country: $e');
    }
  }
  
  // Method helper untuk simulasi delay
  // Berguna kalau mau test loading state di UI
  Future<void> simulateDelay({int seconds = 2}) async {
    await Future.delayed(Duration(seconds: seconds));
  }
}
