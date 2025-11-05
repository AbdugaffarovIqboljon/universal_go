class RevenueData {
  final double totalRevenue;
  final String period;
  final int growthPercentage;
  final int totalOrders;
  final double averageOrder;
  final List<DailySales> dailySales;
  final List<RevenueBreakdownItem> breakdown;

  const RevenueData({
    required this.totalRevenue,
    required this.period,
    required this.growthPercentage,
    required this.totalOrders,
    required this.averageOrder,
    required this.dailySales,
    required this.breakdown,
  });
}

class DailySales {
  final String day;
  final double amount;

  const DailySales({
    required this.day,
    required this.amount,
  });
}

class RevenueBreakdownItem {
  final String label;
  final double amount;
  final int colorValue;

  const RevenueBreakdownItem({
    required this.label,
    required this.amount,
    required this.colorValue,
  });
}