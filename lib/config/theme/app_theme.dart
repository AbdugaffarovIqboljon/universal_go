import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // 💙 Base brand color family
  static const Color primaryColor = Color(0xFF5B67F1); // Calm Royal Blue
  static const Color secondaryColor = Color(0xFF7C83FD); // Soft Indigo
  static const Color accentColor = Color(0xFFA29BFE); // Lavender Blue
  static const Color errorColor = Color(0xFFFF5C5C); // Soft Red
  static const Color backgroundColor = Color(0xFFF9FAFB); // Near-white background
  static const Color surfaceColor = Colors.white;

  // Shades
  static const Color primaryLight = Color(0xFFB3B8FF); // Light blue tint
  static const Color primaryDark = Color(0xFF3E47B5); // Deep blue shade
  static const Color onPrimary = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: surfaceColor,
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceColor,
        onPrimary: onPrimary,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: const Color(0xFF1E293B), // Slate-800
      ),

      // 🧭 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: onPrimary,
          letterSpacing: 0.3,
        ),
      ),

      // 🚀 Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 3,
          shadowColor: primaryColor.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),

      // 🫧 Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),

      // 🩵 Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),

      // ✏️ Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: primaryColor, width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: errorColor, width: 2.w),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),

      // 🧊 Card
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        color: surfaceColor,
        margin: EdgeInsets.all(8.w),
      ),

      // ⚓ Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF94A3B8), // Slate-400
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 🩶 Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
        contentTextStyle: TextStyle(
          fontSize: 15.sp,
          color: const Color(0xFF334155),
        ),
      ),

      // Text
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16.sp, color: const Color(0xFF1E293B)),
        bodyMedium: TextStyle(fontSize: 15.sp, color: const Color(0xFF334155)),
        labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}