import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_go/features/customer/presentation/widgets/store_info_card.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';
import 'package:universal_go/shared/widgets/current_location_fab.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapFullScreenPage extends StatefulWidget {
  final List<StoreModel> stores;
  final Map<String, String> storeDeals;
  final Position? userPosition;
  final Function(StoreModel) onStoreSelected;

  const MapFullScreenPage({
    required this.stores,
    required this.storeDeals,
    this.userPosition,
    required this.onStoreSelected,
    super.key,
  });

  @override
  State<MapFullScreenPage> createState() => _MapFullScreenPageState();
}

class _MapFullScreenPageState extends State<MapFullScreenPage>
    with SingleTickerProviderStateMixin {
  YandexMapController? _mapController;
  bool _isDisposed = false;

  final ValueNotifier<List<PlacemarkMapObject>> _placemarks =
      ValueNotifier<List<PlacemarkMapObject>>([]);
  final ValueNotifier<bool> _isLoadingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<Position?> _userPositionNotifier =
      ValueNotifier<Position?>(null);
  final ValueNotifier<StoreModel?> _selectedStore =
      ValueNotifier<StoreModel?>(null);

  // Search state
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<List<SearchResult>> _searchResults =
      ValueNotifier<List<SearchResult>>([]);
  final ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  PlacemarkMapObject? _searchMarker;

  SearchSession? _activeSearchSession;
  bool _searchAvailable = true;

  // Animation for active marker
  late AnimationController _markerAnimationController;
  late Animation<double> _markerScaleAnimation;

  @override
  void initState() {
    super.initState();
    _userPositionNotifier.value = widget.userPosition;

    // Initialize marker animation - continuous bounce
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _markerScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_markerAnimationController);

    _markerScaleAnimation.addListener(() {
      if (!_isDisposed && _selectedStore.value != null) {
        _addShopMarkers();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userPosition != null) {
        _moveToUserLocation();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _markerAnimationController.dispose();
    _placemarks.dispose();
    _isLoadingLocation.dispose();
    _userPositionNotifier.dispose();
    _selectedStore.dispose();
    _searchQuery.dispose();
    _searchResults.dispose();
    _isSearching.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _activeSearchSession?.close();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(YandexMapController controller) {
    if (_isDisposed) return;
    _mapController = controller;
    _addShopMarkers();
  }

  void _addShopMarkers() {
    if (_isDisposed) return;

    final placemarks = <PlacemarkMapObject>[];

    final userPosition = _userPositionNotifier.value;
    if (userPosition != null) {
      final userPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('user_location'),
        point: Point(
          latitude: userPosition.latitude,
          longitude: userPosition.longitude,
        ),
        opacity: 1.0,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage(
              'assets/icons/ic_user_location.png',
            ),
            scale: 0.3,
            anchor: const Offset(0.5, 0.5),
            rotationType: RotationType.noRotation,
          ),
        ),
      );
      placemarks.add(userPlacemark);
    }

    // Add search marker if exists
    if (_searchMarker != null) {
      placemarks.add(_searchMarker!);
    }

    final selectedStore = _selectedStore.value;

    for (final store in widget.stores) {
      final isSelected = selectedStore?.id == store.id;
      final hasDeal = widget.storeDeals.containsKey(store.id);

      if (isSelected) {
        // Add active marker with animation
        final animationScale = _markerScaleAnimation.value;
        final placemark = PlacemarkMapObject(
          mapId: MapObjectId('store_active_${store.id}'),
          point: Point(latitude: store.latitude, longitude: store.longitude),
          opacity: 1.0,
          consumeTapEvents: true,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                'assets/icons/ic_active_marker.png',
              ),
              scale: 0.45 * animationScale,
              anchor: const Offset(0.5, 1.0),
              rotationType: RotationType.noRotation,
            ),
          ),
          onTap: (PlacemarkMapObject self, Point point) {
            _onMarkerTap(store);
          },
        );
        placemarks.add(placemark);
      } else {
        // Regular marker
        final placemark = PlacemarkMapObject(
          mapId: MapObjectId('store_${store.id}'),
          point: Point(latitude: store.latitude, longitude: store.longitude),
          opacity: 1.0,
          consumeTapEvents: true,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                hasDeal
                    ? 'assets/icons/ic_store_deal_marker.png'
                    : 'assets/icons/ic_store_marker.png',
              ),
              scale: hasDeal ? 0.4 : 0.35,
              anchor: const Offset(0.5, 1.0),
              rotationType: RotationType.noRotation,
            ),
          ),
          onTap: (PlacemarkMapObject self, Point point) {
            _onMarkerTap(store);
          },
        );
        placemarks.add(placemark);
      }
    }

    _placemarks.value = placemarks;
  }

  void _onMarkerTap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    // Set selected store and start continuous animation
    _selectedStore.value = store;
    _markerAnimationController.repeat();

    if (_mapController != null && !_isDisposed && mounted) {
      try {
        _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  Point(latitude: store.latitude, longitude: store.longitude),
              zoom: 16.5,
            ),
          ),
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 0.8,
          ),
        );
      } catch (e) {
        debugPrint('⚠️ Camera move failed: $e');
      }
    }
  }

  void _clearSelectedStore() {
    if (!_isDisposed) {
      _selectedStore.value = null;
      _markerAnimationController.stop();
      _markerAnimationController.reset();
      _addShopMarkers();
    }
  }

  Future<void> _getCurrentLocation() async {
    _isLoadingLocation.value = true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      if (!mounted || _isDisposed) return;

      _userPositionNotifier.value = position;

      if (_mapController != null && !_isDisposed && mounted) {
        try {
          await _mapController!.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: Point(
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
                zoom: 11.5,
              ),
            ),
            animation: const MapAnimation(
              type: MapAnimationType.smooth,
              duration: 1.2,
            ),
          );

          _addShopMarkers();
        } catch (e) {
          debugPrint('⚠️ Camera move failed: $e');
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (!_isDisposed) {
        _isLoadingLocation.value = false;
      }
    }
  }

  void _moveToUserLocation() {
    final userPosition = _userPositionNotifier.value;
    if (userPosition != null &&
        _mapController != null &&
        !_isDisposed &&
        mounted) {
      try {
        _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(
                latitude: userPosition.latitude,
                longitude: userPosition.longitude,
              ),
              zoom: 11.5,
            ),
          ),
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 1.0,
          ),
        );
      } catch (e) {
        debugPrint('⚠️ Camera move failed: $e');
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery.value = '';
    _searchResults.value = [];
    _searchFocusNode.unfocus();
    _removeSearchMarker();
  }

  void _clearSearchAndSelection() {
    _clearSearch();
    _clearSelectedStore();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchQuery.value = query;

    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _searchResults.value = [];
      _isSearching.value = false;
      return;
    }

    if (!_searchAvailable) {
      _searchStoresOnly(query);
      return;
    }

    _isSearching.value = true;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _searchStoresOnly(String query) {
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final store in widget.stores) {
      if (store.name.toLowerCase().contains(lowerQuery) ||
          store.address.toLowerCase().contains(lowerQuery) ||
          store.category.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult.fromStore(store));
      }
    }

    if (!_isDisposed) {
      _searchResults.value = results;
    }
  }

  Future<void> _performSearch(String query) async {
    if (_isDisposed || !_searchAvailable) return;

    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final store in widget.stores) {
      if (store.name.toLowerCase().contains(lowerQuery) ||
          store.address.toLowerCase().contains(lowerQuery) ||
          store.category.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult.fromStore(store));
      }
    }

    if (results.isNotEmpty && !_isDisposed) {
      _searchResults.value = List.from(results);
    }

    try {
      final geocodeResults = await _searchLocations(query);
      results.addAll(geocodeResults);

      if (!_isDisposed) {
        _searchResults.value = results;
        _isSearching.value = false;
      }
    } catch (e) {
      debugPrint('❌ Location search error: $e');

      if (e.toString().contains('MissingPluginException')) {
        _searchAvailable = false;
        debugPrint('⚠️ Yandex Search not available on this platform');
      }

      if (!_isDisposed) {
        _isSearching.value = false;
      }
    }
  }

  Future<List<SearchResult>> _searchLocations(String query) async {
    if (_isDisposed) return [];

    try {
      await _activeSearchSession?.close();

      final searchCenter = _userPositionNotifier.value != null
          ? Point(
              latitude: _userPositionNotifier.value!.latitude,
              longitude: _userPositionNotifier.value!.longitude,
            )
          : const Point(latitude: 41.2995, longitude: 69.2401);

      final resultWithSession = await YandexSearch.searchByText(
        searchText: query,
        geometry: Geometry.fromPoint(searchCenter),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          resultPageSize: 15,
          geometry: true,
        ),
      );

      final session = resultWithSession.$1;
      final resultFuture = resultWithSession.$2;

      _activeSearchSession = session;

      final result = await resultFuture;

      debugPrint('📋 Location search results: ${result.items?.length ?? 0}');

      final locationResults = <SearchResult>[];

      if (result.items != null && result.items!.isNotEmpty) {
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

          final kind = _determineLocationKind(title);

          locationResults.add(SearchResult.fromLocation(
            address: title,
            point: point,
            kind: kind,
          ));
        }
      }

      await session.close();
      _activeSearchSession = null;

      return locationResults;
    } catch (e) {
      debugPrint('❌ Yandex search error: $e');
      return [];
    }
  }

  String _determineLocationKind(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('street') ||
        lowerTitle.contains('avenue') ||
        lowerTitle.contains('road') ||
        lowerTitle.contains('ko\'cha') ||
        lowerTitle.contains('koʻcha')) {
      return 'street';
    }

    if (lowerTitle.contains('district') || lowerTitle.contains('tuman')) {
      return 'district';
    }

    if (lowerTitle.contains('city') || lowerTitle.contains('shahar')) {
      return 'city';
    }

    if (lowerTitle.contains('region') || lowerTitle.contains('viloyat')) {
      return 'region';
    }

    if (lowerTitle.contains('uzbekistan') ||
        lowerTitle.contains('o\'zbekiston')) {
      return 'country';
    }

    return 'location';
  }

  bool _isCoordinateString(String text) {
    final coordPattern = RegExp(r'^-?\d+\.?\d*,?\s*-?\d+\.?\d*$');
    return coordPattern.hasMatch(text);
  }

  void _onSearchResultTap(SearchResult result) {
    if (_isDisposed || !mounted || _mapController == null) return;

    try {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: result.point,
            zoom: _getZoomForResultType(result),
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1.0,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Camera move failed: $e');
    }

    if (result.type == SearchResultType.store && result.store != null) {
      // Set selected store and start continuous animation
      _selectedStore.value = result.store;
      _markerAnimationController.repeat();
    } else {
      _addSearchMarker(result);
    }

    // Close search overlay after result is tapped
    _clearSearch();
  }

  double _getZoomForResultType(SearchResult result) {
    if (result.type == SearchResultType.store) {
      return 16.5;
    }

    switch (result.kind) {
      case 'street':
        return 15;
      case 'district':
        return 13;
      case 'city':
        return 11;
      case 'region':
        return 9;
      case 'country':
        return 6;
      default:
        return 13;
    }
  }

  void _addSearchMarker(SearchResult result) {
    _searchMarker = PlacemarkMapObject(
      mapId: const MapObjectId('search_result'),
      point: result.point,
      opacity: 1.0,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage(
            'assets/icons/ic_user_location.png',
          ),
          scale: 0.35,
          anchor: const Offset(0.5, 1.0),
          rotationType: RotationType.noRotation,
        ),
      ),
    );

    _addShopMarkers();
  }

  void _removeSearchMarker() {
    if (_searchMarker != null) {
      _searchMarker = null;
      _addShopMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _clearSearchAndSelection,
        child: Stack(
          children: [
            // Full screen map
            ValueListenableBuilder<List<PlacemarkMapObject>>(
              valueListenable: _placemarks,
              builder: (context, placemarks, _) {
                return YandexMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.map,
                  mapObjects: placemarks,
                );
              },
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GradientAppBar(
                title: "Find stores",
                showBackButton: true,
                subtitle: "discover stores near you",
              ),
            ),

            // Top search bar - always visible
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: MediaQuery.of(context).padding.top + 24.h,
                ),
                child: Column(
                  children: [
                    MapSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onClear: _clearSearch,
                      onBack: () => Navigator.pop(context),
                      isSearchAvailable: _searchAvailable,
                    ),
                    SizedBox(height: 12.h),
                    // Search results overlay
                    ValueListenableBuilder<String>(
                      valueListenable: _searchQuery,
                      builder: (context, query, _) {
                        if (query.isEmpty) return const SizedBox.shrink();

                        return SearchResultsOverlay(
                          searchQueryNotifier: _searchQuery,
                          searchResultsNotifier: _searchResults,
                          isSearchingNotifier: _isSearching,
                          onResultTap: _onSearchResultTap,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Floating store info card - appears when store is selected
            ValueListenableBuilder<StoreModel?>(
              valueListenable: _selectedStore,
              builder: (context, selectedStore, _) {
                if (selectedStore == null) return const SizedBox.shrink();

                return FloatingStoreInfoCard(
                  store: selectedStore,
                  userPosition: _userPositionNotifier.value,
                  onClose: _clearSelectedStore,
                  onViewStore: () {
                    widget.onStoreSelected(selectedStore);
                  },
                );
              },
            ),

            // Bottom navigation button
            Positioned(
              bottom: 32.h,
              right: 16.w,
              child: CurrentLocationFab(
                isLoadingNotifier: _isLoadingLocation,
                onPressed: _getCurrentLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Map Search Bar - Always visible with back button integrated
class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final VoidCallback onBack;
  final bool isSearchAvailable;

  const MapSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.onBack,
    this.isSearchAvailable = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16.r),
      color: Colors.white,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: isSearchAvailable
                      ? 'Search stores, streets, districts...'
                      : 'Search stores...',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 20.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Search Results Overlay
class SearchResultsOverlay extends StatelessWidget {
  final ValueNotifier<String> searchQueryNotifier;
  final ValueNotifier<List<SearchResult>> searchResultsNotifier;
  final ValueNotifier<bool> isSearchingNotifier;
  final Function(SearchResult) onResultTap;

  const SearchResultsOverlay({
    required this.searchQueryNotifier,
    required this.searchResultsNotifier,
    required this.isSearchingNotifier,
    required this.onResultTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16.r),
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints(maxHeight: 420.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isSearchingNotifier,
          builder: (context, isSearching, _) {
            if (isSearching) {
              return Padding(
                padding: EdgeInsets.all(40.w),
                child: Center(
                  child: SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            }

            return ValueListenableBuilder<List<SearchResult>>(
              valueListenable: searchResultsNotifier,
              builder: (context, results, _) {
                if (results.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48.sp,
                            color: Colors.grey[350],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Try different keywords',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1.h,
                    indent: 72.w,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return SearchResultItem(
                      result: result,
                      onTap: () => onResultTap(result),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Search Result Item
class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultItem({
    required this.result,
    required this.onTap,
    super.key,
  });

  IconData _getIconForKind(String? kind) {
    switch (kind) {
      case 'street':
        return Icons.route;
      case 'district':
        return Icons.map;
      case 'city':
        return Icons.location_city;
      case 'region':
        return Icons.terrain;
      case 'country':
        return Icons.public;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: result.type == SearchResultType.store
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                result.type == SearchResultType.store
                    ? Icons.storefront
                    : _getIconForKind(result.kind),
                color: result.type == SearchResultType.store
                    ? Theme.of(context).primaryColor
                    : Colors.blue,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      result.subtitle!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

// Search result classes
enum SearchResultType { store, location }

class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final SearchResultType type;
  final Point point;
  final StoreModel? store;
  final String? kind;

  const SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.point,
    this.store,
    this.kind,
  });

  factory SearchResult.fromStore(StoreModel store) {
    return SearchResult(
      id: 'store_${store.id}',
      title: store.name,
      subtitle: '${store.category} • ${store.address}',
      type: SearchResultType.store,
      point: Point(latitude: store.latitude, longitude: store.longitude),
      store: store,
    );
  }

  factory SearchResult.fromLocation({
    required String address,
    required Point point,
    String? kind,
  }) {
    String subtitle = 'Location';
    if (kind != null) {
      switch (kind) {
        case 'street':
          subtitle = 'Street';
          break;
        case 'district':
          subtitle = 'District';
          break;
        case 'city':
          subtitle = 'City';
          break;
        case 'region':
          subtitle = 'Region';
          break;
        case 'country':
          subtitle = 'Country';
          break;
        default:
          subtitle = 'Location';
      }
    }

    return SearchResult(
      id: 'location_${point.latitude}_${point.longitude}',
      title: address,
      subtitle: subtitle,
      type: SearchResultType.location,
      point: point,
      kind: kind,
    );
  }
}

