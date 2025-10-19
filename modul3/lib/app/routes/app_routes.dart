part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const COUNTRIES_HTTP = _Paths.COUNTRIES_HTTP;
  static const COUNTRIES_DIO = _Paths.COUNTRIES_DIO;
  static const ASYNC_DEMO = _Paths.ASYNC_DEMO;
  static const LOGIN_DEMO = _Paths.LOGIN_DEMO;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const COUNTRIES_HTTP = '/countries-http';
  static const COUNTRIES_DIO = '/countries-dio';
  static const ASYNC_DEMO = '/async-demo';
  static const LOGIN_DEMO = '/login-demo';
}
