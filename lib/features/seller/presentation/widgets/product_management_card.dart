import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';

class ProductManagementCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductManagementCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // Product Image
                  ProductImage(product: product, isDark: isDark),
                  SizedBox(width: 16.w),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B85F5),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        StockBadge(product: product),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Action Buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularActionButton(
                        icon: Icons.edit_outlined,
                        onPressed: onEdit,
                        backgroundColor: const Color(0xFFA8D5FF),
                      ),
                      SizedBox(height: 8.h),
                      CircularActionButton(
                        icon: Icons.delete_outline,
                        onPressed: onDelete,
                        backgroundColor: const Color(0xFFFFD9E8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  final ProductModel product;
  final bool isDark;

  const ProductImage({
    super.key,
    required this.product,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.network(
          product.image ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.image_outlined,
            size: 36.sp,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  final ProductModel product;

  const StockBadge({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;
    final stockText = inStock
        ? 'Stock:  ${product.stockQuantity ?? 0}  units'
        : 'Out of Stock';

    return Text(
      stockText,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 34.w,
          height: 34.h,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18.sp,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
