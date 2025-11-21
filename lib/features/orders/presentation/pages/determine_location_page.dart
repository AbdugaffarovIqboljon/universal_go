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

enum LocationCategory {
  home,
  business,
  landmark,
  street,
  building,
  generic;

  IconData get icon {
    switch (this) {
      case LocationCategory.home:
        return Icons.home;
      case LocationCategory.business:
        return Icons.store;
      case LocationCategory.landmark:
        return Icons.location_city;
      case LocationCategory.street:
        return Icons.route;
      case LocationCategory.building:
        return Icons.apartment;
      case LocationCategory.generic:
        return Icons.place;
    }
  }
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
  final isSearchAvailable = ValueNotifier<bool>(true);
  List<EnhancedSearchResult> searchResults = [];
  Timer? searchDebounce;

  SearchSession? _activeSearchSession;
  SearchSession? _activeBusinessSearchSession;

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
    isSearchAvailable.dispose();
    _activeSearchSession?.close();
    _activeBusinessSearchSession?.close();
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
        debugPrint('⚠️ No valid address found, using placeholder');
        foundAddress = 'Selected location on map';
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
        debugPrint('⚠️ Search API not available - using fallback');
        isSearchAvailable.value = false;
      }

      if (mounted) {
        setState(() {
          selectedAddress = 'Selected location on map';
          addressDetails = 'Use the search bar to find your address';
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
      _performEnhancedSearch(query);
    });
  }

  Future<void> _performEnhancedSearch(String query) async {
    if (query.trim().isEmpty || !mounted) return;

    debugPrint('🔎 Enhanced search for: $query');
    isSearching.value = true;

    try {
      await _activeSearchSession?.close();
      await _activeBusinessSearchSession?.close();

      final searchCenter = selectedPoint ?? storeLocation;

      // Run both GEO and BIZ searches in parallel
      final geoFuture = _searchGeo(query, searchCenter);
      final bizFuture = _searchBusiness(query, searchCenter);

      final results = await Future.wait([geoFuture, bizFuture]);
      final geoResults = results[0];
      final bizResults = results[1];

      // Merge and process results
      final allResults = <EnhancedSearchResult>[...geoResults, ...bizResults];

      // Remove duplicates based on proximity (within 50m)
      final uniqueResults = _deduplicateResults(allResults);

      // Sort by relevance: exact matches first, then by distance
      uniqueResults.sort((a, b) {
        final aExact = a.title.toLowerCase().contains(query.toLowerCase());
        final bExact = b.title.toLowerCase().contains(query.toLowerCase());

        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;

        return a.distance.compareTo(b.distance);
      });

      debugPrint('✅ Total unique results: ${uniqueResults.length}');

      if (mounted) {
        setState(() => searchResults = uniqueResults);
      }

      isSearching.value = false;
    } catch (e) {
      debugPrint('❌ Enhanced search error: $e');

      if (e.toString().contains('MissingPluginException')) {
        isSearchAvailable.value = false;
      }

      if (mounted) {
        setState(() => searchResults = []);
      }
      isSearching.value = false;
    }
  }

  Future<List<EnhancedSearchResult>> _searchGeo(
    String query,
    Point center,
  ) async {
    try {
      final resultWithSession = YandexSearch.searchByText(
        searchText: query,
        geometry: Geometry.fromPoint(center),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          resultPageSize: 30,
          geometry: true,
        ),
      );

      final sessionAndFuture = await resultWithSession;
      final session = sessionAndFuture.$1;
      final resultFuture = sessionAndFuture.$2;

      _activeSearchSession = session;
      final result = await resultFuture;

      debugPrint('📍 GEO results: ${result.items?.length ?? 0}');

      final items = result.items != null
          ? _processSearchResults(result.items!, center)
          : <EnhancedSearchResult>[];

      await session.close();
      _activeSearchSession = null;

      return items;
    } catch (e) {
      debugPrint('❌ GEO search error: $e');
      return [];
    }
  }

  Future<List<EnhancedSearchResult>> _searchBusiness(
    String query,
    Point center,
  ) async {
    try {
      final resultWithSession = YandexSearch.searchByText(
        searchText: query,
        geometry: Geometry.fromPoint(center),
        searchOptions: const SearchOptions(
          searchType: SearchType.biz,
          resultPageSize: 30,
          geometry: true,
        ),
      );

      final sessionAndFuture = await resultWithSession;
      final session = sessionAndFuture.$1;
      final resultFuture = sessionAndFuture.$2;

      _activeBusinessSearchSession = session;
      final result = await resultFuture;

      debugPrint('🏪 BIZ results: ${result.items?.length ?? 0}');

      final items = result.items != null
          ? _processSearchResults(result.items!, center)
          : <EnhancedSearchResult>[];

      await session.close();
      _activeBusinessSearchSession = null;

      return items;
    } catch (e) {
      debugPrint('❌ BIZ search error: $e');
      return [];
    }
  }

  List<EnhancedSearchResult> _processSearchResults(
    List items,
    Point center,
  ) {
    final results = <EnhancedSearchResult>[];

    for (final item in items) {
      Point? point;

      if (item.geometry.isNotEmpty) {
        final geometry = item.geometry.first;
        if (geometry.point != null) {
          point = geometry.point!;
        } else if (geometry.boundingBox != null) {
          final box = geometry.boundingBox!;
          point = Point(
            latitude: (box.northEast.latitude + box.southWest.latitude) / 2,
            longitude: (box.northEast.longitude + box.southWest.longitude) / 2,
          );
        }
      }

      if (point == null) continue;

      final title = item.name;
      if (title.isEmpty || _isCoordinateString(title)) continue;

      final distance = _calculateDistanceInMeters(point, center);
      final category = _detectCategory(title);

      results.add(EnhancedSearchResult(
        title: title,
        distance: distance,
        point: point,
        category: category,
      ));
    }

    return results;
  }

  List<EnhancedSearchResult> _deduplicateResults(
    List<EnhancedSearchResult> results,
  ) {
    final unique = <EnhancedSearchResult>[];

    for (final result in results) {
      final isDuplicate = unique.any((existing) {
        final distance = Geolocator.distanceBetween(
          existing.point.latitude,
          existing.point.longitude,
          result.point.latitude,
          result.point.longitude,
        );
        return distance < 50; // Within 50 meters
      });

      if (!isDuplicate) {
        unique.add(result);
      }
    }

    return unique;
  }

  LocationCategory _detectCategory(String title) {
    final lowerTitle = title.toLowerCase();

    // Home-related keywords
    if (lowerTitle.contains('home') ||
        lowerTitle.contains('house') ||
        lowerTitle.contains('apartment') ||
        lowerTitle.contains('residence')) {
      return LocationCategory.home;
    }

    // Business-related keywords
    if (lowerTitle.contains('store') ||
        lowerTitle.contains('shop') ||
        lowerTitle.contains('restaurant') ||
        lowerTitle.contains('cafe') ||
        lowerTitle.contains('market') ||
        lowerTitle.contains('mall') ||
        lowerTitle.contains('butchery') ||
        lowerTitle.contains('bakery')) {
      return LocationCategory.business;
    }

    // Landmark-related keywords
    if (lowerTitle.contains('park') ||
        lowerTitle.contains('square') ||
        lowerTitle.contains('monument') ||
        lowerTitle.contains('stadium') ||
        lowerTitle.contains('theater')) {
      return LocationCategory.landmark;
    }

    // Building-related keywords
    if (lowerTitle.contains('building') ||
        lowerTitle.contains('tower') ||
        lowerTitle.contains('complex')) {
      return LocationCategory.building;
    }

    // Street-related keywords
    if (lowerTitle.contains('street') ||
        lowerTitle.contains('avenue') ||
        lowerTitle.contains('road') ||
        lowerTitle.contains('boulevard')) {
      return LocationCategory.street;
    }

    return LocationCategory.generic;
  }

  double _calculateDistanceInMeters(Point point, Point center) {
    return Geolocator.distanceBetween(
      center.latitude,
      center.longitude,
      point.latitude,
      point.longitude,
    );
  }

  Future<void> _selectSearchResult(EnhancedSearchResult item) async {
    searchController.clear();
    searchFocusNode.unfocus();

    if (!mounted) return;

    final distanceText = item.distance < 1000
        ? '${item.distance.toStringAsFixed(0)}m away'
        : '${(item.distance / 1000).toStringAsFixed(1)}km away';

    setState(() {
      searchResults = [];
      selectedPoint = item.point;
      selectedAddress = item.title;
      addressDetails = distanceText;
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

    if (selectedAddress.isEmpty ||
        selectedAddress == 'Selected location on map') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please use search to specify your address'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
                  EnhancedSearchResultsList(
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

class EnhancedSearchResult {
  final String title;
  final double distance;
  final Point point;
  final LocationCategory category;

  const EnhancedSearchResult({
    required this.title,
    required this.distance,
    required this.point,
    required this.category,
  });

  String get distanceText {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    }
    return '${(distance / 1000).toStringAsFixed(1)}km away';
  }
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
          hintText: 'Search address, building, store...',
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

class EnhancedSearchResultsList extends StatelessWidget {
  final List<EnhancedSearchResult> results;
  final ValueChanged<EnhancedSearchResult> onSelect;

  const EnhancedSearchResultsList({
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
          return EnhancedSearchResultTile(
            result: result,
            onTap: () => onSelect(result),
          );
        },
      ),
    );
  }
}

class EnhancedSearchResultTile extends StatelessWidget {
  final EnhancedSearchResult result;
  final VoidCallback onTap;

  const EnhancedSearchResultTile({
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
          result.category.icon,
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
        result.distanceText,
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
