import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/seller/data/mock_seller_data.dart';
import 'package:universal_go/features/seller/presentation/widgets/product_management_card.dart';
import 'package:universal_go/features/seller/presentation/widgets/grid_product_card.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';

enum ViewMode { list, grid }

class SellerProductsPage extends StatefulWidget {
  const SellerProductsPage({super.key});

  @override
  State<SellerProductsPage> createState() => _SellerProductsPageState();
}

class _SellerProductsPageState extends State<SellerProductsPage> {
  List<ProductModel> _products = [];
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<ViewMode> _viewMode = ValueNotifier(ViewMode.list);
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewMode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<ProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _products;
    }
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _loadProducts() {
    setState(() {
      _products = MockSellerData.products;
    });
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _products.remove(product);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product "${product.name}" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddEdit([ProductModel? product]) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addEditProduct,
      arguments: product,
    );
    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddEdit,
        label: Text(
          "Add Product",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        icon: Icon(
          Icons.add,
          size: 18.sp,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF8B85F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      body: Column(
        children: [
          GradientAppBar(
            title: 'My Products',
            subtitle: '${_products.length} products in stock',
            showBackButton: true,
          ),
          // Search bar with view toggle
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                          fontSize: 15.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                          size: 22.sp,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () => _searchController.clear(),
                                icon: Icon(
                                  Icons.close,
                                  size: 20.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                ViewToggleButtons(viewMode: _viewMode),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: _products.isEmpty
                ? EmptyProductsView(onAddProduct: () => _navigateToAddEdit())
                : filteredProducts.isEmpty
                    ? EmptySearchView(
                        searchQuery: _searchQuery,
                        onAddProduct: () => _navigateToAddEdit(),
                      )
                    : ValueListenableBuilder<ViewMode>(
                        valueListenable: _viewMode,
                        builder: (context, mode, _) {
                          if (mode == ViewMode.grid) {
                            return GridView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return GridProductCard(
                                  product: product,
                                  onEdit: () => _navigateToAddEdit(product),
                                  onDelete: () => _deleteProduct(product),
                                );
                              },
                            );
                          } else {
                            return ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return ProductManagementCard(
                                  product: product,
                                  onTap: () => _navigateToAddEdit(product),
                                  onEdit: () => _navigateToAddEdit(product),
                                  onDelete: () => _deleteProduct(product),
                                );
                              },
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ViewToggleButtons extends StatelessWidget {
  final ValueNotifier<ViewMode> viewMode;

  const ViewToggleButtons({
    super.key,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<ViewMode>(
      valueListenable: viewMode,
      builder: (context, mode, _) {
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ViewToggleButton(
                icon: Icons.grid_view_rounded,
                isSelected: mode == ViewMode.grid,
                onTap: () => viewMode.value = ViewMode.grid,
              ),
              SizedBox(width: 4.w),
              ViewToggleButton(
                icon: Icons.view_list_rounded,
                isSelected: mode == ViewMode.list,
                onTap: () => viewMode.value = ViewMode.list,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ViewToggleButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 36.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B85F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class EmptyProductsView extends StatelessWidget {
  final VoidCallback onAddProduct;

  const EmptyProductsView({
    super.key,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 80.sp,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        SizedBox(height: 24.h),
        Text(
          'Add your first product',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Start selling by adding products to your store',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class EmptySearchView extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onAddProduct;

  const EmptySearchView({
    super.key,
    required this.searchQuery,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 80.sp,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        SizedBox(height: 24.h),
        Text(
          'No products found',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Try adjusting your search query',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
