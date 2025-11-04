import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/instrument_model.dart';
import '../../../data/providers/instrument_provider.dart';
import '../../../core/values/app_strings.dart';

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
      Get.back(result: true);
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
      Get.back(result: true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing
            ? AppStrings.editInstrument
            : AppStrings.addInstrument),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.instrumentName,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.music_note),
                  hintText: 'Enter instrument name',
                ),
                textInputAction: TextInputAction.next,
                validator: controller.validateName,
                enabled: !controller.isLoading.value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: AppStrings.description,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Enter description (optional)',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                enabled: !controller.isLoading.value,
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          controller.isEditing
                              ? AppStrings.updateInstrument
                              : AppStrings.addInstrument,
                          style: const TextStyle(fontSize: 16),
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
