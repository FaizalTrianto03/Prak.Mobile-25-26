import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../controllers/instrument_controller.dart';

class InstrumentListView extends GetView<InstrumentController> {
  const InstrumentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.instruments),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.instruments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_note_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noData,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadInstruments,
          child: ListView.builder(
            itemCount: controller.instruments.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final instrument = controller.instruments[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    instrument.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: instrument.description != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            instrument.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : null,
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(AppStrings.edit),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8),
                            Text(AppStrings.delete),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        controller.goToForm(instrument: instrument);
                      } else if (value == 'delete') {
                        controller.deleteInstrument(
                          instrument.id!,
                          instrument.name,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.goToForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addInstrument),
      ),
    );
  }
}
