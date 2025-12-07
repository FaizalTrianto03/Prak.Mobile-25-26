import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/models/notification_log_model.dart';

class NotificationHistoryView extends StatelessWidget {
  const NotificationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationProvider provider = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Notifikasi',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await provider.clearLogs();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<NotificationLogModel>>(
        valueListenable: provider.listenable(),
        builder: (context, box, _) {
          final logs = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (logs.isEmpty) {
            return const Center(child: Text('Tidak ada notifikasi'));
          }

          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: log.type == 'push' ? Colors.red[100] : Colors.blue[100],
                  child: Icon(
                    log.type == 'push' ? Icons.notifications_active : Icons.alarm,
                    color: log.type == 'push' ? Colors.red : Colors.blue,
                  ),
                ),
                title: Text(log.title),
                subtitle: Text(log.body),
                trailing: Text(
                  DateFormat('dd/MM HH:mm').format(log.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

