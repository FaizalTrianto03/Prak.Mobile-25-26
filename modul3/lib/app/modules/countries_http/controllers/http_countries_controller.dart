import 'package:get/get.dart';
import '../../../data/models/country_model.dart';
import '../../../data/services/http_service.dart';

// Controller untuk halaman countries yang pakai HTTP package
// Di sini kalian bisa lihat cara manage state dengan GetX:
// - Loading state (lagi fetch data atau ngga)
// - Error state (ada error atau ngga)
// - Data state (list countries)
class HttpCountriesController extends GetxController {
  final HttpService _httpService = HttpService();
  
  // State variables yang reactive (pakai .obs supaya UI auto update)
  final RxList<Country> countries = <Country>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Langsung fetch data begitu controller dibuat
    fetchCountries();
  }
  
  // Method untuk fetch semua negara
  // Pattern standar async: loading -> try fetch -> success/error -> loading off
  Future<void> fetchCountries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Await disini artinya tunggu sampai API nya return data
      final result = await _httpService.getAllCountries();
      
      // Kalau berhasil, update list countries
      countries.value = result;
      
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error: $e');
    } finally {
      // Finally ini pasti dijalankan mau success atau error
      isLoading.value = false;
    }
  }
  
  // Search country dengan debouncing (delay dikit biar gak request terus2an)
  Future<void> searchCountry(String query) async {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      // Kalau search kosong, tampilkan semua negara
      await fetchCountries();
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Delay 500ms biar gak langsung request setiap ketik
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Cek lagi, kalau query udah berubah ya gak usah lanjut
      if (searchQuery.value != query) return;
      
      final result = await _httpService.searchCountryByName(query);
      countries.value = result;
      
      if (result.isEmpty) {
        errorMessage.value = 'No countries found';
      }
      
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Method untuk pull-to-refresh
  Future<void> refreshCountries() async {
    await fetchCountries();
  }
  
  // Clear pencarian
  void clearSearch() {
    searchQuery.value = '';
    fetchCountries();
  }
}
