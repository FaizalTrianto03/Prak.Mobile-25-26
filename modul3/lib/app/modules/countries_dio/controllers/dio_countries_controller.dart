import 'package:get/get.dart';
import '../../../data/models/country_model.dart';
import '../../../data/services/dio_service.dart';

// Controller untuk halaman countries yang pakai Dio
// Sama seperti HTTP controller, tapi pakai Dio service
// Ada tambahan progress tracking sebagai contoh fitur Dio
class DioCountriesController extends GetxController {
  final DioService _dioService = DioService();
  
  final RxList<Country> countries = <Country>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxDouble downloadProgress = 0.0.obs; // Progress tracking (fitur Dio)
  
  @override
  void onInit() {
    super.onInit();
    fetchCountries();
  }
  
  // Fetch countries - sama konsepnya kayak HTTP controller
  Future<void> fetchCountries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _dioService.getAllCountries();
      countries.value = result;
      
    } catch (e) {
      errorMessage.value = e.toString();
      print('Dio Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fetch dengan progress - ini fitur spesial dari Dio
  Future<void> fetchCountriesWithProgress() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      downloadProgress.value = 0.0;
      
      final result = await _dioService.getAllCountriesWithProgress(
        onProgress: (received, total) {
          // Callback ini dipanggil tiap ada data yang di-download
          downloadProgress.value = received / total;
          print('Download progress: ${(downloadProgress.value * 100).toStringAsFixed(0)}%');
        },
      );
      
      countries.value = result;
      downloadProgress.value = 1.0;
      
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Search country
  Future<void> searchCountry(String query) async {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      await fetchCountries();
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (searchQuery.value != query) return;
      
      final result = await _dioService.searchCountryByName(query);
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
  
  Future<void> refreshCountries() async {
    await fetchCountries();
  }
  
  void clearSearch() {
    searchQuery.value = '';
    fetchCountries();
  }
}
