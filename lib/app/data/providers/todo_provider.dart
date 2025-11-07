import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/todo_model.dart';

class TodoProvider extends GetxService {
  static const String boxName = 'todo_box';

  late Box<TodoModel> _box;

  Future<TodoProvider> init() async {
    try {
      await Hive.initFlutter();
    } on HiveError {
      // Hive already initialized, ignore.
    }

    final adapter = TodoModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }

    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<TodoModel>(boxName);
    } else {
      _box = await Hive.openBox<TodoModel>(boxName);
    }
    return this;
  }

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
