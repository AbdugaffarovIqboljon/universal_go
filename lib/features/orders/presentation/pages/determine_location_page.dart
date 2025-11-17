// lib/features/location/customer_current_location_determiner.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/shared/widgets/current_location_fab.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';
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

  YandexMapController? mapController;
  Point? selectedPoint;
  String selectedAddress = '';
  String addressDetails = '';

  final isLoadingAddress = ValueNotifier<bool>(false);
  final isLoadingCurrentLocation = ValueNotifier<bool>(false);
  final isSearching = ValueNotifier<bool>(false);

  List<SearchResultItem> searchResults = [];
  Timer? searchDebounce;

  SearchSession? _activeSearchSession;

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
    searchDebounce?.cancel();
    pulseController.dispose();
    isLoadingAddress.dispose();
    isLoadingCurrentLocation.dispose();
    isSearching.dispose();
    _activeSearchSession?.close();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _getCurrentLocation() async {
    isLoadingCurrentLocation.value = true;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint(
        '📍 Current Position: ${position.latitude}, ${position.longitude}',
      );

      final point = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _selectLocation(point);

      if (mounted && mapController != null) {
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
      isLoadingCurrentLocation.value = false;
    }
  }

  Future<void> _selectLocation(Point point) async {
    if (!mounted) return;

    setState(() => selectedPoint = point);
    isLoadingAddress.value = true;

    debugPrint('🔍 Reverse geocoding: ${point.latitude}, ${point.longitude}');

    try {
      // Close previous session if exists
      await _activeSearchSession?.close();

      final resultWithSession = YandexSearch.searchByPoint(
        point: point,
        zoom: 17,
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
          resultPageSize: 10,
        ),
      );

      // Await to get the tuple
      final sessionAndFuture = await resultWithSession;
      final session = sessionAndFuture.$1;
      final resultFuture = sessionAndFuture.$2;

      _activeSearchSession = session;

      final result = await resultFuture;

      debugPrint('📦 Reverse geocode results: ${result.items?.length ?? 0}');

      String foundAddress = '';
      String foundDetails = '';

      if (result.items != null && result.items!.isNotEmpty) {
        for (final item in result.items!) {
          final address = item.name;

          if (address.isNotEmpty && !_isCoordinateString(address)) {
            foundAddress = address;
            foundDetails = 'Selected location';
            debugPrint('✅ Found address: $foundAddress');
            break;
          }
        }
      }

      if (foundAddress.isEmpty) {
        debugPrint('⚠️ No valid address found, using coordinates');
        foundAddress =
            '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        foundDetails = 'Tap search to find nearby addresses';
      }

      if (mounted) {
        setState(() {
          selectedAddress = foundAddress;
          addressDetails = foundDetails;
        });
      }

      isLoadingAddress.value = false;
      await session.close();
      _activeSearchSession = null;
    } catch (e) {
      debugPrint('❌ Reverse geocoding error: $e');

      if (e.toString().contains('MissingPluginException')) {
        debugPrint(
            '⚠️ Search API not available. Make sure you\'re using the FULL variant of yandex_mapkit');
      }

      if (mounted) {
        setState(() {
          selectedAddress =
              '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
          addressDetails = 'Search not available';
        });
      }
      isLoadingAddress.value = false;
    }
  }

  bool _isCoordinateString(String text) {
    final coordPattern = RegExp(r'^-?\d+\.?\d*,?\s*-?\d+\.?\d*$');
    return coordPattern.hasMatch(text);
  }

  void _onSearchChanged(String query) {
    searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() => searchResults = []);
      isSearching.value = false;
      return;
    }

    isSearching.value = true;

    searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty || !mounted) return;

    debugPrint('🔎 Searching for: $query');

    try {
      // Close previous session if exists
      await _activeSearchSession?.close();

      final searchCenter = selectedPoint ?? storeLocation;

      final resultWithSession = YandexSearch.searchByText(
        searchText: query,
        geometry: Geometry.fromPoint(searchCenter),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          resultPageSize: 20,
          geometry: true,
        ),
      );

      // Await to get the tuple
      final sessionAndFuture = await resultWithSession;
      final session = sessionAndFuture.$1;
      final resultFuture = sessionAndFuture.$2;

      _activeSearchSession = session;

      final result = await resultFuture;

      debugPrint('📋 Search results: ${result.items?.length ?? 0}');

      if (result.items != null && mounted) {
        final items = <SearchResultItem>[];

        for (final item in result.items!) {
          Point? point;

          if (item.geometry.isNotEmpty) {
            final geometry = item.geometry.first;
            if (geometry.point != null) {
              point = geometry.point!;
            } else if (geometry.boundingBox != null) {
              final box = geometry.boundingBox!;
              point = Point(
                latitude: (box.northEast.latitude + box.southWest.latitude) / 2,
                longitude:
                    (box.northEast.longitude + box.southWest.longitude) / 2,
              );
            }
          }

          if (point == null) continue;

          final title = item.name;
          if (title.isEmpty || _isCoordinateString(title)) continue;

          final distance = _calculateDistance(point);
          final distanceText = distance < 1
              ? '${(distance * 1000).toStringAsFixed(0)}m away'
              : '${distance.toStringAsFixed(1)}km away';

          items.add(SearchResultItem(
            title: title,
            subtitle: distanceText,
            point: point,
          ));
        }

        if (mounted) {
          setState(() => searchResults = items);
        }
      } else if (mounted) {
        setState(() => searchResults = []);
      }

      isSearching.value = false;
      await session.close();
      _activeSearchSession = null;
    } catch (e, stackTrace) {
      debugPrint('❌ Search error: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (e.toString().contains('MissingPluginException') && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Search requires the full version of Yandex MapKit'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        setState(() => searchResults = []);
      }
      isSearching.value = false;
    }
  }

  Future<void> _selectSearchResult(SearchResultItem item) async {
    searchController.clear();
    searchFocusNode.unfocus();

    if (!mounted) return;

    setState(() {
      searchResults = [];
      selectedPoint = item.point;
      selectedAddress = item.title;
      addressDetails = item.subtitle;
    });
    isSearching.value = false;

    debugPrint('📍 Selected: ${item.title}');

    if (mapController != null && mounted) {
      mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: item.point, zoom: 17),
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

    if (selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait while we determine the address'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_isCoordinateString(selectedAddress)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Could not determine address. Please search for a nearby location'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final location = SelectedLocation(
      latitude: selectedPoint!.latitude,
      longitude: selectedPoint!.longitude,
      address: selectedAddress,
      distance: _calculateDistance(selectedPoint!),
    );

    debugPrint('✅ Confirmed location: $selectedAddress');
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: const GradientAppBar(
          title: "Select Location",
          showBackButton: true,
          subtitle: "select your delivery address",
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
          MapCenterCrosshair(
            animation: pulseAnimation,
            isVisible: selectedPoint == null,
          ),
          SafeArea(
            child: Column(
              children: [
                LocationSearchBar(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: _onSearchChanged,
                  isSearchingNotifier: isSearching,
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
                details: addressDetails,
                isLoadingNotifier: isLoadingAddress,
                onConfirm: _confirmLocation,
              ),
            ),
        ],
      ),
      floatingActionButton: CurrentLocationFab(
        isLoadingNotifier: isLoadingCurrentLocation,
        onPressed: _getCurrentLocation,
      ),
    );
  }
}

class SearchResultItem {
  final String title;
  final String subtitle;
  final Point point;

  const SearchResultItem({
    required this.title,
    required this.subtitle,
    required this.point,
  });
}

class MapCenterCrosshair extends StatelessWidget {
  final Animation<double> animation;
  final bool isVisible;

  const MapCenterCrosshair({
    super.key,
    required this.animation,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: isVisible ? 0.6 : 0.0,
              child: Transform.scale(
                scale: animation.value,
                child: child,
              ),
            );
          },
          child: Container(
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
  final ValueNotifier<bool> isSearchingNotifier;

  const LocationSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isSearchingNotifier,
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
          hintText: 'Search city, street, building...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20.sp,
          ),
          suffixIcon: ValueListenableBuilder<bool>(
            valueListenable: isSearchingNotifier,
            builder: (context, isSearching, child) {
              if (isSearching) {
                return Padding(
                  padding: EdgeInsets.all(12.w),
                  child: SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }

              if (controller.text.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
          return SearchResultTile(
            result: result,
            onTap: () => onSelect(result),
          );
        },
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final SearchResultItem result;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.15),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }
}

class SelectedLocationCard extends StatelessWidget {
  final String address;
  final String details;
  final ValueNotifier<bool> isLoadingNotifier;
  final VoidCallback onConfirm;

  const SelectedLocationCard({
    super.key,
    required this.address,
    required this.details,
    required this.isLoadingNotifier,
    required this.onConfirm,
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
          ValueListenableBuilder<bool>(
            valueListenable: isLoadingNotifier,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return SizedBox(
                  height: 60.h,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Determining address...',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.isNotEmpty ? address : 'Select a location',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (details.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            details,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoadingNotifier,
              builder: (context, isLoading, child) {
                return ElevatedButton(
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
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
