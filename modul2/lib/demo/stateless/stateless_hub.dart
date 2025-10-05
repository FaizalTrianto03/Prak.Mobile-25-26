import 'package:flutter/material.dart';

import 'stateless_navigator.dart';
import 'stateless_gorouter.dart';
import 'stateless_getx.dart';

// Halaman penghubung untuk demo stateless.
// Menyajikan opsi navigasi yang berbeda sebagai contoh.
class StatelessHubPage extends StatelessWidget {
  const StatelessHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Stateless')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatelessNavigatorPage()),
              ),
              child: const Text('Navigator (Imperatif)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatelessGoRouterPage()),
              ),
              child: const Text('GoRouter (tertanam)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatelessGetxPage()),
              ),
              child: const Text('GetX Navigation (menggunakan Get.to)'),
            ),
          ],
        ),
      ),
    );
  }
}
