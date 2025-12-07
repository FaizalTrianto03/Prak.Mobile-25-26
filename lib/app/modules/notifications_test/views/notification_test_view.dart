import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/notification_test_controller.dart';

class NotificationTestView extends GetView<NotificationTestController> {
  const NotificationTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Timer Notification',
                              style: TextStyle(fontSize: 16),
                            ),
                            Obx(
                              () => Text(
                                '${controller.timerValue.value.toInt()} seconds',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Obx(
                      () => Slider(
                        value: controller.timerValue.value,
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: controller.timerValue.value.round().toString(),
                        onChanged: (double value) {
                          controller.timerValue.value = value;
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.startTimerNotification,
                        child: const Text('Start Timer'),
                      ),
                    ),
                  ],
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
