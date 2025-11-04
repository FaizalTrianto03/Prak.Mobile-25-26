import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/instrument_model.dart';
import '../../../data/providers/instrument_provider.dart';
import '../../../core/values/app_strings.dart';
import '../../../routes/app_pages.dart';

class InstrumentController extends GetxController {
  final InstrumentProvider _instrumentProvider = Get.find();

  // Observable variables
  final instruments = <InstrumentModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadInstruments();
  }

  // Load instruments
  Future<void> loadInstruments() async {
    isLoading.value = true;
    try {
      final data = await _instrumentProvider.getInstruments();
      instruments.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error loading data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete instrument
  Future<void> deleteInstrument(int id, String name) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text('${AppStrings.deleteConfirm} "$name"?'),
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
        await _instrumentProvider.deleteInstrument(id);
        Get.snackbar(
          'Success',
          AppStrings.instrumentDeletedSuccess,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        loadInstruments();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Error deleting: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Navigate to form
  void goToForm({InstrumentModel? instrument}) {
    Get.toNamed(
      Routes.INSTRUMENT_FORM,
      arguments: instrument,
    );
  }
}
