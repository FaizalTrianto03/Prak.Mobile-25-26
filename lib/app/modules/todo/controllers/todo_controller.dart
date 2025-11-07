import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_strings.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/providers/todo_provider.dart';
import '../../../routes/app_pages.dart';

class TodoController extends GetxController {
  final TodoProvider _todoProvider = Get.find();

  final todos = <TodoModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  Future<void> loadTodos() async {
    isLoading.value = true;
    try {
      final data = _todoProvider.getTodos();
      todos.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTodo(TodoModel todo) async {
    final updated = todo.copyWith(isCompleted: !todo.isCompleted);
    try {
      await _todoProvider.updateTodo(updated);
      final index = todos.indexWhere((item) => item.id == todo.id);
      if (index != -1) {
        todos[index] = updated;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteTodo(TodoModel todo) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text('${AppStrings.deleteConfirm} "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _todoProvider.deleteTodo(todo.id);
        todos.removeWhere((item) => item.id == todo.id);
        Get.snackbar(
          'Success',
          AppStrings.todoDeletedSuccess,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete task: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> goToForm({TodoModel? todo}) async {
    final result = await Get.toNamed(Routes.TODO_FORM, arguments: todo);
    if (result != null) {
      await loadTodos();

      if (result is String && result.isNotEmpty) {
        Get.snackbar(
          'Success',
          result,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }
}

