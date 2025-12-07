import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/todo_model.dart';
import '../models/notification_log_model.dart';

class LocalStorageService extends GetxService {
  static const String todoBoxName = 'todo_box';
  static const String notificationBoxName = 'notification_log_box';

  late final Box<TodoModel> _todoBox;
  late final Box<NotificationLogModel> _notificationBox;

  Box<TodoModel> get todoBox => _todoBox;
  Box<NotificationLogModel> get notificationBox => _notificationBox;

  Future<LocalStorageService> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);
    }

    if (!Hive.isAdapterRegistered(TodoModelAdapter().typeId)) {
      Hive.registerAdapter(TodoModelAdapter());
    }
    if (!Hive.isAdapterRegistered(NotificationLogModelAdapter().typeId)) {
      Hive.registerAdapter(NotificationLogModelAdapter());
    }

    _todoBox = await Hive.openBox<TodoModel>(todoBoxName);
    _notificationBox = await Hive.openBox<NotificationLogModel>(notificationBoxName);

    return this;
  }

  Future<void> close() async {
    await _todoBox.close();
  }
}
