import 'package:flutter/material.dart';

// Demo penggunaan Navigator (imperative) dengan state lokal sederhana.
class StatefulNavigatorPage extends StatefulWidget {
  const StatefulNavigatorPage({super.key});

  @override
  State<StatefulNavigatorPage> createState() => _StatefulNavigatorPageState();
}

class _StatefulNavigatorPageState extends State<StatefulNavigatorPage> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateful - Navigator')),
      body: Column(
        children: [
          Container(height: 12),
          Text('Counter: $counter'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => counter++),
                child: const Text('+'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
