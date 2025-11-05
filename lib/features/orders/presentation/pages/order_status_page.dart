import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';

class CustomerOrderStatusPage extends StatefulWidget {
  const CustomerOrderStatusPage({super.key});

  @override
  State<CustomerOrderStatusPage> createState() =>
      _CustomerOrderStatusPageState();
}

class _CustomerOrderStatusPageState extends State<CustomerOrderStatusPage> {
  Timer? _pulseTimer;
  bool _showBadge = true;

  @override
  void initState() {
    super.initState();
    _startPulseAnimation();
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _startPulseAnimation() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _showBadge = !_showBadge;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderCard(
                        colorScheme: colorScheme,
                        showBadge: _showBadge,
                      ),
                      SizedBox(height: 18.h),
                      DeliveryTimeCard(colorScheme: colorScheme),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.customerMain,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                  child: Text(
                    'Back to Stores',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== ORDER CARD ==========
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.colorScheme,
    required this.showBadge,
  });

  final ColorScheme colorScheme;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Order #o69z',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Thank you for your order!\nWe will notify you when your order is ready',
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 22.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimelineColumn(colorScheme: colorScheme),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusItem(
                      title: 'Order Accepted',
                      description: 'Your order has been accepted by the store',
                      isCompleted: true,
                      color: const Color(0xFF10B981),
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 40.h),
                    StatusItem(
                      title: 'In Delivery',
                      description: 'Your order is on its way',
                      isCompleted: true,
                      color: colorScheme.primary,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 7.h),
                    CurrentStatusBadge(
                      colorScheme: colorScheme,
                      showBadge: showBadge,
                    ),
                    SizedBox(height: 40.h),
                    StatusItem(
                      title: 'Completed',
                      description: 'Your order has been delivered',
                      isCompleted: false,
                      color: colorScheme.onSurface.withOpacity(0.3),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========== TIMELINE COLUMN ==========
class TimelineColumn extends StatelessWidget {
  const TimelineColumn({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimelineCircle(
          icon: Icons.receipt_long_rounded,
          backgroundColor: const Color(0xFF10B981),
          iconColor: Colors.white,
        ),
        TimelineLine(color: colorScheme.onSurface.withOpacity(0.12)),
        TimelineCircle(
          icon: Icons.local_shipping_outlined,
          backgroundColor: colorScheme.primary,
          iconColor: Colors.white,
        ),
        TimelineLine(color: colorScheme.onSurface.withOpacity(0.12)),
        TimelineCircle(
          icon: Icons.task_alt_rounded,
          backgroundColor: colorScheme.onSurface.withOpacity(0.08),
          iconColor: colorScheme.onSurface.withOpacity(0.35),
        ),
      ],
    );
  }
}

// ========== TIMELINE CIRCLE ==========
class TimelineCircle extends StatelessWidget {
  const TimelineCircle({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22.sp),
    );
  }
}

// ========== TIMELINE LINE ==========
class TimelineLine extends StatelessWidget {
  const TimelineLine({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.w,
      height: 58.h,
      color: color,
    );
  }
}

// ========== STATUS ITEM ==========
class StatusItem extends StatelessWidget {
  const StatusItem({
    super.key,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.color,
    required this.colorScheme,
  });

  final String title;
  final String description;
  final bool isCompleted;
  final Color color;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isCompleted ? color : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// ========== CURRENT STATUS BADGE (WITH PULSE) ==========
class CurrentStatusBadge extends StatelessWidget {
  const CurrentStatusBadge({
    super.key,
    required this.colorScheme,
    required this.showBadge,
  });

  final ColorScheme colorScheme;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showBadge ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          'Current Status',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ========== DELIVERY TIME CARD ==========
class DeliveryTimeCard extends StatelessWidget {
  const DeliveryTimeCard({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Delivery Time',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 13.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 13.w),
              Text(
                '10-15 minutes',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

