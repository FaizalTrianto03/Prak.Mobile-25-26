import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_log_model.dart';
import '../services/local_storage_service.dart';

class NotificationProvider extends GetxService {
  final LocalStorageService _localStorage = Get.find();

  Box<NotificationLogModel> get _box => _localStorage.notificationBox;

  ValueListenable<Box<NotificationLogModel>> listenable() => _box.listenable();

  List<NotificationLogModel> getLogs() {
    return _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addLog(NotificationLogModel log) async {
    await _box.add(log);
  }

  Future<void> clearLogs() async {
    await _box.clear();
  }
}

