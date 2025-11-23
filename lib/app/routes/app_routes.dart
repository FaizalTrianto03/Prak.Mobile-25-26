part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const LOCATION = _Paths.LOCATION;
  static const NETWORK_LOCATION = _Paths.NETWORK_LOCATION;
  static const GPS_LOCATION = _Paths.GPS_LOCATION;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const LOCATION = '/location';
  static const NETWORK_LOCATION = '/network-location';
  static const GPS_LOCATION = '/gps-location';
}
