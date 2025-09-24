import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Demo navigasi stateless yang memanfaatkan GetX untuk navigasi cepat.
class StatelessGetxPage extends StatelessWidget {
  const StatelessGetxPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateless - GetX')),
      body: Column(
        children: [
          Container(height: 24),
          Center(child: const Text('Demo navigasi sederhana dengan GetX')),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Kembali'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Get.to(() => const _GetxSecond()),
                child: const Text('Ke halaman kedua'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GetxSecond extends StatelessWidget {
  const _GetxSecond({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetX - Halaman Kedua')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('Kembali'),
        ),
      ),
    );
  }
}
