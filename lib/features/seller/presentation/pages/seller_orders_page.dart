import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/seller/data/mock_seller_data.dart';
import 'package:universal_go/features/seller/data/models/order_model.dart';
import 'package:universal_go/features/seller/presentation/widgets/empty_orders_state.dart';
import 'package:universal_go/features/seller/presentation/widgets/order_list_item.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';

enum OrderFilter { all, pending, active, completed }

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<OrderFilter> _selectedFilter = ValueNotifier(OrderFilter.all);
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final List<OrderModel> _allOrders = MockSellerData.orders;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _selectedFilter.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  List<OrderModel> _getFilteredOrders() {
    List<OrderModel> filtered;
    
    switch (_selectedFilter.value) {
      case OrderFilter.pending:
        filtered = _allOrders.where((o) => o.status == OrderStatus.newOrder).toList();
        break;
      case OrderFilter.active:
        filtered = _allOrders.where((o) => 
          o.status == OrderStatus.accepted || o.status == OrderStatus.inDelivery
        ).toList();
        break;
      case OrderFilter.completed:
        filtered = _allOrders.where((o) => o.status == OrderStatus.completed).toList();
        break;
      case OrderFilter.all:
      filtered = _allOrders;
    }

    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.id.toLowerCase().contains(_searchQuery.value) ||
               order.customerName.toLowerCase().contains(_searchQuery.value) ||
               order.productName.toLowerCase().contains(_searchQuery.value);
      }).toList();
    }

    return filtered;
  }

  int _getCountForFilter(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.all:
        return _allOrders.length;
      case OrderFilter.pending:
        return _allOrders.where((o) => o.status == OrderStatus.newOrder).length;
      case OrderFilter.active:
        return _allOrders.where((o) => 
          o.status == OrderStatus.accepted || o.status == OrderStatus.inDelivery
        ).length;
      case OrderFilter.completed:
        return _allOrders.where((o) => o.status == OrderStatus.completed).length;
    }
  }

  void _handleStatusChange(OrderModel order, OrderStatus newStatus) {
    setState(() {
      order.status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
      body: Column(
        children: [
          GradientAppBar(
            title: 'Orders',
            subtitle: '${_allOrders.length} orders found',
            showBackButton: true,
          ),
          SizedBox(height: 16.h),
          // Search Bar
          SearchBar(
            controller: _searchController,
            isDark: isDark,
          ),
          SizedBox(height: 16.h),
          // Filter Chips
          SizedBox(
            height: 44.h,
            child: ValueListenableBuilder<OrderFilter>(
              valueListenable: _selectedFilter,
              builder: (context, selectedFilter, _) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    OrderFilterChip(
                      label: 'All',
                      count: _getCountForFilter(OrderFilter.all),
                      isSelected: selectedFilter == OrderFilter.all,
                      onTap: () => _selectedFilter.value = OrderFilter.all,
                    ),
                    SizedBox(width: 8.w),
                    OrderFilterChip(
                      label: 'Pending',
                      count: _getCountForFilter(OrderFilter.pending),
                      isSelected: selectedFilter == OrderFilter.pending,
                      onTap: () => _selectedFilter.value = OrderFilter.pending,
                    ),
                    SizedBox(width: 8.w),
                    OrderFilterChip(
                      label: 'Active',
                      count: _getCountForFilter(OrderFilter.active),
                      isSelected: selectedFilter == OrderFilter.active,
                      onTap: () => _selectedFilter.value = OrderFilter.active,
                    ),
                    SizedBox(width: 8.w),
                    OrderFilterChip(
                      label: 'Completed',
                      count: _getCountForFilter(OrderFilter.completed),
                      isSelected: selectedFilter == OrderFilter.completed,
                      onTap: () => _selectedFilter.value = OrderFilter.completed,
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          // Orders List
          Expanded(
            child: ValueListenableBuilder<OrderFilter>(
              valueListenable: _selectedFilter,
              builder: (context, _, __) {
                return ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (context, __, ___) {
                    final orders = _getFilteredOrders();
                    
                    if (orders.isEmpty) {
                      return const EmptyOrdersState();
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: orders.length,
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
                          onStatusChange: (newStatus) {
                            _handleStatusChange(orders[index], newStatus);
                          },
                          isDark: isDark,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const SearchBar({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 15.sp,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'Search orders or customers...',
          hintStyle: TextStyle(
            fontSize: 15.sp,
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF9CA3AF),
            size: 22.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}

class OrderFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const OrderFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B85F5) : Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B85F5) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          '$label  ($count)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}