import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/values/app_strings.dart';
import '../../../data/providers/auth_provider.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();
    final authController = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.instruments),
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.currentUser?.email ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.loggedIn,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(AppStrings.logout),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
              }
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.instruments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noInstrumentsYet,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.tapToAdd,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadInstruments,
            child: ListView.builder(
              itemCount: controller.instruments.length,
              itemBuilder: (context, index) {
                final instrument = controller.instruments[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        instrument.name[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      instrument.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: instrument.description != null
                        ? Text(instrument.description!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              controller.goToForm(instrument: instrument),
                          tooltip: AppStrings.edit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteInstrument(
                            instrument.id!,
                            instrument.name,
                          ),
                          tooltip: AppStrings.delete,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.goToForm(),
        tooltip: AppStrings.addInstrument,
        child: const Icon(Icons.add),
      ),
    );
  }
}
