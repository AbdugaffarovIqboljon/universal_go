import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/shared/widgets/theme_toggle_widget.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Fixed Header with Curve
          SliverToBoxAdapter(
            child: ProfileHeaderSection(
              name: 'John Doe',
              email: 'john.doe@example.com',
              joinedYear: '2023',
            ),
          ),

          // Scrollable Content
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account Section
                ProfileMenuSection(
                  title: 'Account',
                  items: [
                    ProfileMenuItem(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      onTap: () {
                        // TODO: Navigate to personal info
                      },
                    ),
                    ProfileMenuItem(
                      title: 'Addresses',
                      icon: Icons.location_on_outlined,
                      onTap: () {
                        // TODO: Navigate to addresses
                      },
                    ),
                    ProfileMenuItem(
                      title: 'Payment Methods',
                      icon: Icons.payment_outlined,
                      onTap: () {
                        // TODO: Navigate to payment methods
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Orders Section
                ProfileMenuSection(
                  title: 'Orders',
                  items: [
                    ProfileMenuItem(
                      title: 'Order History',
                      icon: Icons.history,
                      onTap: () {
                        // TODO: Navigate to order history
                      },
                    ),
                    ProfileMenuItem(
                      title: 'Track Orders',
                      icon: Icons.local_shipping_outlined,
                      onTap: () {
                        // TODO: Navigate to track orders
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Settings Section
                ProfileMenuSection(
                  title: 'Settings',
                  items: [
                    const ThemeToggleWidget(),
                    ProfileMenuItem(
                      title: 'Language',
                      icon: Icons.language_outlined,
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
                      onTap: () {
                        // TODO: Navigate to language settings
                      },
                    ),
                    ProfileMenuItem(
                      title: 'Notifications',
                      icon: Icons.notifications_outlined,
                      onTap: () {
                        // TODO: Navigate to notification settings
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Legal Section
                ProfileMenuSection(
                  title: 'Legal',
                  items: [
                    ProfileMenuItem(
                      title: 'FAQ',
                      icon: Icons.help_outline,
                      onTap: () {
                        // TODO: Navigate to FAQ
                      },
                    ),
                    ProfileMenuItem(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () {
                        // TODO: Navigate to privacy policy
                      },
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
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

                SizedBox(height: 40.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // TODO: Implement logout logic
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
      },
    );
  }
}

// Compact Profile Header with Everything Inside Curve

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String email;
  final String joinedYear;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.email,
    required this.joinedYear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipPath(
      clipper: SmoothCurveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: isDark ? 0.15 : 1.0),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: 80.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 15.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.5),
                    child: Icon(
                      Icons.person,
                      size: 45.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    // Joined Info
                    Text(
                      'Joined since $joinedYear',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.w),

                // Edit Profile Button
                FilledButton(
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.all(12.w),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.075),
                    shape: CircleBorder(),
                  ),
                  child: Icon(Icons.edit, size: 18.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Smooth Curve Clipper

class SmoothCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 100);

    // Single smooth curve
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 10,
      size.width,
      size.height - 60,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Menu Section with Soft Borders

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
              width: 1,
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
            children: List.generate(
              items.length,
              (index) => Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 60.w,
                      endIndent: 16.w,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Menu Item

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
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
