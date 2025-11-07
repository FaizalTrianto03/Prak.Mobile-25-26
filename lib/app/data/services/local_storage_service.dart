import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/todo_model.dart';

class LocalStorageService extends GetxService {
  static const String todoBoxName = 'todo_box';

  late final Box<TodoModel> _todoBox;

  Box<TodoModel> get todoBox => _todoBox;

  Future<LocalStorageService> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);
    }

    if (!Hive.isAdapterRegistered(TodoModel.typeId)) {
      Hive.registerAdapter(TodoModelAdapter());
    }

    _todoBox = await Hive.openBox<TodoModel>(todoBoxName);

    return this;
  }

  Future<void> close() async {
    await _todoBox.close();
  }
}
