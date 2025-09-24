import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../../demo/stateless/stateless_hub.dart';
import '../../demo/stateful/stateful_hub.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DEMO_STATELESS,
      page: () => const StatelessHubPage(),
    ),
    GetPage(
      name: _Paths.DEMO_STATEFUL,
      page: () => const StatefulHubPage(),
    ),
  ];
}

// Daftar route aplikasi. Gunakan `AppPages.routes` saat membangun GetMaterialApp.
// Route ini menghubungkan path dengan tampilan (page) dan binding bila perlu.
