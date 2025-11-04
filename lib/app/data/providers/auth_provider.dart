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
      print('Login successful');
      return response;
    } catch (e) {
      print('Login error: $e');
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
      print('Registration successful');
      return response;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _supabaseService.client.auth.signOut();
      print('User logged out');
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
