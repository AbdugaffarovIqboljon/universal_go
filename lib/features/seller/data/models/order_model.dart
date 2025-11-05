enum OrderStatus {
  newOrder,
  accepted,
  inDelivery,
  completed,
  cancelled,
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String storeId;
  final DateTime orderDate;
  final double totalAmount;
  OrderStatus status;
  final double? distance;
  final String productName;
  final int itemCount;
  final String? deliveryAddress;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.storeId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    this.distance,
    required this.productName,
    required this.itemCount,
    this.deliveryAddress,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.newOrder:
        return 'New Order';
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

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? storeId,
    DateTime? orderDate,
    double? totalAmount,
    OrderStatus? status,
    double? distance,
    int? itemCount,
    String? deliveryAddress,
    String? productName,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      storeId: storeId ?? this.storeId,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      itemCount: itemCount ?? this.itemCount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      productName: productName ?? this.productName,
    );
  }
}
