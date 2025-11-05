import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        spacing: 8.w,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDecrement,
              borderRadius: BorderRadius.circular(20.r),
              child: Icon(
                CupertinoIcons.minus,
                size: 18.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            quantity > 99 ? '99+' : quantity.toString(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.primaryColor,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onIncrement,
              borderRadius: BorderRadius.circular(20.r),
              child: Icon(
                CupertinoIcons.plus,
                size: 18.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
