import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Home View - Halaman utama untuk navigasi ke semua modul
class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 3 - HTTP & Async'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card - welcome section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.api,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'API Call & Async Programming',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yuk belajar HTTP, Dio, dan Async Dart!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Kartu navigasi ke modul API
              _buildSectionTitle(context, 'API Implementation'),
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                context,
                icon: Icons.http,
                title: 'HTTP Package',
                subtitle: 'Demo HTTP package dengan MediaQuery responsive',
                color: const Color(0xFF3498DB),
                onTap: () => Get.toNamed('/countries-http'),
              ),
              
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                context,
                icon: Icons.flash_on,
                title: 'Dio Package',
                subtitle: 'Demo Dio dengan LayoutBuilder dan progress tracking',
                color: const Color(0xFF9B59B6),
                onTap: () => Get.toNamed('/countries-dio'),
              ),
              
              const SizedBox(height: 32),
              
              // Kartu navigasi ke modul Async
              _buildSectionTitle(context, 'Async Programming'),
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                context,
                icon: Icons.code,
                title: 'Async Demo',
                subtitle: 'Interactive demo Future, async/await, Event Loop',
                color: const Color(0xFF27AE60),
                onTap: () => Get.toNamed('/async-demo'),
              ),
              
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                context,
                icon: Icons.login,
                title: 'Login Simulation',
                subtitle: 'Contoh real-world form login dengan async',
                color: const Color(0xFFE67E22),
                onTap: () => Get.toNamed('/login-demo'),
              ),
              
              const SizedBox(height: 32),
              
              // List materi yang dipelajari
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Materi yang Dipelajari',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLearningItem('✓ HTTP & Dio - dua cara fetch data dari API'),
                    _buildLearningItem('✓ REST API integration dengan REST Countries'),
                    _buildLearningItem('✓ Async programming - Future, async/await'),
                    _buildLearningItem('✓ Event Loop - cara Dart jalanin kode async'),
                    _buildLearningItem('✓ Error handling yang proper dalam async'),
                    _buildLearningItem('✓ Loading states & user feedback'),
                    _buildLearningItem('✓ Responsive design - MediaQuery vs LayoutBuilder'),
                    _buildLearningItem('✓ GetX - state management yang simple'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLearningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
