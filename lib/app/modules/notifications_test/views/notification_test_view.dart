import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/notification_test_controller.dart';

class NotificationTestView extends GetView<NotificationTestController> {
  const NotificationTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test Notifications',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instruction for Custom Sound',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Terdapat file audio default yang akan diputar. Tugas Anda adalah menemukan di mana file tersebut disimpan dalam struktur project Android dan menggantinya dengan audio pilihan Anda sendiri!\n\nClue: Periksa folder resource Android.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.music_note, color: Colors.purple),
                title: const Text('Custom Audio Notification'),
                subtitle: const Text('Plays a custom sound'),
                trailing: ElevatedButton(
                  onPressed: controller.playCustomSoundNotification,
                  child: const Text('Play'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_active, color: Colors.orange),
                title: const Text('Instant Notification'),
                subtitle: const Text('Test instant notification'),
                trailing: ElevatedButton(
                  onPressed: controller.showInstantNotification,
                  child: const Text('Show'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.download, color: Colors.green),
                title: const Text('Progress Notification'),
                subtitle: const Text('Simulates a download progress'),
                trailing: ElevatedButton(
                  onPressed: controller.showDownloadProgressNotification,
                  child: const Text('Start'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
