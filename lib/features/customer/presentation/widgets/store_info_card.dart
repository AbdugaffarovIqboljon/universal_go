import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';

class FloatingStoreInfoCard extends StatelessWidget {
  final StoreModel store;
  final Position? userPosition;
  final VoidCallback onClose;
  final VoidCallback onViewStore;

  const FloatingStoreInfoCard({
    required this.store,
    this.userPosition,
    required this.onClose,
    required this.onViewStore,
    super.key,
  });

  String _calculateDistance() {
    if (userPosition == null) return '';

    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      store.latitude,
      store.longitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();

    return Positioned(
      top: 80.h + MediaQuery.of(context).padding.top,
      left: 16.w,
      right: 16.w,
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, name, and close button
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.storefront,
                      color: Theme.of(context).primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14.sp,
                              color: Colors.amber[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${store.rating}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Address and distance
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      store.address,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (distance.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        distance,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 12.h),

              // View Store button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewStore,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'View Store & Products',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}