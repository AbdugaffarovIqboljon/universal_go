import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_event.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_state.dart';
import 'package:universal_go/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:universal_go/features/cart/presentation/widgets/cart_bottom_bar.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';

class CustomerCartPage extends StatefulWidget {
  const CustomerCartPage({super.key});

  @override
  State<CustomerCartPage> createState() => _CustomerCartPageState();
}

class _CustomerCartPageState extends State<CustomerCartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCart());
  }

  void _handleClearCart() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Clear Cart',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartBloc>().add(ClearCart());
            },
            child: Text(
              'Clear',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            );
          }

          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(LoadCart());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CartLoaded) {
            if (state.cart.isEmpty) {
              return const EmptyCartView();
            }

            return Column(
              children: [
                GradientAppBar(
                  title: "Cart",
                  subtitle: "${state.cart.items.length} items",
                  actions: [
                    ClearCartActionButton(
                      onPressed: _handleClearCart,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: state.cart.items.length,
                    itemBuilder: (context, index) {
                      final item = state.cart.items[index];
                      return CartItemTile(
                        key: ValueKey(item.product.id),
                        item: item,
                        onRemove: () {
                          context.read<CartBloc>().add(
                                RemoveFromCart(productId: item.product.id),
                              );
                        },
                        onIncrement: () {
                          context.read<CartBloc>().add(
                                UpdateCartQuantity(
                                  productId: item.product.id,
                                  quantity: item.quantity + 1,
                                ),
                              );
                        },
                        onDecrement: () {
                          if (item.quantity > 1) {
                            context.read<CartBloc>().add(
                                  UpdateCartQuantity(
                                    productId: item.product.id,
                                    quantity: item.quantity - 1,
                                  ),
                                );
                          }
                        },
                      );
                    },
                  ),
                ),
                CartBottomBar(
                  cart: state.cart,
                  onCheckout: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.customerCheckout,
                      arguments: state.cart,
                    );
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ClearCartActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearCartActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IconButton(
      icon: Icon(
        CupertinoIcons.delete,
        color: theme.colorScheme.surface,
        size: 21.sp,
      ),
      onPressed: onPressed,
      tooltip: 'Clear cart',
    );
  }
}

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 100.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            ),
            SizedBox(height: 24.h),
            Text(
              'Your cart is empty',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add some products to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.customerMain,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Shopping',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}