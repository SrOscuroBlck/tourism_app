import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1A1A1A);
  static const Color primaryLight = Color(0xFF2D2D2D);
  static const Color primaryDark = Color(0xFF000000);

  // Secondary Colors
  static const Color secondary = Color(0xFF6C63FF);
  static const Color secondaryLight = Color(0xFF9A94FF);
  static const Color secondaryDark = Color(0xFF3F37C9);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF0F0F0);
  static const Color chipBackground = Color(0xFFE8E8E8);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE91E63);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Other Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color overlay = Color(0x80000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF2D2D2D),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9A94FF),
  ];
}