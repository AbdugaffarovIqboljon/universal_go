class OrderStatsModel {
  final int newOrders;
  final int inDelivery;
  final int completed;

  OrderStatsModel({
    required this.newOrders,
    required this.inDelivery,
    required this.completed,
  });

  int get totalActive => newOrders + inDelivery;

  OrderStatsModel copyWith({
    int? newOrders,
    int? inDelivery,
    int? completed,
  }) {
    return OrderStatsModel(
      newOrders: newOrders ?? this.newOrders,
      inDelivery: inDelivery ?? this.inDelivery,
      completed: completed ?? this.completed,
    );
  }
}

