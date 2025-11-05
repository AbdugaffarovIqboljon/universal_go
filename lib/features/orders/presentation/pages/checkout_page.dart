import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_event.dart';
import 'package:universal_go/features/orders/presentation/pages/determine_location_page.dart';

class CustomerCheckoutPage extends StatefulWidget {
  final CartEntity cart;

  const CustomerCheckoutPage({
    super.key,
    required this.cart,
  });

  @override
  State<CustomerCheckoutPage> createState() => _CustomerCheckoutPageState();
}

class _CustomerCheckoutPageState extends State<CustomerCheckoutPage> {
  SelectedLocation? selectedLocation;
  final double distance = 0.8;
  final double deliveryFee = 5000;
  final double commissionRate = 0.015;

  final _promoController = TextEditingController();
  String? appliedPromoCode;
  double promoDiscount = 0;

  double get subtotal => widget.cart.subtotal;
  double get commission => subtotal * commissionRate;
  double get shipping => deliveryFee;
  double get total => subtotal + shipping + commission - promoDiscount;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _navigateToLocationPicker() async {
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerCurrentLocationDeterminer(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLocation = result;
      });
    }
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showMessage('Please enter a promo code', isError: true);
      return;
    }

    // Simulate promo code validation
    setState(() {
      if (code == 'SAVE10') {
        promoDiscount = subtotal * 0.1; // 10% discount
        appliedPromoCode = code;
        _showMessage('Promo code applied! 10% discount');
      } else if (code == 'SAVE5000') {
        promoDiscount = 5000; // Fixed 5000 UZS discount
        appliedPromoCode = code;
        _showMessage('Promo code applied! 5,000 UZS discount');
      } else if (code == 'FREESHIP') {
        promoDiscount = deliveryFee; // Free shipping
        appliedPromoCode = code;
        _showMessage('Promo code applied! Free shipping');
      } else {
        _showMessage('Invalid promo code', isError: true);
      }
    });
  }

  void _removePromoCode() {
    setState(() {
      promoDiscount = 0;
      appliedPromoCode = null;
      _promoController.clear();
    });
    _showMessage('Promo code removed');
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _placeOrder() {
    if (selectedLocation == null) {
      _showMessage('Please select a delivery location', isError: true);
      return;
    }

    // Clear cart after successful order placement
    context.read<CartBloc>().add(ClearCart());

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.customerOrderStatus,
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order placed successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

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
    final itemCount = widget.cart.items.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // Address Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Address',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToLocationPicker,
                        child: Text(
                          'Edit',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  AddressCard(
                    selectedLocation: selectedLocation,
                    onTap: _navigateToLocationPicker,
                  ),

                  SizedBox(height: 24.h),

                  // Products Section
                  Text(
                    'Products ($itemCount)',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Product List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cart.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart.items[index];
                      return CheckoutCartItemTile(
                        item: item,
                        formatPrice: _formatPrice,
                      );
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Promo Code Section
                  PromoCodeInput(
                    controller: _promoController,
                    appliedPromoCode: appliedPromoCode,
                    onApply: _applyPromoCode,
                    onRemove: _removePromoCode,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PriceBreakdown(
        subtotal: subtotal,
        shipping: shipping,
        commission: commission,
        discount: promoDiscount,
        total: total,
        formatPrice: _formatPrice,
        onPressed: _placeOrder,
        isEnabled: selectedLocation != null,
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final SelectedLocation? selectedLocation;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.selectedLocation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasLocation = selectedLocation != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                hasLocation ? Icons.home : Icons.location_on_outlined,
                color: hasLocation
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLocation ? 'Home' : 'Select Address',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (hasLocation) ...[
                    Text(
                      selectedLocation!.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    Text(
                      'Tap to choose delivery address',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 21.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class PromoCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final String? appliedPromoCode;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const PromoCodeInput({
    super.key,
    required this.controller,
    required this.appliedPromoCode,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPromo = appliedPromoCode != null;

    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasPromo ? Icons.check_circle : Icons.discount,
            size: 22.sp,
            color: hasPromo
                ? Colors.green
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: hasPromo
                ? Text(
                    'Promo code "$appliedPromoCode" applied',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  )
                : TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Enter your promo code',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
          ),
          if (hasPromo)
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.all(4.sp),
                child: Icon(
                  Icons.close,
                  size: 20.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(50.w, 30.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Apply',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PriceBreakdown extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double commission;
  final double discount;
  final double total;
  final String Function(double) formatPrice;
  final VoidCallback onPressed;
  final bool isEnabled;

  const PriceBreakdown({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.commission,
    required this.discount,
    required this.total,
    required this.formatPrice,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriceRow(
              label: 'Subtotal',
              value: '${formatPrice(subtotal)} UZS',
            ),
            SizedBox(height: 12.h),
            PriceRow(
              label: 'Shipping',
              value: '${formatPrice(shipping)} UZS',
            ),
            if (commission > 0) ...[
              SizedBox(height: 12.h),
              PriceRow(
                label: 'Service Fee',
                value: '${formatPrice(commission)} UZS',
              ),
            ],
            if (discount > 0) ...[
              SizedBox(height: 12.h),
              PriceRow(
                label: 'Discount',
                value: '- ${formatPrice(discount)} UZS',
                valueColor: Colors.green,
              ),
            ],
            SizedBox(height: 16.h),
            CustomPaint(
              size: Size(double.infinity, 1.h),
              painter: DashedLinePainter(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total amount',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '${formatPrice(total)} UZS',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ConfirmButton(
              onPressed: onPressed,
              isEnabled: isEnabled,
            ),
          ],
        ),
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const ConfirmButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.surface,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Confirm',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.surface,
          ),
        ),
      ),
    );
  }
}

class CheckoutCartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final String Function(double) formatPrice;

  const CheckoutCartItemTile({
    super.key,
    required this.item,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final product = item.product;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 48.w,
              height: 48.h,
              color: isDark
                  ? theme.colorScheme.surface.withValues(alpha: 0.5)
                  : const Color(0xFFF5F5F7),
              child: CachedNetworkImage(
                imageUrl: product.image ?? '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                  Icons.image_not_supported,
                  size: 32.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),
              Text(
                '${formatPrice(product.price)} UZS',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
