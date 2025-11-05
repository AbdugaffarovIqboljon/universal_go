import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:universal_go/features/auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;


  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    // Logo slide up animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));


    // Start animations
    _logoController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _initializeApp() async {
    // Show splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      context.read<AuthBloc>().add(AuthStarted());
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate based on user role
            if (state.user.role == 'customer') {
              Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
            } else if (state.user.role == 'seller') {
              Navigator.pushReplacementNamed(
                  context, AppRoutes.sellerHome);
            }
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        },
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50.h * (1 - _logoAnimation.value)),
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Theme.of(context).colorScheme.surface,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 5.r,
                                    offset: Offset(0, 10.h),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.asset(
                                  'assets/images/img_universal_go_logo.png',
                                  width: 120.w,
                                  height: 120.h,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      
                SizedBox(height: 40.h),
      
                // Animated App Name
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'Universal Go',
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  offset: Offset(0, 2.h),
                                  blurRadius: 4.r,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Your Local Marketplace',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}