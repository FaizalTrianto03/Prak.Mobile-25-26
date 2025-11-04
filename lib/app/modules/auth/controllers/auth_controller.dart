import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/values/app_strings.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Login
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authProvider.login(
        emailController.text.trim(),
        passwordController.text,
      );
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

  // Register
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authProvider.register(
        emailController.text.trim(),
        passwordController.text,
      );
      Get.snackbar(
        'Success',
        AppStrings.registerSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      Get.back();
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

  // Confirm password validator
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseConfirmPassword;
    }
    if (value != passwordController.text) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }
}
