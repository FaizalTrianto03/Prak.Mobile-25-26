part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const TODO_LIST = _Paths.TODO_LIST;
  static const TODO_FORM = _Paths.TODO_FORM;
  static const NOTIFICATION_HISTORY = _Paths.NOTIFICATION_HISTORY;
  static const NOTIFICATIONS_TEST = _Paths.NOTIFICATIONS_TEST;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const TODO_LIST = '/todos';
  static const TODO_FORM = '/todo-form';
  static const NOTIFICATION_HISTORY = '/notification-history';
  static const NOTIFICATIONS_TEST = '/notifications-test';
}
