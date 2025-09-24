import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Demo GoRouter yang di-embed di dalam widget stateless.
class StatelessGoRouterPage extends StatelessWidget {
  const StatelessGoRouterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (c, s) => const _Home()),
        GoRoute(path: '/second', builder: (c, s) => const _Second()),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Stateless GoRouter Demo',
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('GoRouter - Halaman Utama')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => GoRouter.of(context).go('/second'),
            child: const Text('Ke halaman kedua'),
          ),
        ),
      );
}

class _Second extends StatelessWidget {
  const _Second({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('GoRouter - Halaman Kedua')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => GoRouter.of(context).go('/'),
            child: const Text('Kembali ke awal'),
          ),
        ),
      );

}
