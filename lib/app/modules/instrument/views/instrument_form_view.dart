import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/instrument_model.dart';
import '../../../data/providers/instrument_provider.dart';
import '../../../core/values/app_strings.dart';
import '../controllers/instrument_controller.dart';
import '../../../routes/app_pages.dart';

class InstrumentFormController extends GetxController {
  final InstrumentProvider _instrumentProvider = Get.find();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  InstrumentModel? instrument;

  // Form key
  final formKey = GlobalKey<FormState>();

  bool get isEditing => instrument != null;

  @override
  void onInit() {
    super.onInit();
    instrument = Get.arguments as InstrumentModel?;
    if (isEditing) {
      nameController.text = instrument!.name;
      descriptionController.text = instrument!.description ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Validate name
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterInstrumentName;
    }
    return null;
  }

  // Create instrument
  Future<void> createInstrument() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final newInstrument = InstrumentModel(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
      );

      await _instrumentProvider.createInstrument(newInstrument);

      Get.snackbar(
        'Success',
        AppStrings.instrumentAddedSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Trigger refresh in list controller before going back
      try {
        final listController = Get.find<InstrumentController>();
        // Fire-and-forget refresh to avoid blocking navigation
        // ignore: unawaited_futures
        listController.loadInstruments();
      } catch (e) {
        print('InstrumentController not found: $e');
      }

      // Ensure any snackbars are closed, then return to the existing list page
      Get.closeAllSnackbars();
      Get.until((route) => route.settings.name == Routes.INSTRUMENT_LIST);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error adding instrument: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update instrument
  Future<void> updateInstrument() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final updatedInstrument = instrument!.copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
      );

      await _instrumentProvider.updateInstrument(updatedInstrument);

      Get.snackbar(
        'Success',
        AppStrings.instrumentUpdatedSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Trigger refresh in list controller before going back
      try {
        final listController = Get.find<InstrumentController>();
        // Fire-and-forget refresh to avoid blocking navigation
        // ignore: unawaited_futures
        listController.loadInstruments();
      } catch (e) {
        print('InstrumentController not found: $e');
      }

      // Ensure any snackbars are closed, then return to the existing list page
      Get.closeAllSnackbars();
      Get.until((route) => route.settings.name == Routes.INSTRUMENT_LIST);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error updating instrument: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Submit form
  void submitForm() {
    if (isEditing) {
      updateInstrument();
    } else {
      createInstrument();
    }
  }
}

class InstrumentFormView extends StatelessWidget {
  InstrumentFormView({super.key});

  final controller = Get.put(InstrumentFormController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEditing
              ? AppStrings.editInstrument
              : AppStrings.addInstrument,
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
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.instrumentName,
                    prefixIcon: Icon(Icons.music_note_outlined),
                    hintText: 'Enter instrument name',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: controller.validateName,
                  enabled: !controller.isLoading.value,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => TextFormField(
                  controller: controller.descriptionController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.description,
                    prefixIcon: Icon(Icons.description_outlined),
                    hintText: 'Enter description (optional)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
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
                              ? AppStrings.updateInstrument
                              : AppStrings.addInstrument,
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
