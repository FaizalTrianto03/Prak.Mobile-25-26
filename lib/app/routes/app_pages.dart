import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/location/bindings/location_binding.dart';
import '../modules/location/views/location_view.dart';
import '../modules/location/bindings/network_location_binding.dart';
import '../modules/location/views/network_location_view.dart';
import '../modules/location/bindings/gps_location_binding.dart';
import '../modules/location/views/gps_location_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOCATION,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: _Paths.NETWORK_LOCATION,
      page: () => const NetworkLocationView(),
      binding: NetworkLocationBinding(),
    ),
    GetPage(
      name: _Paths.GPS_LOCATION,
      page: () => const GpsLocationView(),
      binding: GpsLocationBinding(),
    ),
  ];
}
