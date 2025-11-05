import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:universal_go/core/providers/theme_provider.dart';
import 'package:universal_go/shared/widgets/theme_toggle_bottom_sheet.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = Theme.of(context)
        .colorScheme
        .primary
        .withValues(alpha: isDark ? 0.15 : 1.0);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 105.h),
        child: ProfileHeaderSection(
          name: 'John Doe',
          email: 'john.doe@example.com',
          joinedYear: '2023',
          appBarColor: appBarColor,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Account Section
                  const ProfileMenuSection(
                    title: 'Account',
                    items: [
                      ProfileMenuItem(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        isFirst: true,
                        isLast: false,
                      ),
                      ProfileMenuItem(
                        title: 'Addresses',
                        icon: Icons.location_on_outlined,
                        isFirst: false,
                        isLast: false,
                      ),
                      ProfileMenuItem(
                        title: 'Payment Methods',
                        icon: Icons.payment_outlined,
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Orders Section
                  const ProfileMenuSection(
                    title: 'Orders',
                    items: [
                      ProfileMenuItem(
                        title: 'Order History',
                        icon: Icons.history,
                        isFirst: true,
                        isLast: false,
                      ),
                      ProfileMenuItem(
                        title: 'Track Orders',
                        icon: Icons.local_shipping_outlined,
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Settings Section
                  ProfileMenuSection(
                    title: 'Settings',
                    items: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return ProfileMenuItem(
                            title: 'Theme',
                            icon: _getThemeIcon(themeProvider.themeMode),
                            isFirst: true,
                            isLast: false,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  themeProvider.themeModeString,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.3),
                                  size: 22.sp,
                                ),
                              ],
                            ),
                            onTap: () => ThemeBottomSheet.show(context),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        title: 'Language',
                        icon: Icons.language_outlined,
                        isFirst: false,
                        isLast: false,
                        trailing: Text(
                          'English',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const ProfileMenuItem(
                        title: 'Notifications',
                        icon: Icons.notifications_outlined,
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Legal Section
                  const ProfileMenuSection(
                    title: 'Legal',
                    items: [
                      ProfileMenuItem(
                        title: 'FAQ',
                        icon: Icons.help_outline,
                        isFirst: true,
                        isLast: false,
                      ),
                      ProfileMenuItem(
                        title: 'Privacy Policy',
                        icon: Icons.privacy_tip_outlined,
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => LogoutDialog.show(context),
                      icon: Icon(Icons.logout, size: 20.sp),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }
}

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String email;
  final String joinedYear;
  final Color? appBarColor;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.email,
    required this.joinedYear,
    this.appBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        right: 16.w,
        left: 16.w,
        top: 32.h,
        bottom: 12.h,
      ),
      color: appBarColor,
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.3),
                width: 3.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40.r,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              child: Icon(
                Icons.person,
                size: 45.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Name and Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Joined since $joinedYear',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Edit Profile Button
          Material(
            color:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.15),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to edit profile
              },
              customBorder: const CircleBorder(),
              splashColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
              highlightColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Icon(
                  Icons.edit,
                  size: 20.sp,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _buildItemsWithDividers(isDark),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildItemsWithDividers(bool isDark) {
    final result = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);

      // Add divider if not last
      if (i < items.length - 1) {
        result.add(Divider(
          height: 1,
          thickness: 1,
          indent: 60.w,
          endIndent: 16.w,
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
        ));
      }
    }

    return result;
  }
}

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(16.r) : Radius.zero,
          bottom: isLast ? Radius.circular(16.r) : Radius.zero,
        ),
        splashColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        highlightColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                    size: 22.sp,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeOptionTile extends StatelessWidget {
  final ThemeMode themeMode;
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeOptionTile({
    super.key,
    required this.themeMode,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        highlightColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
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
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15)
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3)
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Radio<ThemeMode>(
                value: themeMode,
                groupValue: isSelected ? themeMode : null,
                onChanged: (_) => onTap(),
                fillColor: WidgetStateProperty.resolveWith(
                  (_) => Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Logged out successfully'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          },
          child: Text(
            'Logout',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}
