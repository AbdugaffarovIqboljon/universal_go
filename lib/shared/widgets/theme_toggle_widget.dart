import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:universal_go/core/providers/theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          onTap: () => _showThemeBottomSheet(context, themeProvider),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          leading:  Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getThemeIcon(themeProvider.themeMode),
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
              ),
          title: Text(
            'Theme',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                themeProvider.themeModeString,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 24.sp,
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  void _showThemeBottomSheet(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        void handleThemeSelection(ThemeMode mode) {
          themeProvider.setThemeMode(mode);
          Navigator.of(context).pop();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Title
              Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Text(
                'Select your preferred theme mode',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Theme Options
              RadioGroup<ThemeMode>(
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    handleThemeSelection(mode);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThemeOptionTile(
                      themeMode: ThemeMode.light,
                      icon: Icons.light_mode_outlined,
                      title: 'Light',
                      description: 'Always use light theme',
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onSelected: () => handleThemeSelection(ThemeMode.light),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    ThemeOptionTile(
                      themeMode: ThemeMode.dark,
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark',
                      description: 'Always use dark theme',
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onSelected: () => handleThemeSelection(ThemeMode.dark),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    ThemeOptionTile(
                      themeMode: ThemeMode.system,
                      icon: Icons.brightness_auto_outlined,
                      title: 'System',
                      description: 'Follow system setting',
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onSelected: () => handleThemeSelection(ThemeMode.system),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}

// Theme Option Tile with Radio Button

class ThemeOptionTile extends StatelessWidget {
  final ThemeMode themeMode;
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onSelected;

  const ThemeOptionTile({
    super.key,
    required this.themeMode,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color.fromRGBO(0, 0, 0, 0.06),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22.sp,
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            // Radio Button
            Radio<ThemeMode>(
              value: themeMode,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}