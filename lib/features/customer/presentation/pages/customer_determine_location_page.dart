import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';

class SelectedLocation {
  final double latitude;
  final double longitude;
  final String address;
  final double distance;

  const SelectedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.distance,
  });
}

class CustomerCurrentLocationDeterminer extends StatefulWidget {
  const CustomerCurrentLocationDeterminer({super.key});

  @override
  State<CustomerCurrentLocationDeterminer> createState() =>
      _CustomerCurrentLocationDeterminerState();
}

class _CustomerCurrentLocationDeterminerState
    extends State<CustomerCurrentLocationDeterminer>
    with SingleTickerProviderStateMixin {
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  final addressController = TextEditingController();

  YandexMapController? mapController;
  Point? selectedPoint;
  String selectedAddress = '';
  bool isLoadingAddress = false;
  bool isLoadingCurrentLocation = false;
  bool isSearching = false;
  List<SearchResultItem> searchResults = [];
  Timer? searchDebounce;

  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  static const storeLocation = Point(latitude: 41.2995, longitude: 69.2401);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _initPulseAnimation();
  }

  void _initPulseAnimation() {
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    addressController.dispose();
    searchDebounce?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingCurrentLocation = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint('📍 Current Position: ${position.latitude}, ${position.longitude}');

      final point = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _selectLocation(point);

      if (mapController != null) {
        await mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: point, zoom: 17),
          ),
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 0.5,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Location Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingCurrentLocation = false);
      }
    }
  }

  Future<void> _selectLocation(Point point) async {
    setState(() {
      selectedPoint = point;
      isLoadingAddress = true;
    });

    debugPrint('🔍 Reverse geocoding: ${point.latitude}, ${point.longitude}');

    try {
      final resultWithSession = YandexSearch.searchByPoint(
        point: point,
        zoom: 17,
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
        ),
      );

      final (session, resultFuture) = await resultWithSession;
      final result = await resultFuture;

      debugPrint('📦 Search result items: ${result.items?.length ?? 0}');

      if (result.items != null && result.items!.isNotEmpty) {
        final firstItem = result.items!.first;
        String address = '';

        if (firstItem.toponymMetadata?.address.formattedAddress != null) {
          address = firstItem.toponymMetadata!.address.formattedAddress;
          debugPrint('✅ Found address: $address');
        } else if (firstItem.name.isNotEmpty) {
          address = firstItem.name;
          debugPrint('✅ Found name: $address');
        }

        if (address.isNotEmpty) {
          if (mounted) {
            setState(() {
              selectedAddress = address;
              addressController.text = address;
              isLoadingAddress = false;
            });
          }
          await session.close();
          return;
        }
      }

      debugPrint('⚠️ No address found, showing manual input');

      if (mounted) {
        setState(() {
          selectedAddress = '';
          addressController.text = '';
          isLoadingAddress = false;
        });
      }

      await session.close();
    } catch (e) {
      debugPrint('❌ Reverse geocoding error: $e');
      if (mounted) {
        setState(() {
          selectedAddress = '';
          addressController.text = '';
          isLoadingAddress = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    debugPrint('🔎 Searching for: $query');

    try {
      final searchCenter = selectedPoint ?? storeLocation;

      // Use YandexSearch.searchByText instead of YandexSuggest
      final resultWithSession = YandexSearch.searchByText(
        searchText: query,
        geometry: Geometry.fromPoint(searchCenter),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          resultPageSize: 10,
          geometry: false,
        ),
      );

      final (session, resultFuture) = await resultWithSession;
      final result = await resultFuture;

      debugPrint('📋 Search results: ${result.items?.length ?? 0}');

      if (result.items != null && mounted) {
        final items = result.items!.map((item) {
          // Extract point from geometry
          Point? point;
          if (item.geometry.isNotEmpty && item.geometry.first.point != null) {
            point = item.geometry.first.point!;
          }

          // Get address details
          String title = item.name;
          String subtitle = '';

          if (item.toponymMetadata != null) {
            final address = item.toponymMetadata!.address;
            if (address.formattedAddress.isNotEmpty) {
              title = address.formattedAddress;
            }
            
            // Build subtitle from address components
            final components = <String>[];
            if (address.addressComponents.isNotEmpty) {
              for (final component in address.addressComponents.entries) {
                components.add(component.value);
                components.add(component.key.name);
              }
            }
            subtitle = components.join(' • ');
          }

          return SearchResultItem(
            title: title,
            subtitle: subtitle.isNotEmpty ? subtitle : 'Location',
            point: point,
          );
        }).where((item) => item.point != null).toList();

        setState(() {
          searchResults = items;
          isSearching = false;
        });
      } else if (mounted) {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }

      await session.close();
    } catch (e, stackTrace) {
      debugPrint('❌ Search error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
    }
  }

  Future<void> _selectSearchResult(SearchResultItem item) async {
    searchController.clear();
    searchFocusNode.unfocus();
    setState(() {
      searchResults = [];
      isSearching = false;
    });

    debugPrint('📍 Selected: ${item.title}');

    if (item.point != null) {
      setState(() {
        selectedPoint = item.point!;
        selectedAddress = item.title;
        addressController.text = item.title;
      });

      mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: item.point!, zoom: 17),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.5,
        ),
      );
    }
  }

  double _calculateDistance(Point point) {
    return Geolocator.distanceBetween(
          storeLocation.latitude,
          storeLocation.longitude,
          point.latitude,
          point.longitude,
        ) /
        1000;
  }

  void _confirmLocation() {
    if (selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a location on the map'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final finalAddress = addressController.text.trim();

    if (finalAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your delivery address'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final coordPattern = RegExp(r'^-?\d+\.?\d*,?\s*-?\d+\.?\d*$');
    if (coordPattern.hasMatch(finalAddress)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a proper street address'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final location = SelectedLocation(
      latitude: selectedPoint!.latitude,
      longitude: selectedPoint!.longitude,
      address: finalAddress,
      distance: _calculateDistance(selectedPoint!),
    );

    debugPrint('✅ Confirmed location: $finalAddress');
    Navigator.pop(context, location);
  }

  List<CircleMapObject> _buildCircleMapObjects() {
    if (selectedPoint == null) return [];

    final colorScheme = Theme.of(context).colorScheme;

    return [
      CircleMapObject(
        mapId: const MapObjectId('outer_circle'),
        circle: Circle(center: selectedPoint!, radius: 50),
        strokeColor: colorScheme.primary.withValues(alpha: 0.4),
        strokeWidth: 2,
        fillColor: colorScheme.primary.withValues(alpha: 0.15),
      ),
      CircleMapObject(
        mapId: const MapObjectId('inner_circle'),
        circle: Circle(center: selectedPoint!, radius: 20),
        strokeColor: colorScheme.primary,
        strokeWidth: 3,
        fillColor: colorScheme.primary.withValues(alpha: 0.3),
      ),
      CircleMapObject(
        mapId: const MapObjectId('center_dot'),
        circle: Circle(center: selectedPoint!, radius: 6),
        strokeColor: Colors.white,
        strokeWidth: 2,
        fillColor: colorScheme.primary,
      ),
    ];
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
          'Select Location',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) {
              mapController = controller;
              controller.moveCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    target: Point(latitude: 41.2995, longitude: 69.2401),
                    zoom: 12,
                  ),
                ),
              );
            },
            onMapTap: (point) {
              searchFocusNode.unfocus();
              _selectLocation(point);
            },
            mapObjects: _buildCircleMapObjects(),
          ),
          Center(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: selectedPoint == null ? 0.6 : 0.0,
                    child: Transform.scale(
                      scale: pulseAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: const MapCenterCrosshair(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                LocationSearchBar(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: _onSearchChanged,
                  isSearching: isSearching,
                ),
                if (searchResults.isNotEmpty)
                  SearchResultsList(
                    results: searchResults,
                    onSelect: _selectSearchResult,
                  ),
              ],
            ),
          ),
          if (selectedPoint != null)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: SelectedLocationCard(
                address: selectedAddress,
                isLoading: isLoadingAddress,
                onConfirm: _confirmLocation,
                addressController: addressController,
                onAddressChanged: (value) {
                  setState(() => selectedAddress = value);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: CurrentLocationFab(
        isLoading: isLoadingCurrentLocation,
        onPressed: _getCurrentLocation,
      ),
    );
  }
}

class SearchResultItem {
  final String title;
  final String subtitle;
  final Point? point;

  const SearchResultItem({
    required this.title,
    required this.subtitle,
    this.point,
  });
}

class MapCenterCrosshair extends StatelessWidget {
  const MapCenterCrosshair({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary.withValues(alpha: 0.2),
        border: Border.all(color: colorScheme.primary, width: 2.5),
      ),
      child: Center(
        child: Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}

class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isSearching;

  const LocationSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Street, neighborhood, building...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20.sp,
          ),
          suffixIcon: isSearching
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                )
              : controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 18.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }
}

class SearchResultsList extends StatelessWidget {
  final List<SearchResultItem> results;
  final ValueChanged<SearchResultItem> onSelect;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(maxHeight: 300.h),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        itemCount: results.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 56.w,
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final result = results[index];
          return ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.location_on,
                color: colorScheme.primary,
                size: 18.sp,
              ),
            ),
            title: Text(
              result.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            onTap: () => onSelect(result),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          );
        },
      ),
    );
  }
}

class SelectedLocationCard extends StatelessWidget {
  final String address;
  final bool isLoading;
  final VoidCallback onConfirm;
  final TextEditingController addressController;
  final ValueChanged<String> onAddressChanged;

  const SelectedLocationCard({
    super.key,
    required this.address,
    required this.isLoading,
    required this.onConfirm,
    required this.addressController,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: colorScheme.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (isLoading)
            SizedBox(
              height: 50.h,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
            )
          else
            TextField(
              controller: addressController,
              onChanged: onAddressChanged,
              style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter your delivery address...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
            ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirm Location',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentLocationFab extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const CurrentLocationFab({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.primary,
      elevation: 4,
      child: isLoading
          ? SizedBox(
              width: 24.sp,
              height: 24.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            )
          : Icon(Icons.my_location, size: 24.sp),
    );
  }
}