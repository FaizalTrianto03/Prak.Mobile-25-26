import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

// Tampilan utama aplikasi. Dari halaman ini pengguna bisa memilih
// untuk melihat demo stateless atau stateful.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar (AppBar + body) untuk halaman.
    return Scaffold(
      appBar: AppBar(
        // Judul halaman
        title: const Text('Beranda'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informasi singkat bahwa tampilan sudah berfungsi
            const Text('HomeView sudah berjalan', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            // Tombol menuju kumpulan demo stateless
            ElevatedButton(
              onPressed: () => Get.toNamed('/demo/stateless'),
              child: const Text('Demo Stateless'),
            ),
            const SizedBox(height: 8),
            // Tombol menuju kumpulan demo stateful
            ElevatedButton(
              onPressed: () => Get.toNamed('/demo/stateful'),
              child: const Text('Demo Stateful'),
            ),
          ],
        ),
      ),
    );
  }
}
