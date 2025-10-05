import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}

// Binding ini mendaftarkan controller yang dibutuhkan oleh HomeView.
// Get.lazyPut menunda pembuatan instance hingga benar-benar dipakai.
