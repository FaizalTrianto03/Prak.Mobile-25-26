import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Halaman demo Asynchronous Programming
// Di sini kalian akan belajar konsep-konsep penting async di Dart:
// 1. Future - untuk operasi yang butuh waktu (network, file, dll)
// 2. async/await - cara menulis kode async yang mudah dibaca
// 3. Event Loop - cara Dart jalanin kode async
// 4. Error handling - handle error dalam async code
class AsyncDemoView extends StatefulWidget {
  const AsyncDemoView({super.key});

  @override
  State<AsyncDemoView> createState() => _AsyncDemoViewState();
}

class _AsyncDemoViewState extends State<AsyncDemoView> {
  String _output = '';

  void _addOutput(String text) {
    setState(() {
      _output += '$text\n';
    });
  }

  void _clearOutput() {
    setState(() {
      _output = '';
    });
  }

  // Demo 1: Dasar Future dan async/await
  Future<void> _demoBasicFuture() async {
    _clearOutput();
    _addOutput('=== Demo 1: Basic Future ===');
    _addOutput('Start fetching data...');
    
    // Future.delayed = bikin delay artificial (simulasi network request)
    await Future.delayed(const Duration(seconds: 2));
    
    _addOutput('Data received!');
    _addOutput('Demo selesai\n');
  }

  // Demo 2: Multiple async calls - Sequential (satu per satu)
  Future<void> _demoSequentialAsync() async {
    _clearOutput();
    _addOutput('=== Demo 2: Sequential Async ===');
    
    final stopwatch = Stopwatch()..start();
    
    // Fetch satu per satu, tunggu yang satu selesai baru lanjut
    _addOutput('Fetching user data...');
    await _fetchUserData(); // Tunggu 1 detik
    _addOutput('User data received');
    
    _addOutput('Fetching posts...');
    await _fetchPosts(); // Tunggu lagi 1 detik
    _addOutput('Posts received');
    
    _addOutput('Fetching comments...');
    await _fetchComments(); // Tunggu lagi 1 detik
    _addOutput('Comments received');
    
    stopwatch.stop();
    _addOutput('\nTotal time: ${stopwatch.elapsedMilliseconds}ms\n');
    // Total = 3 detik karena tunggu satu per satu
  }

  // Demo 3: Multiple async calls - Parallel (bersamaan)
  Future<void> _demoParallelAsync() async {
    _clearOutput();
    _addOutput('=== Demo 3: Parallel Async ===');
    
    final stopwatch = Stopwatch()..start();
    
    _addOutput('Fetching all data in parallel...');
    
    // Future.wait = jalankan semua async call bersamaan
    // Lebih cepat dari sequential!
    await Future.wait([
      _fetchUserData(),
      _fetchPosts(),
      _fetchComments(),
    ]);
    
    _addOutput('All data received!');
    
    stopwatch.stop();
    _addOutput('Total time: ${stopwatch.elapsedMilliseconds}ms');
    _addOutput('(Lebih cepat dari sequential! Cuma ~1 detik)\n');
  }

  // Demo 4: Event Loop - cara Dart jalanin kode async
  Future<void> _demoEventLoop() async {
    _clearOutput();
    _addOutput('=== Demo 4: Event Loop ===\n');
    
    // Perhatikan urutan eksekusinya!
    _addOutput('1. Synchronous code'); // Langsung jalan
    
    Future(() {
      _addOutput('4. Microtask queue');
    });
    
    Future.microtask(() {
      _addOutput('3. Microtask (higher priority)'); // Prioritas lebih tinggi
    });
    
    _addOutput('2. More synchronous code'); // Jalan dulu sebelum async
    
    await Future.delayed(const Duration(milliseconds: 100));
    _addOutput('\n5. After await (event loop completed)\n');
  }

  // Demo 5: Error handling dalam async
  Future<void> _demoErrorHandling() async {
    _clearOutput();
    _addOutput('=== Demo 5: Error Handling ===');
    
    try {
      _addOutput('Attempting to fetch data...');
      await _fetchDataWithError(); // Ini akan throw error
      _addOutput('Success!');
    } catch (e) {
      // Catch block untuk tangkap error
      _addOutput('Error caught: $e');
    } finally {
      // Finally selalu jalan, mau error atau ngga
      _addOutput('Cleanup in finally block');
    }
    
    _addOutput('Program continues...\n');
  }

  // Demo 6: Timeout handling
  Future<void> _demoTimeout() async {
    _clearOutput();
    _addOutput('=== Demo 6: Timeout ===');
    
    try {
      _addOutput('Fetching with 3 second timeout...');
      
      // .timeout() untuk set batas waktu
      // Kalau lebih dari 3 detik, throw error
      await _fetchSlowData().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('Request took too long!');
        },
      );
      
      _addOutput('Success!');
    } catch (e) {
      _addOutput('Timeout error: $e');
    }
    
    _addOutput('');
  }

  // Helper functions untuk simulasi
  Future<void> _fetchUserData() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _fetchPosts() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _fetchComments() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _fetchDataWithError() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Network error!');
  }

  Future<void> _fetchSlowData() async {
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Async Programming Demo'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Demo buttons
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Async Programming Concepts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDemoButton(
                    context,
                    'Basic Future & Await',
                    'Dasar async/await dengan Future.delayed',
                    Icons.schedule,
                    _demoBasicFuture,
                  ),
                  
                  _buildDemoButton(
                    context,
                    'Sequential Async',
                    'Multiple async calls satu per satu',
                    Icons.linear_scale,
                    _demoSequentialAsync,
                  ),
                  
                  _buildDemoButton(
                    context,
                    'Parallel Async',
                    'Multiple async calls bersamaan',
                    Icons.compare_arrows,
                    _demoParallelAsync,
                  ),
                  
                  _buildDemoButton(
                    context,
                    'Event Loop',
                    'Visualisasi event loop & microtask',
                    Icons.loop,
                    _demoEventLoop,
                  ),
                  
                  _buildDemoButton(
                    context,
                    'Error Handling',
                    'Try-catch dalam async code',
                    Icons.error_outline,
                    _demoErrorHandling,
                  ),
                  
                  _buildDemoButton(
                    context,
                    'Timeout',
                    'Handle timeout dengan Future.timeout',
                    Icons.timer,
                    _demoTimeout,
                  ),
                ],
              ),
            ),
          ),
          
          // Output console
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: isDark ? Colors.black : Colors.grey.shade900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.terminal, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Console Output',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearOutput,
                          tooltip: 'Clear',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _output.isEmpty ? '// Output will appear here...' : _output,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: _output.isEmpty ? Colors.grey : Colors.greenAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Future<void> Function() onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_arrow),
        onTap: onPressed,
      ),
    );
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
