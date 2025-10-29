import 'package:flutter/material.dart';

/// 💡 AppColors — dizayner palitrasi uchun.
/// Har bir rang uchun light va dark versiyasi mavjud.
/// Faqat ranglarni saqlaydi, hech qanday ThemeData yo‘q.
class AppColorsLight {
  static const primary = Color(0xFF5B67F1);
  static const secondary = Color(0xFF6B63FF);
  static const accent = Color(0xFFA29BFE);

  static const surface = Colors.white;

  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF334155);

  static const border = Color(0xFFE2E8F0);
  static const error = Color(0xFFFF5C5C);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
}

class AppColorsDark {
  static const primary = Color(0xFF818CF8);
  static const secondary = Color(0xFFA5B4FC);
  static const accent = Color(0xFFC7D2FE);

  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);

  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFFCBD5E1);

  static const border = Color(0xFF334155);
  static const error = Color(0xFFFF6B6B);

  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFACC15);
}
