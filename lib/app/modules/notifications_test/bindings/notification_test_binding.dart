import 'package:get/get.dart';
import '../controllers/notification_test_controller.dart';

class NotificationTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationTestController>(
      () => NotificationTestController(),
    );
  }
}

