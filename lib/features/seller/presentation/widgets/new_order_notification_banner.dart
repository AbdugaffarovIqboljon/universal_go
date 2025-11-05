import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewOrderNotificationBanner extends StatelessWidget {
  final String customerName;
  final double amount;
  final VoidCallback onTap;

  const NewOrderNotificationBanner({
    super.key,
    required this.customerName,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCE7F3),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Image.asset(
                "assets/icons/ic_notification.png",
                width: 20.w,
                height: 20.h,
                color: Color(0xFFFF8FB8),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Order Received!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$customerName placed an order for \$${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF9CA3AF),
                size: 21.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
