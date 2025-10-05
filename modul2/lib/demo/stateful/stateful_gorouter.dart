import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Contoh penggunaan GoRouter yang dibungkus di dalam StatefulWidget.
// Flag di sini hanya untuk contoh state lokal yang dapat di-toggle.
class StatefulGoRouterPage extends StatefulWidget {
  const StatefulGoRouterPage({Key? key}) : super(key: key);

  @override
  State<StatefulGoRouterPage> createState() => _StatefulGoRouterPageState();
}

class _StatefulGoRouterPageState extends State<StatefulGoRouterPage> {
  bool flag = false;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (c, s) => _Home(flag: flag, toggle: _toggle)),
      GoRoute(path: '/second', builder: (c, s) => const _Second()),
    ]);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Stateful GoRouter Demo',
    );
  }

  void _toggle() => setState(() => flag = !flag);
}

class _Home extends StatelessWidget {
  final bool flag;
  final VoidCallback toggle;
  const _Home({Key? key, required this.flag, required this.toggle}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('GoRouter - Halaman Utama (stateful)')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Flag: $flag'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: toggle, child: const Text('Toggle')),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () => GoRouter.of(context).go('/second'), child: const Text('Ke halaman kedua')),
            ],
          ),
        ),
      );
}

class _Second extends StatelessWidget {
  const _Second({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('GoRouter - Halaman Kedua')),
        body: Center(child: ElevatedButton(onPressed: () => GoRouter.of(context).go('/'), child: const Text('Kembali'))),
      );
}
