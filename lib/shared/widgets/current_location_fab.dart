import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrentLocationFab extends StatelessWidget {
  final ValueNotifier<bool> isLoadingNotifier;
  final VoidCallback onPressed;

  const CurrentLocationFab({
    super.key,
    required this.isLoadingNotifier,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, child) {
        return FloatingActionButton(
          heroTag: null,
          key: const Key('current_location_fab'),
          onPressed: isLoading ? null : onPressed,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          focusNode: FocusNode(),
          mouseCursor: SystemMouseCursors.click,
          elevation: 4,
          child: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              : Image(
                  image: const AssetImage("assets/icons/ic_navigate.png"),
                  width: 28.w,
                  height: 28.h,
                ),
        );
      },
    );
  }
}
