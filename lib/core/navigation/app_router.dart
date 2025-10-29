import 'package:flutter/material.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/auth/presentation/pages/choose_role_page.dart';
import 'package:universal_go/features/auth/presentation/pages/splash_page.dart';
import 'package:universal_go/features/auth/presentation/pages/login_page.dart';
import 'package:universal_go/features/auth/presentation/pages/register_page.dart';
import 'package:universal_go/features/customer/data/models/store_model.dart';
import 'package:universal_go/features/customer/presentation/pages/check_out_page.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_cart_page.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_main_page.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_order_status_screen.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_profile_page.dart';
import 'package:universal_go/features/customer/presentation/pages/store_details_page.dart';

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
        return MaterialPageRoute(
          builder: (_) => const CustomerMainPage(),
          settings: settings,
        );
      case AppRoutes.customerCart:
        return MaterialPageRoute(
          builder: (_) => const CustomerCartPage(),
          settings: settings,
        );
      case AppRoutes.customerCheckout:
        return MaterialPageRoute(
          builder: (_) => CustomerCheckoutPage(
            items: settings.arguments as List<CartItem>,
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
      case AppRoutes.sellerDashboard:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Seller Dashboard - Coming Soon')),
          ),
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
