import 'package:flutter/material.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/auth/presentation/pages/splash_page.dart';
import 'package:universal_go/features/auth/presentation/pages/login_page.dart';
import 'package:universal_go/features/auth/presentation/pages/register_page.dart';

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
      case AppRoutes.customerHome:
        // TODO: Implement CustomerHomePage
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Customer Home - Coming Soon')),
          ),
          settings: settings,
        );
      case AppRoutes.sellerDashboard:
        // TODO: Implement SellerDashboardPage
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
