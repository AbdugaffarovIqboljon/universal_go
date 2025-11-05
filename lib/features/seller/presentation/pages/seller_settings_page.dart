import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/core/providers/theme_provider.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';
import 'package:universal_go/shared/widgets/theme_toggle_bottom_sheet.dart';

class SellerSettingsPage extends StatelessWidget {
  const SellerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Column(
        children: [
          const GradientAppBar(
            title: 'Settings',
            subtitle: "Manage your preferences",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Profile Card
                  ShopProfileCard(isDark: isDark),
                  SizedBox(height: 24.h),

                  // Preferences Section
                  SectionHeader(title: 'Preferences', isDark: isDark),
                  SizedBox(height: 12.h),
                  SettingsCard(
                    isDark: isDark,
                    children: [
                      AppearanceMenuItem(isDark: isDark),
                      SettingsMenuItem(
                        icon: Icons.language_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Language',
                        subtitle: 'English',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Language settings coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Support & Information Section
                  SectionHeader(title: 'Support & Information', isDark: isDark),
                  SizedBox(height: 12.h),
                  SettingsCard(
                    isDark: isDark,
                    children: [
                      SettingsMenuItem(
                        icon: Icons.help_outline,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Seller Help Center',
                        subtitle: 'Get help with your shop',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Help Center coming soon')),
                          );
                        },
                      ),
                      SettingsMenuItem(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'About Us',
                        subtitle: 'Learn more about our platform',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('About Us coming soon')),
                          );
                        },
                      ),
                      SettingsMenuItem(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Privacy Policy',
                        subtitle: 'How we protect your data',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Privacy Policy coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Logout
                  SettingsCard(
                    isDark: isDark,
                    children: [
                      SettingsMenuItem(
                        icon: Icons.logout_outlined,
                        iconColor: const Color(0xFFEC4899),
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        isDark: isDark,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: const Color(0xFFEC4899),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shop Profile Card Widget
class ShopProfileCard extends StatelessWidget {
  final bool isDark;

  const ShopProfileCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(24.r),
      border: Border.all(
        color: const Color(0xFFF3F4F6),
        width: 1,
        ),
      ),
      child: Row(
        children: [
          // Shop Image
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=2070'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tech Haven Store',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13.sp,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '123 Main Street...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Edit Button
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.sellerShopSetup);
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF8B85F5).withValues(alpha: 0.1)
                    : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.edit,
                size: 19.sp,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const SectionHeader({super.key, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
      ),
    );
  }
}

// Settings Card Container
class SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const SettingsCard({super.key, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}



// Appearance Menu Item - Uses ThemeBottomSheet
class AppearanceMenuItem extends StatelessWidget {
  final bool isDark;

  const AppearanceMenuItem({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return InkWell(
          onTap: () => ThemeBottomSheet.show(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                        : const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    size: 21.sp,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                SizedBox(width: 14.w),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        themeProvider.themeModeString,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  size: 22.sp,
                  color: isDark 
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFD1D5DB),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Settings Menu Item Widget
class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback? onTap;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isDark 
                    ? iconColor.withValues(alpha: 0.15)
                    : iconColor == const Color(0xFFEC4899)
                        ? const Color(0xFFFCE7F3)
                        : const Color(0xFF8B85F5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 21.sp,
                color: iconColor,
              ),
            ),
            SizedBox(width: 14.w),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              size: 22.sp,
              color: isDark 
                  ? const Color(0xFF4B5563)
                  : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}