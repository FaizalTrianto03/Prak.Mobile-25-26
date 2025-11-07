import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/values/app_strings.dart';
import '../../../data/models/note_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/note_provider.dart';
import '../../../data/services/storage_service.dart';
import '../controllers/note_controller.dart';

class NoteFormController extends GetxController {
  final NoteProvider _noteProvider = Get.find();
  final StorageService _storageService = Get.find();
  final AuthProvider _authProvider = Get.find();
  final ImagePicker _picker = ImagePicker();

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final selectedImage = Rxn<XFile>();
  final selectedImageBytes = Rxn<Uint8List>();
  final existingImageUrl = RxnString();

  NoteModel? note;
  bool _removeExistingImage = false;

  bool get isEditing => note != null;
  bool get hasPreviewImage =>
      selectedImage.value != null ||
      selectedImageBytes.value != null ||
      existingImageUrl.value != null;

  @override
  void onInit() {
    super.onInit();
    note = Get.arguments as NoteModel?;
    if (note != null) {
      titleController.text = note!.title;
      contentController.text = note!.content;

      if (note!.imageUrl != null) {
        existingImageUrl.value = note!.imageUrl;
      } else if (note!.imagePath != null && note!.imagePath!.isNotEmpty) {
        try {
          existingImageUrl.value = _storageService.getPublicUrl(
            NoteController.bucketId,
            note!.imagePath!,
          );
        } catch (e) {
          debugPrint('Unable to load existing image URL: $e');
        }
      }
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

  Future<void> pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (file != null) {
        selectedImage.value = file;
        existingImageUrl.value = null;
        _removeExistingImage = false;

        if (kIsWeb) {
          selectedImageBytes.value = await file.readAsBytes();
        } else {
          selectedImageBytes.value = null;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeImage() {
    selectedImage.value = null;
    selectedImageBytes.value = null;
    if (isEditing && note?.imagePath != null) {
      _removeExistingImage = true;
    }
    existingImageUrl.value = null;
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final trimmedTitle = titleController.text.trim();
    final trimmedContent = contentController.text.trim();

    final oldImagePath = note?.imagePath;
    String? imagePath = oldImagePath;
    String? uploadedImagePath;
    var deleteOldAfterSuccess = false;

    try {
      if (_removeExistingImage) {
        imagePath = null;
        if (oldImagePath != null && oldImagePath.isNotEmpty) {
          deleteOldAfterSuccess = true;
        }
      }

      if (selectedImage.value != null) {
        uploadedImagePath = await _uploadSelectedImage();
        imagePath = uploadedImagePath;
        if (oldImagePath != null &&
            oldImagePath.isNotEmpty &&
            oldImagePath != uploadedImagePath) {
          deleteOldAfterSuccess = true;
        }
      }

      String successMessage;
      if (isEditing) {
        final updated = note!.copyWith(
          title: trimmedTitle,
          content: trimmedContent,
          imagePath: imagePath,
          clearImage: imagePath == null,
        );
        await _noteProvider.updateNote(updated);
        successMessage = AppStrings.noteUpdatedSuccess;
      } else {
        final newNote = NoteModel(
          title: trimmedTitle,
          content: trimmedContent,
          imagePath: imagePath,
        );
        await _noteProvider.createNote(newNote);
        successMessage = AppStrings.noteAddedSuccess;
      }

      if (deleteOldAfterSuccess &&
          oldImagePath != null &&
          oldImagePath.isNotEmpty) {
        unawaited(_deleteImage(oldImagePath));
      }

      try {
        final listController = Get.find<NoteController>();
        // ignore: unawaited_futures
        listController.loadNotes();
      } catch (_) {}

      Get.back(result: successMessage);
    } catch (e) {
      if (uploadedImagePath != null && uploadedImagePath != oldImagePath) {
        unawaited(_deleteImage(uploadedImagePath));
      }

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

  Future<String> _uploadSelectedImage() async {
    final file = selectedImage.value;
    if (file == null) {
      throw StateError('No image selected');
    }

    final extension = _fileExtension(file);
    final userId = _authProvider.currentUser?.id ?? 'public';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = '$userId/$timestamp$extension';

    if (kIsWeb) {
      final bytes = selectedImageBytes.value ?? await file.readAsBytes();
      await _storageService.uploadBytes(
        NoteController.bucketId,
        storagePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
    } else {
      await _storageService.uploadFile(
        NoteController.bucketId,
        storagePath,
        File(file.path),
        fileOptions: const FileOptions(upsert: true),
      );
    }

    return storagePath;
  }

  Future<void> _deleteImage(String path) async {
    try {
      await _storageService.deleteFiles(NoteController.bucketId, [path]);
    } catch (e) {
      debugPrint('Failed to delete image "$path": $e');
    }
  }

  String _fileExtension(XFile file) {
    final name = file.name.isNotEmpty ? file.name : file.path;
    final ext = p.extension(name);
    if (ext.isEmpty) {
      return '.jpg';
    }
    return ext;
  }
}

class NoteFormView extends StatelessWidget {
  NoteFormView({super.key});

  final controller = Get.put(NoteFormController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
              const SizedBox(height: 24),
              _ImageAttachmentSection(controller: controller),
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

class _ImageAttachmentSection extends StatelessWidget {
  const _ImageAttachmentSection({required this.controller});

  final NoteFormController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final pickedFile = controller.selectedImage.value;
      final pickedBytes = controller.selectedImageBytes.value;
      final existingUrl = controller.existingImageUrl.value;
      final hasPreview = controller.hasPreviewImage;
      final isDisabled = controller.isLoading.value;

      Widget preview;
      if (pickedBytes != null) {
        preview = Image.memory(
          pickedBytes,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } else if (pickedFile != null && !kIsWeb) {
        preview = Image.file(
          File(pickedFile.path),
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } else if (existingUrl != null) {
        preview = Image.network(
          existingUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, _, _) => _Placeholder(theme: theme),
        );
      } else {
        preview = _Placeholder(theme: theme);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.imagePreview,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 200,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child: preview,
            ),
          ),
          if (!hasPreview)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                AppStrings.imageAttachmentOptional,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: isDisabled ? null : controller.pickImage,
                icon: Icon(
                  hasPreview
                      ? Icons.photo_library_outlined
                      : Icons.add_photo_alternate_outlined,
                ),
                label: Text(
                  hasPreview ? AppStrings.changeImage : AppStrings.addImage,
                ),
              ),
              if (hasPreview)
                TextButton.icon(
                  onPressed: isDisabled ? null : controller.removeImage,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(AppStrings.removeImage),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.photo_outlined,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}
