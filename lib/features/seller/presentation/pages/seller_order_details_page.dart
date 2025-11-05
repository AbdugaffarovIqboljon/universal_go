import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/seller/data/models/order_model.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';

class OrderItem {
  final ProductModel product;
  final int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;
}

class SellerOrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const SellerOrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  State<SellerOrderDetailsPage> createState() => _SellerOrderDetailsPageState();
}

class _SellerOrderDetailsPageState extends State<SellerOrderDetailsPage> {
  late OrderStatus _currentStatus;
  late List<OrderItem> _orderItems;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    _loadOrderItems();
  }

  void _loadOrderItems() {
    final products = [
      ProductModel(
        id: 'prod-1',
        storeId: widget.order.storeId,
        name: 'Green Tea',
        price: 15000.0,
        inStock: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 'prod-2',
        storeId: widget.order.storeId,
        name: 'Black Tea',
        price: 12000.0,
        inStock: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _orderItems = [
      OrderItem(product: products[0], quantity: 2),
      OrderItem(product: products[1], quantity: 1),
    ];
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

  String _getNextActionText(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'Accept Order';
      case OrderStatus.accepted:
        return 'Mark as In Delivery';
      case OrderStatus.inDelivery:
        return 'Complete Order';
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return '';
    }
  }

  OrderStatus? _getNextStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return OrderStatus.accepted;
      case OrderStatus.accepted:
        return OrderStatus.inDelivery;
      case OrderStatus.inDelivery:
        return OrderStatus.completed;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return null;
    }
  }

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)} UZS';
  }

  bool _canUpdateStatus() {
    return _currentStatus != OrderStatus.completed &&
        _currentStatus != OrderStatus.cancelled;
  }

  void _updateStatus(OrderStatus newStatus) {
    setState(() {
      _currentStatus = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to ${_getStatusText(newStatus)}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtotal =
        _orderItems.fold<double>(0, (sum, item) => sum + item.subtotal);
    final deliveryFee = widget.order.distance! * 5000;
    final commission = subtotal * 0.05;
    final total = subtotal + deliveryFee + commission;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
      body: Column(
        children: [
          GradientAppBar(
            title: 'Order Details',
            subtitle: 'Order #${widget.order.id}',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Display Only
                  StatusActionCard(
                    status: _currentStatus,
                    onAction: _canUpdateStatus()
                        ? () {
                            final nextStatus = _getNextStatus(_currentStatus);
                            if (nextStatus != null) {
                              _updateStatus(nextStatus);
                            }
                          }
                        : null,
                    actionText: _getNextActionText(_currentStatus),
                    isDark: isDark,
                  ),
                  SizedBox(height: 16.h),

                  // Customer Information
                  SectionCard(
                    title: 'Customer Information',
                    isDark: isDark,
                    child: Column(
                      children: [
                        InfoRow(
                          label: 'Name',
                          value: widget.order.customerName,
                          isDark: isDark,
                        ),
                        SizedBox(height: 16.h),
                        InfoRow(
                          label: 'Location',
                          value: widget.order.deliveryAddress ?? 'Not provided',
                          icon: Icons.location_on_outlined,
                          iconColor: const Color(0xFF8B85F5),
                          isDark: isDark,
                        ),
                        SizedBox(height: 16.h),
                        InfoRow(
                          label: 'Distance',
                          value: '${widget.order.distance} km',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Order Items
                  SectionCard(
                    title: 'Order Items (${_orderItems.length})',
                    isDark: isDark,
                    child: Column(
                      children: _orderItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            if (index > 0) SizedBox(height: 12.h),
                            OrderItemCard(
                              item: item,
                              isDark: isDark,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Order Summary
                  SectionCard(
                    title: 'Order Summary',
                    isDark: isDark,
                    child: Column(
                      children: [
                        SummaryRow(
                          label: 'Subtotal',
                          value: _formatAmount(subtotal),
                          isDark: isDark,
                        ),
                        SizedBox(height: 12.h),
                        SummaryRow(
                          label: 'Delivery Fee',
                          value: _formatAmount(deliveryFee),
                          isDark: isDark,
                        ),
                        SizedBox(height: 12.h),
                        SummaryRow(
                          label: 'Commission (5%)',
                          value: _formatAmount(commission),
                          isDark: isDark,
                        ),
                        SizedBox(height: 16.h),
                        Divider(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE5E7EB),
                          height: 1,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              _formatAmount(total),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8B85F5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusActionCard extends StatelessWidget {
  final OrderStatus status;
  final VoidCallback? onAction;
  final String actionText;
  final bool isDark;

  const StatusActionCard({
    super.key,
    required this.status,
    this.onAction,
    required this.actionText,
    required this.isDark,
  });

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return const Color(0xFFF59E0B);
      case OrderStatus.accepted:
        return const Color(0xFF3B82F6);
      case OrderStatus.inDelivery:
        return const Color(0xFFF59E0B);
      case OrderStatus.completed:
        return const Color(0xFF10B981);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  Color _getStatusBgColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return const Color(0xFFFEF3C7);
      case OrderStatus.accepted:
        return const Color(0xFFDBEAFE);
      case OrderStatus.inDelivery:
        return const Color(0xFFFEF3C7);
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              _getStatusText(status),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),

          // Action Button
          if (onAction != null)
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B85F5),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                actionText,
                style: TextStyle(
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

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final bool isDark;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18.sp,
                color: iconColor ?? const Color(0xFF6B7280),
              ),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final bool isDark;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.isDark,
  });

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)} UZS';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Qty: ${item.quantity} × ${_formatAmount(item.product.price)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            _formatAmount(item.subtotal),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
