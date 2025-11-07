import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - iOS Blue
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryDark = Color(0xFF0051D5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF5856D6);
  static const Color accent = Color(0xFFFF9500);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);
  
  // Neutral Colors - iOS Style
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F2F7);
  static const Color inputFillColor = Color(0xFFF9F9F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);
  
  // Separator
  static const Color separator = Color(0xFFC6C6C8);
  static const Color separatorLight = Color(0xFFE5E5EA);
  
  // Card & Container
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E5EA);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF5856D6), Color(0xFFAF52DE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow
  static const Color shadowColor = Color(0x1A000000);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  
  // Dark Theme Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkTextTertiary = Color(0xFF636366);
  
  // Dark Theme Separator
  static const Color darkSeparator = Color(0xFF38383A);
  static const Color darkSeparatorLight = Color(0xFF2C2C2E);
  
  // Dark Theme Card & Container
  static const Color darkCardBackground = Color(0xFF1C1C1E);
  static const Color darkCardBorder = Color(0xFF38383A);
}
