import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_strings.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/providers/todo_provider.dart';
import '../../../data/services/notification_handler.dart';
import '../controllers/todo_controller.dart';

class TodoFormController extends GetxController {
  final TodoProvider _todoProvider = Get.find();
  final NotificationHandler _notificationHandler = Get.find();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  // final RxBool hasReminder = false.obs; // Removed
  // final RxInt reminderMinutesBefore = 15.obs; // Removed

  TodoModel? todo;

  bool get isEditing => todo != null;

  @override
  void onInit() {
    super.onInit();
    todo = Get.arguments as TodoModel?;
    if (todo != null) {
      titleController.text = todo!.title;
      descriptionController.text = todo!.description;
      if (todo!.dueDate != null) {
        selectedDate.value = todo!.dueDate;
        selectedTime.value = TimeOfDay.fromDateTime(todo!.dueDate!);
      }
      // hasReminder.value = todo!.hasReminder;
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

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final trimmedTitle = titleController.text.trim();
    final trimmedDescription = descriptionController.text.trim();

    DateTime? finalDueDate;
    if (selectedDate.value != null && selectedTime.value != null) {
      finalDueDate = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );
    }

    try {
      String message;
      int todoId;

      if (isEditing) {
        todoId = todo!.id;
        final updated = todo!.copyWith(
          title: trimmedTitle,
          description: trimmedDescription,
          dueDate: finalDueDate,
          hasReminder: false, // Scheduled notifications removed
        );

        await _todoProvider.updateTodo(updated);
        message = AppStrings.todoUpdatedSuccess;
      } else {
        todoId = _todoProvider.generateId();
        final newTodo = TodoModel(
          id: todoId,
          title: trimmedTitle,
          description: trimmedDescription,
          isCompleted: false,
          createdAt: DateTime.now(),
          dueDate: finalDueDate,
          hasReminder: false, // Scheduled notifications removed
        );

        await _todoProvider.addTodo(newTodo);
        message = AppStrings.todoAddedSuccess;
      }

      // Handle Notification - Instant notification on save
      await _notificationHandler.showNotification(
        title: isEditing ? 'Task Updated' : 'Task Created',
        body: 'Task "$trimmedTitle" has been ${isEditing ? 'updated' : 'created'}.',
      );

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
          style: const TextStyle(fontSize: 20),
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
              const SizedBox(height: 16),
              // Reminder UI removed as per request to remove scheduled notifications.
              // Date/Time picker kept for Due Date.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.pickDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Obx(() => Text( // Wrapped in Obx
                        controller.selectedDate.value == null
                            ? 'Pilih Tanggal'
                            : DateFormat(
                                'dd MMM yyyy',
                              ).format(controller.selectedDate.value!),
                      )),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.pickTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Obx(() => Text( // Wrapped in Obx
                        controller.selectedTime.value == null
                            ? 'Pilih Jam'
                            : controller.selectedTime.value!.format(
                                context,
                              ),
                      )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Obx(
                () => FilledButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitForm,
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
