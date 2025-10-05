import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Contoh halaman stateful sederhana yang menggunakan
// GetX hanya untuk navigasi (Get.to / Get.back).
class StatefulGetxPage extends StatefulWidget {
  const StatefulGetxPage({Key? key}) : super(key: key);

  @override
  State<StatefulGetxPage> createState() => _StatefulGetxPageState();
}

class _StatefulGetxPageState extends State<StatefulGetxPage> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateful - GetX')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Menampilkan nilai counter lokal
            Text('Nilai: $value'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => setState(() => value++), child: const Text('+')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => Get.to(() => const _GetxStateSecond()), child: const Text('Ke halaman kedua')),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
          ],
        ),
      ),
    );
  }
}

class _GetxStateSecond extends StatelessWidget {
  const _GetxStateSecond({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetX - Halaman Kedua')),
      body: Center(child: ElevatedButton(onPressed: () => Get.back(), child: const Text('Kembali'))),
    );
  }
}
