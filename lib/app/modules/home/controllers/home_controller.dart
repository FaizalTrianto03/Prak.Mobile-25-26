import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthProvider _authProvider = Get.find();

  // Navigate to todo list
  void goToTodos() {
    Get.toNamed(Routes.TODO_LIST);
  }

  // Get user email
  String? get userEmail => _authProvider.currentUser?.email;
}
