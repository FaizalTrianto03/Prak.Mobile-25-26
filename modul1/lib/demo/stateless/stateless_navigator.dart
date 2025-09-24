import 'package:flutter/material.dart';

// Demo layout stateless sederhana yang menunjukkan penggunaan Navigator.
class StatelessNavigatorPage extends StatelessWidget {
  const StatelessNavigatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: const Text('Stateless - Navigator')),
      body: Stack(
        children: [
          Container(color: Colors.grey[200]),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Contoh layout widget stateless', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const _NavigatorSecond()),
                      ),
                      child: const Text('Buka halaman kedua'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigatorSecond extends StatelessWidget {
  const _NavigatorSecond({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Kedua')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kembali'),
        ),
      ),
    );
  }
}
