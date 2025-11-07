import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../data/models/note_model.dart';
import '../../../data/providers/note_provider.dart';
import '../controllers/note_controller.dart';

class NoteFormController extends GetxController {
  final NoteProvider _noteProvider = Get.find();

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  NoteModel? note;

  bool get isEditing => note != null;

  @override
  void onInit() {
    super.onInit();
    note = Get.arguments as NoteModel?;
    if (note != null) {
      titleController.text = note!.title;
      contentController.text = note!.content;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterNoteTitle;
    }
    return null;
  }

  String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterNoteContent;
    }
    return null;
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      String successMessage;
      if (isEditing) {
        final updated = note!.copyWith(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
        );
        await _noteProvider.updateNote(updated);
        successMessage = AppStrings.noteUpdatedSuccess;
      } else {
        final newNote = NoteModel(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
        );
        await _noteProvider.createNote(newNote);
        successMessage = AppStrings.noteAddedSuccess;
      }

      try {
        final listController = Get.find<NoteController>();
        // Fire and forget refresh so navigation can proceed immediately
        // ignore: unawaited_futures
        listController.loadNotes();
      } catch (_) {
        // Silently ignore if list controller is not available in the stack
      }

      Get.back(result: successMessage);
    } catch (e) {
      Get.snackbar(
        'Error',
        '${AppStrings.errorSavingNote}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class NoteFormView extends StatelessWidget {
  NoteFormView({super.key});

  final controller = Get.put(NoteFormController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEditing ? AppStrings.editNote : AppStrings.addNote,
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
                    labelText: AppStrings.noteTitle,
                    prefixIcon: Icon(Icons.title_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: controller.validateTitle,
                  enabled: !controller.isLoading.value,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => TextFormField(
                  controller: controller.contentController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.noteContent,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  textInputAction: TextInputAction.newline,
                  minLines: 5,
                  validator: controller.validateContent,
                  enabled: !controller.isLoading.value,
                ),
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
                              ? AppStrings.updateNote
                              : AppStrings.saveNote,
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
