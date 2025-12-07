import 'package:hive/hive.dart';

part 'notification_log_model.g.dart';

@HiveType(typeId: 2)
class NotificationLogModel {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String body;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String type; // "push" or "local"

  NotificationLogModel({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
  });
}

