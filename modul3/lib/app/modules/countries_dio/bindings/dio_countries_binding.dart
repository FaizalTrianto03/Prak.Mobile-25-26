import 'package:get/get.dart';
import '../controllers/dio_countries_controller.dart';

class DioCountriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DioCountriesController>(() => DioCountriesController());
  }
}
