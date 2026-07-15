import 'package:flutter/material.dart';

/// Placeholder brand palette — swap for the academy's real brand colors.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0EA5A4); // teal — "pool water"
  static const primaryDark = Color(0xFF0B7F7E);
  static const secondary = Color(0xFF2563EB); // blue accent
  static const accentPink = Color(0xFFDB2777); // ladies-only accent
  static const accentPurple = Color(0xFF7C3AED); // private lessons accent

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);

  static const darkBackground = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF141E30);
  static const darkBorder = Color(0xFF243044);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);

  static Color fromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
