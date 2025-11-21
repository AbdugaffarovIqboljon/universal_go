import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_event.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_state.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';
import 'package:universal_go/features/shops/presentation/widgets/product_card.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';

class StoreDetailsPage extends StatefulWidget {
  final StoreModel store;

  const StoreDetailsPage({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final List<ProductModel> _products = [];
  final List<ProductModel> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
    // Load cart to get initial count
    context.read<CartBloc>().add(LoadCart());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    if (widget.store.products != null && widget.store.products!.isNotEmpty) {
      setState(() {
        _products.clear();
        _products.addAll(
          widget.store.products!.cast<ProductModel>(),
        );
        _filterProducts();
        _isLoading = false;
      });
      return;
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _products.clear();
        _products.addAll([
          ProductModel(
            id: '1',
            storeId: widget.store.id,
            name: 'Wireless Headphones',
            price: 99.99,
            image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&q=80',
            description: 'High-quality wireless headphones with noise cancellation',
            inStock: true,
            stockQuantity: 15,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ProductModel(
            id: '2',
            storeId: widget.store.id,
            name: 'Smart Watch',
            price: 199.99,
            image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&q=80',
            description: 'Advanced smartwatch with fitness tracking',
            inStock: true,
            stockQuantity: 8,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 25)),
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          ProductModel(
            id: '3',
            storeId: widget.store.id,
            name: 'Coffee Maker',
            price: 79.99,
            image: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400&q=80',
            description: 'Automatic coffee maker with timer',
            inStock: false,
            stockQuantity: 0,
            category: 'Appliances',
            createdAt: DateTime.now().subtract(const Duration(days: 20)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ProductModel(
            id: '4',
            storeId: widget.store.id,
            name: 'Laptop Stand',
            price: 49.99,
            image: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&q=80',
            description: 'Adjustable laptop stand for ergonomic workspace',
            inStock: true,
            stockQuantity: 25,
            category: 'Office',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ProductModel(
            id: '5',
            storeId: widget.store.id,
            name: 'Bluetooth Speaker',
            price: 69.99,
            image: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&q=80',
            description: 'Portable Bluetooth speaker with rich bass',
            inStock: true,
            stockQuantity: 12,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 18)),
            updatedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          ProductModel(
            id: '6',
            storeId: widget.store.id,
            name: 'Wireless Mouse',
            price: 29.99,
            image: 'https://images.unsplash.com/photo-1527814050087-3793815479db?w=400&q=80',
            description: 'Ergonomic wireless mouse with precision tracking',
            inStock: true,
            stockQuantity: 30,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 12)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ProductModel(
            id: '7',
            storeId: widget.store.id,
            name: 'Mechanical Keyboard',
            price: 89.99,
            image: 'https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=400&q=80',
            description: 'RGB mechanical keyboard with blue switches',
            inStock: true,
            stockQuantity: 10,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 22)),
            updatedAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
          ProductModel(
            id: '8',
            storeId: widget.store.id,
            name: 'USB-C Hub',
            price: 39.99,
            image: 'https://images.unsplash.com/photo-1625842268584-8f6716232a18?w=400&q=80',
            description: 'Multi-port USB-C hub with HDMI and SD card reader',
            inStock: true,
            stockQuantity: 20,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 14)),
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          ProductModel(
            id: '9',
            storeId: widget.store.id,
            name: 'Desk Lamp',
            price: 34.99,
            image: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&q=80',
            description: 'LED desk lamp with adjustable brightness',
            inStock: true,
            stockQuantity: 18,
            category: 'Office',
            createdAt: DateTime.now().subtract(const Duration(days: 16)),
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ProductModel(
            id: '10',
            storeId: widget.store.id,
            name: 'Phone Stand',
            price: 19.99,
            image: 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400&q=80',
            description: 'Adjustable phone stand for desk or table',
            inStock: true,
            stockQuantity: 35,
            category: 'Accessories',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ProductModel(
            id: '11',
            storeId: widget.store.id,
            name: 'Webcam HD',
            price: 59.99,
            image: 'https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=400&q=80',
            description: '1080p HD webcam with built-in microphone',
            inStock: true,
            stockQuantity: 14,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 21)),
            updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ProductModel(
            id: '12',
            storeId: widget.store.id,
            name: 'Cable Organizer',
            price: 14.99,
            image: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400&q=80',
            description: 'Cable management system for desk organization',
            inStock: true,
            stockQuantity: 40,
            category: 'Accessories',
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ProductModel(
            id: '13',
            storeId: widget.store.id,
            name: 'Monitor Stand',
            price: 44.99,
            image: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&q=80',
            description: 'Ergonomic monitor stand with storage space',
            inStock: true,
            stockQuantity: 16,
            category: 'Office',
            createdAt: DateTime.now().subtract(const Duration(days: 19)),
            updatedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          ProductModel(
            id: '14',
            storeId: widget.store.id,
            name: 'Wireless Charger',
            price: 24.99,
            image: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400&q=80',
            description: 'Fast wireless charging pad for smartphones',
            inStock: true,
            stockQuantity: 22,
            category: 'Accessories',
            createdAt: DateTime.now().subtract(const Duration(days: 13)),
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ProductModel(
            id: '15',
            storeId: widget.store.id,
            name: 'Tablet Stand',
            price: 27.99,
            image: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&q=80',
            description: 'Adjustable tablet stand with multiple viewing angles',
            inStock: true,
            stockQuantity: 19,
            category: 'Accessories',
            createdAt: DateTime.now().subtract(const Duration(days: 11)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ProductModel(
            id: '16',
            storeId: widget.store.id,
            name: 'External Hard Drive',
            price: 79.99,
            image: 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=400&q=80',
            description: '1TB portable external hard drive',
            inStock: true,
            stockQuantity: 9,
            category: 'Electronics',
            createdAt: DateTime.now().subtract(const Duration(days: 17)),
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ]);
        _filterProducts();
        _isLoading = false;
      });
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts.clear();
      final searchQuery = _searchController.text.toLowerCase();

      for (final product in _products) {
        final matchesSearch = searchQuery.isEmpty ||
            product.name.toLowerCase().contains(searchQuery) ||
            (product.description?.toLowerCase().contains(searchQuery) ?? false);

        if (matchesSearch) {
          _filteredProducts.add(product);
        }
      }
    });
  }

  void _addToCart(ProductModel product) {
    final cartItem = CartItemEntity(
      product: product,
      quantity: 1,
    );

    context.read<CartBloc>().add(AddToCart(item: cartItem));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to your cart'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.only(
          bottom: 20.h,
          left: 16.w,
          right: 16.w,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientAppBar(
            title: widget.store.name,
            subtitle: widget.store.address,
            showBackButton: true,
            actions: [
              const CartIconButton(),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Store Info Card - with rating and product count
                  StoreInfoCard(store: widget.store),
                  SizedBox(height: 16.h),

                  // Products Header
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Search Bar
                  CustomSearchBar(controller: _searchController),

                  SizedBox(height: 20.h),
                  // Products Grid or Loading/Empty State
                  if (_isLoading)
                    SizedBox(
                      height: 300.h,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else if (_filteredProducts.isEmpty)
                    EmptyProductsView(
                      hasSearchQuery: _searchController.text.isNotEmpty,
                    )
                  else
                    ProductsGrid(
                      products: _filteredProducts,
                      onAddToCart: _addToCart,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Products Grid
class ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onAddToCart;

  const ProductsGrid({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2 / 3,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onAddToCart: () => onAddToCart(products[index]),
        );
      },
    );
  }
}

// Cart button with badge
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  int _getTotalCartQuantity(CartState state) {
    if (state is CartLoaded) {
      return state.cart.items.fold(
        0,
        (sum, item) => sum + item.quantity,
      );
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final totalQuantity = _getTotalCartQuantity(state);
        final cartItemCount =
            totalQuantity > 99 ? '99+' : totalQuantity.toString();

        return InkWell(
          onTap: () {
            // Navigate to CustomerMainPage with cart tab selected. This preserves the bottom navigation bar as it's part of CustomerMainPage
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.customerMain,
              (route) => false,
              arguments: 1, // Cart tab index
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: Theme.of(context).colorScheme.surface,
                size: 24.sp,
              ),
              if (totalQuantity > 0)
                Positioned(
                  right: -6.w,
                  top: -10.h,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14.w,
                      minHeight: 14.h,
                    ),
                    child: Center(
                      child: Text(
                        cartItemCount,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Store info card
class StoreInfoCard extends StatelessWidget {
  final StoreModel store;

  const StoreInfoCard({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store Icon
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.storefront_rounded,
                size: 40.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          SizedBox(width: 14.w),

          // Store Info - NO NAME, just location, rating, product count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '0.5 km away',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Address
                Text(
                  store.address,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                // Rating and Product Count
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 18.sp,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${store.rating}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 18.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${store.productCount} products',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom search bar
class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const CustomSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.search_outlined,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          size: 20.sp,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
      ),
      style: TextStyle(
        fontSize: 14.sp,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// Empty state
class EmptyProductsView extends StatelessWidget {
  final bool hasSearchQuery;

  const EmptyProductsView({
    super.key,
    required this.hasSearchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearchQuery
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 80.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 20.h),
            Text(
              hasSearchQuery ? 'No products found' : 'No products available',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              hasSearchQuery
                  ? 'Try adjusting your search terms'
                  : 'This store hasn\'t added any products yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
