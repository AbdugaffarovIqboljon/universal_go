import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:universal_go/core/providers/theme_provider.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_profile_page.dart';

class ThemeBottomSheet extends StatelessWidget {
  const ThemeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ThemeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          SizedBox(height: 20.h),

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
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),

          SizedBox(height: 24.h),

          // Theme Options
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Column(
                children: [
                  ThemeOptionTile(
                    themeMode: ThemeMode.light,
                    icon: Icons.light_mode_outlined,
                    title: 'Light',
                    description: 'Always use light theme',
                    isSelected: themeProvider.themeMode == ThemeMode.light,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.light);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 12.h),
                  ThemeOptionTile(
                    themeMode: ThemeMode.dark,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark',
                    description: 'Always use dark theme',
                    isSelected: themeProvider.themeMode == ThemeMode.dark,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.dark);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 12.h),
                  ThemeOptionTile(
                    themeMode: ThemeMode.system,
                    icon: Icons.brightness_auto_outlined,
                    title: 'System',
                    description: 'Follow system setting',
                    isSelected: themeProvider.themeMode == ThemeMode.system,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.system);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}