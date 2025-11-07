import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/note/bindings/note_binding.dart';
import '../modules/note/views/note_list_view.dart';
import '../modules/note/views/note_form_view.dart';
import '../modules/todo/bindings/todo_binding.dart';
import '../modules/todo/views/todo_list_view.dart';
import '../modules/todo/views/todo_form_view.dart';

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
      name: _Paths.NOTE_LIST,
      page: () => const NoteListView(),
      binding: NoteBinding(),
    ),
    GetPage(
      name: _Paths.NOTE_FORM,
      page: () => NoteFormView(),
      binding: NoteBinding(),
    ),
    GetPage(
      name: _Paths.TODO_LIST,
      page: () => const TodoListView(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: _Paths.TODO_FORM,
      page: () => TodoFormView(),
      binding: TodoBinding(),
    ),
  ];
}
