import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_cart_page.dart';

import 'customer_determine_location_page.dart';

class CustomerCheckoutPage extends StatefulWidget {
  final List<CartItem> items;

  const CustomerCheckoutPage({
    super.key,
    required this.items,
  });

  @override
  State<CustomerCheckoutPage> createState() => _CustomerCheckoutPageState();
}

class _CustomerCheckoutPageState extends State<CustomerCheckoutPage> {
   SelectedLocation? selectedLocation;
  final double distance = 0.8;
  final double deliveryFee = 800;
  final double commissionRate = 0.015;

  double get subtotal {
    return widget.items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity.value),
    );
  }

  double get commission => subtotal * commissionRate;
  double get total => subtotal + deliveryFee + commission;

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


  void _placeOrder() {
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
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Confirmation',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: 'Delivery Details'),
                  SizedBox(height: 12.h),
                  DeliveryDetailsCard(
                    selectedLocation: selectedLocation,
                    deliveryFee: deliveryFee,
                    formatPrice: _formatPrice,
                    onTap: _navigateToLocationPicker,
                  ),
                  SizedBox(height: 24.h),
                  SectionTitle(title: 'Order Summary'),
                  SizedBox(height: 12.h),
                  OrderSummarySection(
                    items: widget.items,
                    formatPrice: _formatPrice,
                  ),
                  SizedBox(height: 24.h),
                  SectionTitle(title: 'Payment Details'),
                  SizedBox(height: 12.h),
                  const PaymentMethodCard(),
                  SizedBox(height: 12.h),
                  PriceBreakdown(
                    subtotal: subtotal,
                    deliveryFee: deliveryFee,
                    commission: commission,
                    total: total,
                    formatPrice: _formatPrice,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          PlaceOrderButton(
            onPressed: _placeOrder,
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class DeliveryDetailsCard extends StatelessWidget {
  final SelectedLocation? selectedLocation;
  final double deliveryFee;
  final String Function(double) formatPrice;
  final VoidCallback onTap;

  const DeliveryDetailsCard({
    super.key,
    required this.selectedLocation,
    required this.deliveryFee,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLocation = selectedLocation != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surface.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasLocation
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: hasLocation ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: hasLocation
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    hasLocation ? Icons.location_on : Icons.location_off,
                    color: hasLocation
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation ? 'Delivery Location' : 'Choose Location',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        hasLocation
                            ? selectedLocation!.address
                            : 'Tap to select delivery address',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20.sp,
                ),
              ],
            ),
            if (hasLocation) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${selectedLocation!.distance.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Fee',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${formatPrice(deliveryFee)} UZS',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OrderSummarySection extends StatelessWidget {
  final List<CartItem> items;
  final String Function(double) formatPrice;

  const OrderSummarySection({
    super.key,
    required this.items,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${item.quantity.value}x ${item.name}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                '${formatPrice(item.price * item.quantity.value)} UZS',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method: Cash',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Pay in cash upon delivery',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PriceBreakdown extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double commission;
  final double total;
  final String Function(double) formatPrice;

  const PriceBreakdown({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.commission,
    required this.total,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        PriceRow(
          label: 'Subtotal',
          value: '${formatPrice(subtotal)} UZS',
        ),
        SizedBox(height: 10.h),
        PriceRow(
          label: 'Delivery Fee',
          value: '${formatPrice(deliveryFee)} UZS',
        ),
        SizedBox(height: 10.h),
        PriceRow(
          label: 'Commission (1.5%)',
          value: '${formatPrice(commission)} UZS',
          isCommission: true,
        ),
        SizedBox(height: 12.h),
        Divider(
          thickness: 1.h,
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${formatPrice(total)} UZS',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCommission;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.isCommission = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withValues(
              alpha: isCommission ? 0.6 : 0.7,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class PlaceOrderButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PlaceOrderButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}