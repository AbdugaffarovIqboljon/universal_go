import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientAppBar extends StatelessWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.notificationCount,
    this.onNotificationTap,
    this.gradientColors,
    this.actions,
    this.showBackButton = false,
  });

  final String title;
  final String? subtitle;
  final ValueNotifier<int>? notificationCount;
  final VoidCallback? onNotificationTap;
  final List<Color>? gradientColors;
  final List<Widget>? actions;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      const Color(0xFF8B85F5),
      const Color(0xFF4E47DD),
    ];
    final colors = gradientColors ?? defaultColors;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showBackButton == true) ...[
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    splashColor: Colors.white.withValues(alpha: 0.02),
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            if (notificationCount != null) ...[
              ValueListenableBuilder<int>(
                valueListenable: notificationCount!,
                builder: (context, count, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: IconButton(
                          onPressed: onNotificationTap,
                          icon: Icon(
                            Icons.notifications_outlined,
                            size: 24.sp,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          right: -6.w,
                          top: -4.h,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDA4AF),
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20.w,
                              minHeight: 20.h,
                            ),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (actions != null) SizedBox(width: 8.w),
            ],
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
