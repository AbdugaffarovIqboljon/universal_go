import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/seller/data/models/seller_revenue_model.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';

class SellerRevenuePage extends StatefulWidget {
  const SellerRevenuePage({super.key});

  @override
  State<SellerRevenuePage> createState() => _SellerRevenuePageState();
}

class _SellerRevenuePageState extends State<SellerRevenuePage> {
  final ValueNotifier<String> selectedPeriod = ValueNotifier('Week');

  RevenueData revenueData = const RevenueData(
    totalRevenue: 5240,
    period: 'Week',
    growthPercentage: 12,
    totalOrders: 42,
    averageOrder: 124.76,
    dailySales: [
      DailySales(day: 'Mon', amount: 720),
      DailySales(day: 'Tue', amount: 1170),
      DailySales(day: 'Wed', amount: 900),
      DailySales(day: 'Thu', amount: 1440),
      DailySales(day: 'Fri', amount: 1260),
      DailySales(day: 'Sat', amount: 1620),
      DailySales(day: 'Sun', amount: 1080),
    ],
    breakdown: [
      RevenueBreakdownItem(
          label: 'Product Sales', amount: 4454, colorValue: 0xFF8B85F5),
      RevenueBreakdownItem(
          label: 'Shipping Fees', amount: 524, colorValue: 0xFF6AB6F6),
      RevenueBreakdownItem(label: 'Other', amount: 262, colorValue: 0xFFFF9AC3),
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // TODO: Replace with actual API call
  }

  @override
  void dispose() {
    selectedPeriod.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Column(
        children: [
          const GradientAppBar(
            title: 'Sales Overview',
            subtitle: 'Track your revenue performance',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PeriodSelector(selectedPeriod: selectedPeriod),
                  SizedBox(height: 24.h),
                  RevenueCard(
                    amount: revenueData.totalRevenue,
                    period: revenueData.period,
                    growthPercentage: revenueData.growthPercentage,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Orders',
                          value: revenueData.totalOrders.toString(),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: StatCard(
                          label: 'Average Order',
                          value:
                              '\$${revenueData.averageOrder.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SalesBarChart(
                    dailySales: revenueData.dailySales,
                    growthPercentage: revenueData.growthPercentage,
                  ),
                  SizedBox(height: 16.h),
                  RevenueBreakdown(items: revenueData.breakdown),
                  SizedBox(height: 20.h),
                  const ExportButton(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.selectedPeriod});

  final ValueNotifier<String> selectedPeriod;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<String>(
      valueListenable: selectedPeriod,
      builder: (context, selected, _) {
        return Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PeriodButton(
                label: 'Week',
                isSelected: selected == 'Week',
                onTap: () => selectedPeriod.value = 'Week',
              ),
              SizedBox(width: 16.w),
              PeriodButton(
                label: 'Month',
                isSelected: selected == 'Month',
                onTap: () => selectedPeriod.value = 'Month',
              ),
              SizedBox(width: 16.w),
              PeriodButton(
                label: 'Year',
                isSelected: selected == 'Year',
                onTap: () => selectedPeriod.value = 'Year',
              ),
            ],
          ),
        );
      },
    );
  }
}

class PeriodButton extends StatelessWidget {
  const PeriodButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B85F5) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class RevenueCard extends StatelessWidget {
  const RevenueCard({
    super.key,
    required this.amount,
    required this.period,
    required this.growthPercentage,
  });

  final double amount;
  final String period;
  final int growthPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(21.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB5B0FF), Color(0xFF8B85F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withAlpha(40),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 36.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withAlpha(40),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '+$growthPercentage%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Total Revenue This $period',
            style: TextStyle(
              color: const Color(0xFFF5F3FF),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF3F4F6),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class SalesBarChart extends StatelessWidget {
  const SalesBarChart({
    super.key,
    required this.dailySales,
    required this.growthPercentage,
  });

  final List<DailySales> dailySales;
  final int growthPercentage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxAmount =
        dailySales.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF3F4F6),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Overview',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: const Color(0xFF7DD3C0),
                    size: 18.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '+$growthPercentage%',
                    style: TextStyle(
                      color: const Color(0xFF7DD3C0),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 165.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dailySales.map((sale) {
                return BarItem(
                  label: sale.day,
                  height: sale.amount / maxAmount,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BarItem extends StatelessWidget {
  const BarItem({
    super.key,
    required this.label,
    required this.height,
  });

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: 120.h * height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B85F5), Color(0xFFB5B0FF)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueBreakdown extends StatelessWidget {
  const RevenueBreakdown({super.key, required this.items});

  final List<RevenueBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF3F4F6),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Breakdown',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: RevenueBreakdownItemWidget(
                color: Color(entry.value.colorValue),
                label: entry.value.label,
                amount: entry.value.amount,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class RevenueBreakdownItemWidget extends StatelessWidget {
  const RevenueBreakdownItemWidget({
    super.key,
    required this.color,
    required this.label,
    required this.amount,
  });

  final Color color;
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Implement export functionality
      },
      icon: Icon(
        Icons.calendar_today_outlined,
        size: 20.sp,
      ),
      label: Text(
        'Export Report',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF8B85F5),
        side: BorderSide(color: const Color(0xFF8B85F5), width: 2.w),
        padding: EdgeInsets.symmetric(vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
