import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/shared/styles/app_colors.dart';

// Material 3 theming with dynamic light/dark support.
// Uses ColorScheme.fromSeed, integrating legacy AppColors where sensible.

const _seedColor = Color(0xFF4E47DD);

ColorScheme _buildLightScheme() {
  final base = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );
  
  return base.copyWith(
    primary: AppColorsLight.primary,
    secondary: AppColorsLight.secondary,
    surface: AppColorsLight.surface,
    error: AppColorsLight.error,
    onPrimary: Colors.white,
    onSurface: AppColorsLight.textPrimary,
    // Material 3 tonal colors for soft buttons
    surfaceTint: AppColorsLight.primary,
    primaryContainer: AppColorsLight.primary.withValues(alpha: 0.12),
    onPrimaryContainer: AppColorsLight.primary,
  );
}

ColorScheme _buildDarkScheme() {
  final base = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );
  
  return base.copyWith(
    primary: AppColorsDark.primary,
    secondary: AppColorsDark.secondary,
    surface: AppColorsDark.surface,
    error: AppColorsDark.error,
    onPrimary: Colors.white,
    onSurface: AppColorsDark.textPrimary,
    // Material 3 tonal colors for soft buttons
    surfaceTint: AppColorsDark.primary,
    primaryContainer: AppColorsDark.primary.withValues(alpha: 0.15),
    onPrimaryContainer: AppColorsDark.primary,
  );
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Poppins',
  colorScheme: _buildLightScheme(),
  scaffoldBackgroundColor: AppColorsLight.surface,

  appBarTheme: AppBarTheme(
    backgroundColor: AppColorsLight.surface,
    foregroundColor: AppColorsLight.textPrimary,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColorsLight.textPrimary,
      fontFamily: 'Poppins',
    ),
  ),

  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16.sp, color: AppColorsLight.textPrimary),
    bodyMedium: TextStyle(fontSize: 15.sp, color: AppColorsLight.textPrimary),
    labelLarge: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColorsLight.textPrimary,
    ),
  ),

  // ElevatedButton - default Material 3 style, no forced colors
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        fontFamily: 'Poppins',
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
  ),

  // FilledButton - primary color, solid
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        fontFamily: 'Poppins',
      ),
      elevation: 0,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColorsLight.primary,
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        fontFamily: 'Poppins',
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColorsLight.primary,
      side: BorderSide(
        color: AppColorsLight.primary.withValues(alpha: 0.3),
        width: 1.5,
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        fontFamily: 'Poppins',
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColorsLight.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsLight.border.withValues(alpha: 0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsLight.border.withValues(alpha: 0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsLight.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsLight.error.withValues(alpha: 0.5),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsLight.error,
        width: 2,
      ),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColorsLight.surface,
    elevation: 0,
    margin: EdgeInsets.all(8.w),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.r),
      side: BorderSide(
        color: Colors.black.withValues(alpha: 0.05),
        width: 1,
      ),
    ),
  ),

  dividerTheme: DividerThemeData(
    color: Colors.black.withValues(alpha: 0.06),
    thickness: 1,
    space: 1,
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColorsLight.surface,
    selectedItemColor: AppColorsLight.primary,
    unselectedItemColor: AppColorsLight.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    ),
  ),

  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
    ),
    elevation: 8,
    backgroundColor: AppColorsLight.surface,
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    backgroundColor: AppColorsLight.textPrimary,
    contentTextStyle: TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Poppins',
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Poppins',
  colorScheme: _buildDarkScheme(),
  scaffoldBackgroundColor: AppColorsDark.background,

  appBarTheme: AppBarTheme(
    backgroundColor: AppColorsDark.surface,
    foregroundColor: AppColorsDark.textPrimary,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColorsDark.textPrimary,
      fontFamily: 'Poppins',
    ),
  ),

  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16.sp, color: AppColorsDark.textPrimary),
    bodyMedium: TextStyle(fontSize: 15.sp, color: AppColorsDark.textPrimary),
    labelLarge: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColorsDark.textPrimary,
    ),
  ),

  // ElevatedButton - default Material 3 style, no forced colors
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        fontFamily: 'Poppins',
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
  ),

  // FilledButton - primary color, solid
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        fontFamily: 'Poppins',
      ),
      elevation: 0,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColorsDark.primary,
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        fontFamily: 'Poppins',
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColorsDark.primary,
      side: BorderSide(
        color: AppColorsDark.primary.withValues(alpha: 0.3),
        width: 1.5,
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        fontFamily: 'Poppins',
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColorsDark.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsDark.border.withValues(alpha: 0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsDark.border.withValues(alpha: 0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsDark.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsDark.error.withValues(alpha: 0.5),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColorsDark.error,
        width: 2,
      ),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColorsDark.surface,
    elevation: 0,
    margin: EdgeInsets.all(8.w),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.r),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.06),
        width: 1,
      ),
    ),
  ),

  dividerTheme: DividerThemeData(
    color: Colors.white.withValues(alpha: 0.06),
    thickness: 1,
    space: 1,
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColorsDark.surface,
    selectedItemColor: AppColorsDark.primary,
    unselectedItemColor: AppColorsDark.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    ),
  ),

  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
    ),
    elevation: 8,
    backgroundColor: AppColorsDark.surface,
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    backgroundColor: AppColorsDark.textPrimary,
    contentTextStyle: TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Poppins',
    ),
  ),
);