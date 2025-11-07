import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_strings.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/providers/todo_provider.dart';
import '../controllers/todo_controller.dart';

class TodoFormController extends GetxController {
  final TodoProvider _todoProvider = Get.find();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  TodoModel? todo;

  bool get isEditing => todo != null;

  @override
  void onInit() {
    super.onInit();
    todo = Get.arguments as TodoModel?;
    if (todo != null) {
      titleController.text = todo!.title;
      descriptionController.text = todo!.description;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterTodoTitle;
    }
    return null;
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final trimmedTitle = titleController.text.trim();
    final trimmedDescription = descriptionController.text.trim();

    try {
      String message;

      if (isEditing) {
        final updated = todo!.copyWith(
          title: trimmedTitle,
          description: trimmedDescription,
        );

        await _todoProvider.updateTodo(updated);
        message = AppStrings.todoUpdatedSuccess;
      } else {
        final newTodo = TodoModel(
          id: _todoProvider.generateId(),
          title: trimmedTitle,
          description: trimmedDescription,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        await _todoProvider.addTodo(newTodo);
        message = AppStrings.todoAddedSuccess;
      }

      try {
        final todoController = Get.find<TodoController>();
        // ignore: unawaited_futures
        todoController.loadTodos();
      } catch (_) {}

      Get.back(result: message);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class TodoFormView extends StatelessWidget {
  TodoFormView({super.key});

  final controller = Get.put(TodoFormController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          controller.isEditing ? AppStrings.editTodo : AppStrings.addTodo,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => TextFormField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.todoTitle,
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: controller.validateTitle,
                  enabled: !controller.isLoading.value,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => TextFormField(
                  controller: controller.descriptionController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.todoDescription,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  enabled: !controller.isLoading.value,
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => FilledButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.submitForm,
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          controller.isEditing
                              ? AppStrings.editTodo
                              : AppStrings.addTodo,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

