import 'package:get/get.dart';
import '../../../data/services/notification_handler.dart';

class NotificationTestController extends GetxController {
  final NotificationHandler _notificationHandler = Get.find();
  final RxDouble timerValue = 5.0.obs;

  void playCustomSoundNotification() {
    _notificationHandler.showCustomSoundNotification();
  }

  void startTimerNotification() {
    _notificationHandler.showScheduledTimerNotification(timerValue.value.toInt());
    Get.snackbar('Timer Started', 'Notification will appear in ${timerValue.value.toInt()} seconds');
  }

  void showDownloadProgressNotification() {
    _notificationHandler.showProgressNotification();
    Get.snackbar('Download Started', 'Check your notification shade for progress');
  }
}

