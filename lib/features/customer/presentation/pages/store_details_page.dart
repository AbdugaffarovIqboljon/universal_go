import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';

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
            image: 'assets/images/headphones.jpg',
            description: 'High-quality wireless headphones',
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
            image: 'assets/images/smartwatch.jpg',
            description: 'Advanced smartwatch',
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
            image: 'assets/images/coffee_maker.jpg',
            description: 'Automatic coffee maker',
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
            image: 'assets/images/laptop_stand.jpg',
            description: 'Adjustable laptop stand',
            inStock: true,
            stockQuantity: 25,
            category: 'Office',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
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
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 70.h),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(color: Theme.of(context).colorScheme.onPrimary),
                  Expanded(
                    child: Text(
                      widget.store.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CartIconButton(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Info Card - NO store name, WITH rating and product count
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

// Product Card - FIXED overflow by making taller and smaller fonts
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image - Bigger
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 50.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ),

          // Product Info - Compact
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  Spacer(),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 30.h,
                    child: ElevatedButton(
                      onPressed: product.inStock ? onAddToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            product.inStock ? 'Add to Cart' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// Cart button with badge
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined,
              color: Colors.white, size: 24.sp),
          onPressed: () {},
        ),
        Positioned(
          right: 6.w,
          top: 6.h,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(
              minWidth: 18.w,
              minHeight: 18.h,
            ),
            child: Center(
              child: Text(
                '3',
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '0.5 km away',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${store.productCount} products',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
