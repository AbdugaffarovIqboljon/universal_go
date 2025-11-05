import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/seller/data/models/order_model.dart';

class OrderListItem extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final Function(OrderStatus) onStatusChange;
  final bool isDark;

  const OrderListItem({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusChange,
    required this.isDark,
  });

  Color _getStatusBackgroundColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return const Color(0xFFFEF3C7);
      case OrderStatus.accepted:
        return const Color(0xFFDBEAFE);
      case OrderStatus.inDelivery:
        return const Color(0xFFEDE9FE);
      case OrderStatus.completed:
        return const Color(0xFFD1FAE5);
      case OrderStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.inDelivery:
        return 'In Delivery';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  List<OrderStatus> _getAvailableStatuses() {
    switch (order.status) {
      case OrderStatus.newOrder:
        return [OrderStatus.accepted];
      case OrderStatus.accepted:
        return [OrderStatus.inDelivery];
      case OrderStatus.inDelivery:
        return [OrderStatus.completed];
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBgColor = _getStatusBackgroundColor(order.status);
    final statusText = _getStatusText(order.status);
    final availableStatuses = _getAvailableStatuses();

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #  ${order.id}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  // Customer Info
                  OrderInfoRow(
                    icon: Icons.person_outline,
                    text: order.customerName,
                    isDark: isDark,
                  ),
                  SizedBox(height: 10.h),
                  // Product Info
                  OrderInfoRow(
                    icon: Icons.inventory_2_outlined,
                    text: order.productName,
                    isDark: isDark,
                  ),
                  SizedBox(height: 10.h),
                  // Distance Info
                  OrderInfoRow(
                    icon: Icons.location_on_outlined,
                    text: '${order.distance} km  away',
                    isDark: isDark,
                  ),
                  SizedBox(height: 14.h),
                  Divider(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE5E7EB),
                    height: 1,
                  ),
                  SizedBox(height: 14.h),
                  // Bottom Row with Price and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B85F5),
                        ),
                      ),
                      if (availableStatuses.isNotEmpty)
                        PopupMenuButton<OrderStatus>(
                          onSelected: onStatusChange,
                          offset: Offset(0, 40.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          child: Row(
                            children: [
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF374151),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ],
                          ),
                          itemBuilder: (context) {
                            return availableStatuses.map((status) {
                              return PopupMenuItem<OrderStatus>(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8.w,
                                      height: 8.h,
                                      decoration: BoxDecoration(
                                        color:
                                            _getStatusBackgroundColor(status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      _getStatusText(status),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                        )
                      else
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const OrderInfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: const Color(0xFF6B7280),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}
