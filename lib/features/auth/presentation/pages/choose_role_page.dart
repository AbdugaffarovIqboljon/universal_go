import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),
              // Logo
                  Image.asset(
                    "assets/images/img_universal_go_logo.png",
                    width: 100.w,
                    height: 100.h,
                  ),
              SizedBox(height: 40.h),
              // Heading
              Text(
                'How will you use UniversalGo?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              // Subtitle
              Text(
                'Select your role to continue',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 32.h),
              // Customer Role Card
              RoleCard(
                icon: Icons.shopping_bag_outlined,
                iconColor: Theme.of(context).colorScheme.primary,
                iconBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                title: 'Continue as Customer',
                description: 'Browse products and place orders\nfrom local shops',
              ),
              SizedBox(height: 20.h),
              // Shop Owner Role Card
              RoleCard(
                icon: Icons.store_outlined,
                iconColor: Theme.of(context).colorScheme.secondary,
                iconBackgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                title: 'Continue as Shop Owner',
                description: 'Manage your store, products, and\nreceive orders',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String description;

  const RoleCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20.r),
      elevation: 5,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      child: InkWell(
        onTap: () {
          if (title == 'Continue as Customer') {
            Navigator.pushReplacementNamed(context, AppRoutes.customerMain);
          } else if (title == 'Continue as Shop Owner') {
            Navigator.pushReplacementNamed(context, AppRoutes.sellerDashboard);
          }
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  icon,
                  size: 32.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 16.w),
              // Text content
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
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}