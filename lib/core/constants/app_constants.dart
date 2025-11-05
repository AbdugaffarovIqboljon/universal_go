class AppConstants {
  // App Info
  static const String appName = 'Universal Go';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String shopsCollection = 'shops';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String notificationsCollection = 'notifications';
  
  // User Roles
  static const String customerRole = 'customer';
  static const String sellerRole = 'seller';
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderAccepted = 'accepted';
  static const String orderInDelivery = 'in_delivery';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';
  
  // Delivery Cost (UZS per km)
  static const double deliveryCostPerKm = 1000.0;
  
  // Commission (1.5%)
  static const double commissionRate = 0.015;
  
  // Price Markup (7.5% increase when adding to cart)
  static const double priceMarkupRate = 0.075;
  
  // Map
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 5.0;
}
