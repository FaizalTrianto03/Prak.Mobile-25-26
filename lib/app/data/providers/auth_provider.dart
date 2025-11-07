import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends GetxService {
  final SupabaseService _supabaseService = Get.find();

  // Get current user
  User? get currentUser => _supabaseService.currentUser;

  // Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Login successful');
      return response;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  // Register
  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint('Registration successful');
      return response;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _supabaseService.client.auth.signOut();
      debugPrint('User logged out');
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
