import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/note_model.dart';
import '../../../data/providers/note_provider.dart';
import '../../../core/values/app_strings.dart';
import '../../../routes/app_pages.dart';

class NoteController extends GetxController {
  final NoteProvider _noteProvider = Get.find();

  final notes = <NoteModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    isLoading.value = true;
    try {
      final data = await _noteProvider.getNotes();
      notes.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        '${AppStrings.errorLoadingNotes}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNote(int id, String title) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text('${AppStrings.deleteConfirm} "$title"?'),
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
        await _noteProvider.deleteNote(id);
        Get.snackbar(
          'Success',
          AppStrings.noteDeletedSuccess,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadNotes();
      } catch (e) {
        Get.snackbar(
          'Error',
          '${AppStrings.errorDeletingNote}: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> goToForm({NoteModel? note}) async {
    final result = await Get.toNamed(
      Routes.NOTE_FORM,
      arguments: note,
    );

    if (result != null) {
      await loadNotes();

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

