import 'package:get/get.dart';
import '../controllers/http_countries_controller.dart';

class HttpCountriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HttpCountriesController>(() => HttpCountriesController());
  }
}
