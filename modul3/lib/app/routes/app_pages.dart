import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/countries_http/bindings/http_countries_binding.dart';
import '../modules/countries_http/views/http_countries_view.dart';
import '../modules/countries_dio/bindings/dio_countries_binding.dart';
import '../modules/countries_dio/views/dio_countries_view.dart';
import '../modules/async_demo/views/async_demo_view.dart';
import '../modules/login_demo/views/login_demo_view.dart';

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
      name: _Paths.COUNTRIES_HTTP,
      page: () => const HttpCountriesView(),
      binding: HttpCountriesBinding(),
    ),
    GetPage(
      name: _Paths.COUNTRIES_DIO,
      page: () => const DioCountriesView(),
      binding: DioCountriesBinding(),
    ),
    GetPage(
      name: _Paths.ASYNC_DEMO,
      page: () => const AsyncDemoView(),
    ),
    GetPage(
      name: _Paths.LOGIN_DEMO,
      page: () => const LoginDemoView(),
    ),
  ];
}
