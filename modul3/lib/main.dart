import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Modul 3 - HTTP & Async",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
    ),
  );
}

/// Light Theme - Minimalist & Clean
ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF2C3E50),
      secondary: const Color(0xFF34495E),
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
      error: const Color(0xFFE74C3C),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF2C3E50),
      onBackground: const Color(0xFF2C3E50),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C3E50),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  );
}

/// Dark Theme - Minimalist & Clean
ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFECF0F1),
      secondary: const Color(0xFFBDC3C7),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: const Color(0xFFE74C3C),
      onPrimary: const Color(0xFF1E1E1E),
      onSecondary: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFECF0F1),
      onBackground: const Color(0xFFECF0F1),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFECF0F1),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFECF0F1),
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFECF0F1),
        foregroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}
