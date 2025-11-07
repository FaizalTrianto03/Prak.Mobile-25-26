import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/values/app_strings.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find();

  // Observable variables
  final isLoading = false.obs;

  // Login with email and password parameters
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await _authProvider.login(email.trim(), password);
      Get.snackbar(
        'Success',
        AppStrings.loginSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar(
        'Error',
        '${AppStrings.loginFailed}: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register with email and password parameters
  Future<void> register(String email, String password) async {
    isLoading.value = true;
    try {
      await _authProvider.register(email.trim(), password);
      Get.snackbar(
        'Success',
        AppStrings.registerSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Ensure any snackbars are closed, then return to the existing login page
      Get.closeAllSnackbars();
      Get.until((route) => route.settings.name == Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        '${AppStrings.registerFailed}: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authProvider.logout();
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // Navigate to register
  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  // Navigate to login
  void goToLogin() {
    Get.back();
  }

  // Email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterEmail;
    }
    if (!value.contains('@')) {
      return AppStrings.pleaseEnterValidEmail;
    }
    return null;
  }

  // Password validator
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterPassword;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }

  // Confirm password validator (requires password for comparison)
  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseConfirmPassword;
    }
    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }
}
