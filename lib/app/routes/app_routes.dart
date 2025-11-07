part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const NOTE_LIST = _Paths.NOTE_LIST;
  static const NOTE_FORM = _Paths.NOTE_FORM;
  static const TODO_LIST = _Paths.TODO_LIST;
  static const TODO_FORM = _Paths.TODO_FORM;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const NOTE_LIST = '/notes';
  static const NOTE_FORM = '/note-form';
  static const TODO_LIST = '/todos';
  static const TODO_FORM = '/todo-form';
}
