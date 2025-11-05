import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/auth/presentation/pages/choose_role_page.dart';
import 'package:universal_go/features/auth/presentation/pages/splash_page.dart';
import 'package:universal_go/features/auth/presentation/pages/login_page.dart';
import 'package:universal_go/features/auth/presentation/pages/register_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_home_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_main_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_products_page.dart';
import 'package:universal_go/features/seller/presentation/pages/add_edit_product_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_orders_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_order_details_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_revenue_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_shop_setup_page.dart';
import 'package:universal_go/features/seller/presentation/pages/seller_settings_page.dart';
import 'package:universal_go/features/seller/data/models/order_model.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';
import 'package:universal_go/features/shops/presentation/pages/store_details_page.dart';
import 'package:universal_go/features/orders/presentation/pages/checkout_page.dart';
import 'package:universal_go/features/orders/presentation/pages/order_status_page.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_main_page.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_profile_page.dart';
import 'package:universal_go/features/cart/presentation/pages/customer_cart_page.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/injection_container.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case AppRoutes.chooseRole:
        return MaterialPageRoute(
          builder: (_) => const ChooseRolePage(),
          settings: settings,
        );
      case AppRoutes.customerMain:
        final initialTab = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => CustomerMainPage(initialTab: initialTab),
          settings: settings,
        );
      case AppRoutes.customerCart:
      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<CartBloc>(),
            child: const CustomerCartPage(),
          ),
          settings: settings,
        );
      case AppRoutes.customerCheckout:
        final cart = settings.arguments;
        if (cart == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Cart is empty')),
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => CustomerCheckoutPage(
            cart: cart as CartEntity,
          ),
          settings: settings,
        );
      case AppRoutes.customerOrderStatus:
        return MaterialPageRoute(
          builder: (_) => const CustomerOrderStatusPage(),
          settings: settings,
        );
      case AppRoutes.customerProfile:
        return MaterialPageRoute(
          builder: (_) => const CustomerProfilePage(),
          settings: settings,
        );
      case AppRoutes.customerHome:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Customer Home - Coming Soon')),
          ),
          settings: settings,
        );
      case AppRoutes.storeDetails:
        final store = settings.arguments as StoreModel?;
        if (store == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Store not found')),
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => StoreDetailsPage(store: store),
          settings: settings,
        );
      case AppRoutes.sellerHome:
        return MaterialPageRoute(
          builder: (_) => const SellerHomePage(),
          settings: settings,
        );
      case AppRoutes.sellerMain:
        final initialTab = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => SellerMainPage(initialTab: initialTab),
          settings: settings,
        );
      case AppRoutes.sellerProducts:
        return MaterialPageRoute(
          builder: (_) => const SellerProductsPage(),
          settings: settings,
        );
      case AppRoutes.addEditProduct:
        final product = settings.arguments as ProductModel?;
        return MaterialPageRoute(
          builder: (_) => AddEditProductPage(product: product),
          settings: settings,
        );
      case AppRoutes.sellerOrders:
        return MaterialPageRoute(
          builder: (_) => const SellerOrdersPage(),
          settings: settings,
        );
      case AppRoutes.sellerOrderDetails:
        final order = settings.arguments as OrderModel?;
        if (order == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Order not found')),
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => SellerOrderDetailsPage(order: order),
          settings: settings,
        );
      case AppRoutes.sellerRevenue:
        return MaterialPageRoute(
          builder: (_) => const SellerRevenuePage(),
          settings: settings,
        );
      case AppRoutes.sellerShopSetup:
        return MaterialPageRoute(
          builder: (_) => const SellerShopSetupPage(),
          settings: settings,
        );
      case AppRoutes.sellerProfile:
        return MaterialPageRoute(
          builder: (_) => const SellerSettingsPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
          settings: settings,
        );
    }
  }
}
