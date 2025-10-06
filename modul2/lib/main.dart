import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

// Titik masuk aplikasi.
// Menggunakan GetMaterialApp agar routing dan dependency injection
// dari paket GetX bisa langsung dipakai.
void main() {
  runApp(
    GetMaterialApp(
      title: "Aplikasi",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      // Theme configuration untuk light dan dark mode
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system, // Mengikuti system preference
    ),
  );
}

/// Light Theme - Minimalist, Clean, Modern
ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme dengan warna solid yang elegan
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF2C3E50), // Navy blue elegant
      secondary: const Color(0xFF34495E), // Soft slate
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
      error: const Color(0xFFE74C3C),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF2C3E50),
      onBackground: const Color(0xFF2C3E50),
    ),
    
    // AppBar theme
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
    
    // Card theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated button theme
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
    
    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: const Color(0xFF2C3E50),
      inactiveTrackColor: const Color(0xFFE0E0E0),
      thumbColor: const Color(0xFF2C3E50),
      overlayColor: const Color(0xFF2C3E50).withOpacity(0.2),
      valueIndicatorColor: const Color(0xFF2C3E50),
    ),
    
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  );
}

/// Dark Theme - Minimalist, Clean, Modern
ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme dengan warna solid yang elegan untuk dark mode
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFECF0F1), // Light gray untuk kontras
      secondary: const Color(0xFFBDC3C7), // Medium gray
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: const Color(0xFFE74C3C),
      onPrimary: const Color(0xFF1E1E1E),
      onSecondary: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFECF0F1),
      onBackground: const Color(0xFFECF0F1),
    ),
    
    // AppBar theme untuk dark mode
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
    
    // Card theme untuk dark mode
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated button theme untuk dark mode
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
    
    // Slider theme untuk dark mode
    sliderTheme: SliderThemeData(
      activeTrackColor: const Color(0xFFECF0F1),
      inactiveTrackColor: const Color(0xFF424242),
      thumbColor: const Color(0xFFECF0F1),
      overlayColor: const Color(0xFFECF0F1).withOpacity(0.2),
      valueIndicatorColor: const Color(0xFFECF0F1),
    ),
    
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}
