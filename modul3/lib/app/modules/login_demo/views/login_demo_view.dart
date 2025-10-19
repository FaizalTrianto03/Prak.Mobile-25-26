import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Demo Login dengan Async
// Di sini kalian bisa lihat contoh real-world penggunaan async:
// - Form handling dengan loading state
// - Error handling yang user-friendly
// - Navigation setelah async operation selesai
class LoginDemoView extends StatefulWidget {
  const LoginDemoView({super.key});

  @override
  State<LoginDemoView> createState() => _LoginDemoViewState();
}

class _LoginDemoViewState extends State<LoginDemoView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login - pattern umum untuk form submission
  // Flow: Validate → Loading State → API Call → Handle Response
  Future<void> _handleLogin() async {
    // Validasi form dulu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Coba login (ini async, tunggu responsenya)
      await _simulateLoginAPI(
        _emailController.text,
        _passwordController.text,
      );

      // Berhasil! Kasih feedback ke user
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      // Error! Kasih tau ke user kenapa gagal
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // Finally block: selalu reset loading state
      // mounted check biar aman kalau widget udah di-dispose
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Simulasi API login dengan validation logic
  Future<void> _simulateLoginAPI(String email, String password) async {
    // Simulasi network delay 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi validation (credential hardcoded buat demo)
    if (email == 'admin@example.com' && password == 'password123') {
      return; // Login berhasil
    } else {
      throw Exception('Invalid email or password'); // Login gagal
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Successful'),
        content: const Text('Welcome back!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate ke home atau dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Demo (Async)'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Sign In',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Demo async form submission',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Info card
              Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Test Credentials',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Email: admin@example.com', style: TextStyle(fontSize: 13)),
                      const Text('Password: password123', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),

              // Login button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 24),

              // Additional info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Async Concepts Demo:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem('✓ Form validation'),
                    _buildInfoItem('✓ Async API simulation'),
                    _buildInfoItem('✓ Loading state management'),
                    _buildInfoItem('✓ Error handling with try-catch'),
                    _buildInfoItem('✓ Success feedback'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
