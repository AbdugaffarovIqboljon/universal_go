import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Safe area dimensions
  double get safeAreaTop => MediaQuery.of(this).padding.top;
  double get safeAreaBottom => MediaQuery.of(this).padding.bottom;
  
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  
  // Navigation shortcuts
  NavigatorState get navigator => Navigator.of(this);
  
  // Responsive helpers
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
  
  // Keyboard
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;
  
  // Status bar
  bool get isStatusBarVisible => MediaQuery.of(this).padding.top > 0;
}
