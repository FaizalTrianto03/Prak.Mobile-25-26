import 'package:flutter/material.dart';

import 'stateful_navigator.dart';
import 'stateful_gorouter.dart';
import 'stateful_getx.dart';

// Halaman penghubung untuk contoh-contoh stateful.
// Menyediakan tombol untuk membuka masing-masing demo navigation.
class StatefulHubPage extends StatelessWidget {
  const StatefulHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Stateful')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatefulNavigatorPage()),
              ),
              child: const Text('Navigator (Imperatif)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatefulGoRouterPage()),
              ),
              child: const Text('GoRouter (tertanam)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatefulGetxPage()),
              ),
              child: const Text('GetX Navigation (menggunakan Get.to)'),
            ),
          ],
        ),
      ),
    );
  }
}
