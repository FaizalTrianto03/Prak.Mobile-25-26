part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const INSTRUMENT_LIST = _Paths.INSTRUMENT_LIST;
  static const INSTRUMENT_FORM = _Paths.INSTRUMENT_FORM;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const INSTRUMENT_LIST = '/instruments';
  static const INSTRUMENT_FORM = '/instrument-form';
}
