import 'package:get/get.dart';
import '../../../data/services/notification_handler.dart';

class NotificationTestController extends GetxController {
  final NotificationHandler _notificationHandler = Get.find();

  void playCustomSoundNotification() {
    _notificationHandler.showCustomSoundNotification();
  }

  void showInstantNotification() {
    _notificationHandler.showNotification(
      title: 'Test Notification',
      body: 'This is an instant notification test!',
    );
    Get.snackbar('Success', 'Notification triggered immediately');
  }

  void showDownloadProgressNotification() {
    _notificationHandler.showProgressNotification();
    Get.snackbar('Download Started', 'Check your notification shade for progress');
  }
}

