import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/seller/data/models/seller_store_model.dart';

class StoreInfoCard extends StatelessWidget {
  final SellerStoreModel store;
  final VoidCallback onTap;

  const StoreInfoCard({
    super.key,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Color(0xFFF8FAFC),
            border: Border.all(
              color: const Color(0xFFF3F4F6),
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Container(
                width: 65.w,
                height: 65.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: store.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(store.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: const Color(0xFF7C6FFA),
                ),
                child: store.avatarUrl == null
                    ? Center(
                        child: Text(
                          store.avatarLetter,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            store.address,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}