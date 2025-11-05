import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/seller/data/models/seller_store_model.dart';
import 'package:universal_go/features/seller/data/models/order_model.dart';
import 'package:universal_go/features/seller/data/mock_seller_data.dart';
import 'package:universal_go/features/seller/presentation/widgets/store_info_card.dart';
import 'package:universal_go/features/seller/presentation/widgets/metric_card.dart';
import 'package:universal_go/features/seller/presentation/widgets/order_list_item.dart';
import 'package:universal_go/features/seller/presentation/widgets/empty_orders_state.dart';
import 'package:universal_go/features/seller/presentation/widgets/new_order_notification_banner.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  late final ValueNotifier<int> notificationCount;
  late final ValueNotifier<List<OrderModel>> recentOrders;
  late final ValueNotifier<bool> hasNewOrder;
  late final SellerStoreModel store;

  @override
  void initState() {
    super.initState();
    store = MockSellerData.store;
    notificationCount = ValueNotifier<int>(3);
    recentOrders = ValueNotifier<List<OrderModel>>(MockSellerData.orders);
    hasNewOrder = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    notificationCount.dispose();
    recentOrders.dispose();
    hasNewOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
      body: Column(
        children: [
          // App Bar
          GradientAppBar(
            title: 'Seller Dashboard',
            subtitle: 'Manage your business',
            notificationCount: notificationCount,
            onNotificationTap: () {
              // TODO: Navigate to notifications
            },
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // Notification Banner
                  ValueListenableBuilder<bool>(
                    valueListenable: hasNewOrder,
                    builder: (context, hasOrder, _) {
                      if (!hasOrder) return const SizedBox.shrink();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NewOrderNotificationBanner(
                            customerName: 'Sarah Johnson',
                            amount: 89.99,
                            onTap: () {
                              // TODO: Navigate to order details
                            },
                          ),
                          SizedBox(height: 16.h),
                        ],
                      );
                    },
                  ),

                  // Store Info Card
                  StoreInfoCard(
                    store: store,
                    onTap: () {
                      // TODO: Navigator.pushNamed(context, AppRoutes.sellerStoreEdit);
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Metrics Grid
                  GridView.count(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 1.05,
                    children: [
                      MetricCard(
                        icon: Icons.attach_money,
                        value: '\$5,240',
                        label: 'Total Revenue',
                        percentage: '+12%',
                        gradientColors: const [
                          Color(0xFF9C8CFA),
                          Color(0xFF7C6FFA),
                        ],
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.sellerRevenue);
                        },
                      ),
                      MetricCard(
                        icon: Icons.shopping_bag_outlined,
                        value: '142',
                        label: 'Orders',
                        percentage: '+8%',
                        gradientColors: const [
                          Color(0xFFD4E7FE),
                          Color(0xFFBFDBFE),
                        ],
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.sellerOrders);
                        },
                      ),
                      MetricCard(
                        icon: Icons.inventory_2_outlined,
                        value: '48',
                        label: 'Products',
                        gradientColors: const [
                          Color(0xFFFCE7F3),
                          Color(0xFFFBCFE8),
                        ],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.sellerProducts,
                          );
                        },
                      ),
                      MetricCard(
                        icon: Icons.chat_bubble_outline,
                        value: '12',
                        label: 'Chats',
                        gradientColors: const [
                          Color(0xFFD9F4E8),
                          Color(0xFFB5E7D3),
                        ],
                        isComingSoon: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Recent Orders Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.sellerOrders);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 4.h,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8B85F5),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12.sp,
                              color: const Color(0xFF8B85F5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Recent Orders List
                  ValueListenableBuilder<List<OrderModel>>(
                    valueListenable: recentOrders,
                    builder: (context, orders, _) {
                      if (orders.isEmpty) {
                        return const EmptyOrdersState();
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length > 3 ? 3 : orders.length,
                        itemBuilder: (context, index) {
                          return OrderListItem(
                            order: orders[index],
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.sellerOrderDetails,
                                arguments: orders[index],
                              );
                            },
                            isDark: isDark,
                            onStatusChange: (OrderStatus status) {
                              setState(() {
                                orders[index].status = status;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
