import 'package:get/get.dart';
import '../controllers/instrument_controller.dart';

class InstrumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstrumentController>(
      () => InstrumentController(),
      fenix: true,  // Keep controller alive when navigating
    );
  }
}
