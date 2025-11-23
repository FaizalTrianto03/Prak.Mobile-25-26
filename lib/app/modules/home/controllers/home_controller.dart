import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthProvider _authProvider = Get.find();

  // Navigate to location tracker (old combined view)
  void goToLocation() {
    Get.toNamed(Routes.LOCATION);
  }

  // Navigate to network location (network provider only)
  void goToNetworkLocation() {
    Get.toNamed(Routes.NETWORK_LOCATION);
  }

  // Navigate to GPS location (GPS only)
  void goToGpsLocation() {
    Get.toNamed(Routes.GPS_LOCATION);
  }

  // Get user email
  String? get userEmail => _authProvider.currentUser?.email;
}
