import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';
import 'package:universal_go/features/cart/presentation/widgets/quantity_selector.dart';

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  String _formatPrice(double price) {
    final formatter = price.toStringAsFixed(0);
    return formatter.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        child: Icon(
          CupertinoIcons.delete_solid,
          color: Colors.white,
          size: 18.sp,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Remove Item',
              style: theme.textTheme.titleLarge,
            ),
            content: Text(
              'Are you sure you want to remove this item from your cart?',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Remove',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onRemove();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 80.w,
                height: 80.h,
                color: isDark
                    ? theme.colorScheme.surface.withValues(alpha: 0.5)
                    : const Color(0xFFF5F5F7),
                child: CachedNetworkImage(
                  imageUrl: product.image ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported,
                    size: 45.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatPrice(product.price)} UZS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryColor,
                        ),
                      ),
                      QuantitySelector(
                        quantity: item.quantity,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
