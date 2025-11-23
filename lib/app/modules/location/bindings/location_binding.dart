import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../../../data/services/location_service.dart';

/// Binding untuk Location Module
/// Menginisialisasi LocationController dan LocationService
class LocationBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocationService sebagai singleton
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    
    // Register LocationController
    Get.lazyPut<LocationController>(
      () => LocationController(),
      fenix: true,
    );
  }
}

