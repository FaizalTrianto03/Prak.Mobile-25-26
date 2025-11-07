import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/todo_model.dart';
import '../services/local_storage_service.dart';

class TodoProvider extends GetxService {
  final LocalStorageService _localStorage = Get.find();

  Box<TodoModel> get _box => _localStorage.todoBox;

  List<TodoModel> getTodos() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addTodo(TodoModel todo) async {
    await _box.put(todo.id, todo);
  }

  Future<void> updateTodo(TodoModel todo) async {
    await _box.put(todo.id, todo);
  }

  Future<void> deleteTodo(int id) async {
    await _box.delete(id);
  }

  int generateId() {
    final keys = _box.keys.whereType<int>();
    if (keys.isEmpty) {
      return 1;
    }

    final maxKey = keys.reduce(
      (value, element) => value > element ? value : element,
    );
    if (maxKey >= 0xFFFFFFFF) {
      throw HiveError('Maximum number of todos reached');
    }

    return maxKey + 1;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
