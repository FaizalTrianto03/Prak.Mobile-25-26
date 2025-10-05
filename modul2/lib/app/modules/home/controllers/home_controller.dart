import 'package:get/get.dart';

class HomeController extends GetxController {
  // Counter sederhana (observable) yang dipakai oleh HomeView
  // untuk menampilkan dan memperbarui nilai secara reaktif.
  final count = 0.obs;

  void increment() => count.value++;
}
