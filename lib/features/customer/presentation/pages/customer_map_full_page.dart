import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_go/core/services/map/cluster_stores_service.dart';
import 'package:universal_go/core/utils/map_clustering_helper.dart';
import 'package:universal_go/features/customer/data/models/map_store_cluster.dart';
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

class _MapFullScreenPageState extends State<MapFullScreenPage> {
  YandexMapController? _mapController;
  bool _isDisposed = false;

  // Clustering
  final _clusteringService = MapClusteringService();
  List<StoreCluster> _currentClusters = [];
  final Map<int, Uint8List> _clusterMarkerCache = {};
  final Set<int> _generatingMarkers = {};

  // Core state
  final ValueNotifier<List<PlacemarkMapObject>> _placemarks =
      ValueNotifier<List<PlacemarkMapObject>>([]);
  final ValueNotifier<bool> _isLoadingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<Position?> _userPositionNotifier =
      ValueNotifier<Position?>(null);
  final ValueNotifier<StoreModel?> _selectedStore =
      ValueNotifier<StoreModel?>(null);
  final ValueNotifier<double> _currentZoom = ValueNotifier<double>(11.5);

  // Search state
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<List<SearchResult>> _searchResults =
      ValueNotifier<List<SearchResult>>([]);
  final ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  Timer? _zoomDebounceTimer;
  PlacemarkMapObject? _searchMarker;
  double _lastProcessedZoom = 11.5;

  SearchSession? _activeSearchSession;
  bool _searchAvailable = true;

  @override
  void initState() {
    super.initState();
    _userPositionNotifier.value = widget.userPosition;

    _initializeClustering();
    _generateEssentialClusterMarkers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userPosition != null) {
        _moveToUserLocation();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeClustering() async {
    await _clusteringService.initialize();
    _performClustering(_currentZoom.value);
  }

  Future<void> _performClustering(double zoom) async {
    final clusters = await _clusteringService.clusterStores(
      stores: widget.stores,
      zoom: zoom,
    );

    if (!_isDisposed && mounted) {
      _currentClusters = clusters;
      _addShopMarkers();
    }
  }

  Future<void> _generateEssentialClusterMarkers() async {
    const essentialSizes = [2, 3, 4, 5, 10, 15, 20, 25];

    for (final count in essentialSizes) {
      if (_clusterMarkerCache.containsKey(count)) continue;
      final bytes = await _createClusterMarkerBytes(count);
      if (!_isDisposed && mounted) {
        _clusterMarkerCache[count] = bytes;
      }
    }
  }

  Future<Uint8List> _getOrCreateClusterMarker(int count) async {
    if (_clusterMarkerCache.containsKey(count)) {
      return _clusterMarkerCache[count]!;
    }

    if (_generatingMarkers.contains(count)) {
      await Future.delayed(const Duration(milliseconds: 50));
      return _getOrCreateClusterMarker(count);
    }

    _generatingMarkers.add(count);
    final bytes = await _createClusterMarkerBytes(count);
    _generatingMarkers.remove(count);

    if (!_isDisposed && mounted) {
      _clusterMarkerCache[count] = bytes;
    }

    return bytes;
  }

  Future<Uint8List> _createClusterMarkerBytes(int count) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const double size = 56.0;
    const center = Offset(size / 2, size / 2);
    const radius = size / 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(0, 1.5), radius, shadowPaint);

    final paint = Paint()
      ..color = const Color(0xFF6B4EFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);

    final fontSize = count > 99 ? 16.0 : (count > 9 ? 18.0 : 20.0);
    final textPainter = TextPainter(
      text: TextSpan(
        text: count > 999 ? '999+' : count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _zoomDebounceTimer?.cancel();
    _clusteringService.dispose();
    _clusterMarkerCache.clear();
    _generatingMarkers.clear();
    _placemarks.dispose();
    _isLoadingLocation.dispose();
    _userPositionNotifier.dispose();
    _selectedStore.dispose();
    _searchQuery.dispose();
    _searchResults.dispose();
    _isSearching.dispose();
    _currentZoom.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _activeSearchSession?.close();
    _mapController?.dispose();
    MapClusteringHelper.clearCache();
    super.dispose();
  }

  void _onMapCreated(YandexMapController controller) {
    if (_isDisposed) return;
    _mapController = controller;
    _addShopMarkers();
  }

  void _onZoomChanged(double newZoom) {
    _currentZoom.value = newZoom;

    _zoomDebounceTimer?.cancel();
    _zoomDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (!_isDisposed &&
          mounted &&
          _shouldRecalculateClusters(_lastProcessedZoom, newZoom)) {
        _lastProcessedZoom = newZoom;
        _performClustering(newZoom);
      }
    });
  }

  bool _shouldRecalculateClusters(double oldZoom, double newZoom) {
    const mainBoundary = MapClusteringHelper.individualStoreThreshold;

    final wasAbove = oldZoom >= mainBoundary;
    final isAbove = newZoom >= mainBoundary;

    if (wasAbove != isAbove) return true;

    const boundaries = [11.0, 12.5, 14.0];
    for (final boundary in boundaries) {
      final wasBelow = oldZoom < boundary;
      final isBelow = newZoom < boundary;
      if (wasBelow != isBelow) return true;
    }

    return (newZoom - oldZoom).abs() > 1.0;
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
            scale: 0.28,
            anchor: const Offset(0.5, 0.5),
            rotationType: RotationType.noRotation,
          ),
        ),
      );
      placemarks.add(userPlacemark);
    }

    if (_searchMarker != null) {
      placemarks.add(_searchMarker!);
    }

    final selectedStore = _selectedStore.value;
    final showIndividual =
        MapClusteringHelper.shouldShowIndividualStores(_currentZoom.value);

    for (final cluster in _currentClusters) {
      if (showIndividual && cluster.count == 1) {
        final store = cluster.stores.first;
        final isSelected = selectedStore?.id == store.id;
        final hasDeal = widget.storeDeals.containsKey(store.id);

        final iconAsset = isSelected
            ? 'assets/icons/ic_active_marker.png'
            : (hasDeal
                ? 'assets/icons/ic_store_deal_marker.png'
                : 'assets/icons/ic_store_marker.png');

        final placemark = PlacemarkMapObject(
          mapId: MapObjectId('store_${store.id}'),
          point: Point(latitude: store.latitude, longitude: store.longitude),
          opacity: 1.0,
          consumeTapEvents: true,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(iconAsset),
              scale: 0.28,
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
        _getOrCreateClusterMarker(cluster.count).then((markerBytes) {
          if (_isDisposed || !mounted) return;

          final updatedPlacemarks =
              List<PlacemarkMapObject>.from(_placemarks.value);
          updatedPlacemarks.add(
            PlacemarkMapObject(
              mapId: MapObjectId('cluster_${cluster.id}'),
              point: Point(
                latitude: cluster.latitude,
                longitude: cluster.longitude,
              ),
              opacity: 1.0,
              consumeTapEvents: true,
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromBytes(markerBytes),
                  scale: 1.0,
                  anchor: const Offset(0.5, 0.5),
                  rotationType: RotationType.noRotation,
                ),
              ),
              onTap: (_, __) {
                if (cluster.count == 1) {
                  _onMarkerTap(cluster.stores.first);
                } else {
                  _onClusterTap(cluster);
                }
              },
            ),
          );
          _placemarks.value = updatedPlacemarks;
        });
      }
    }

    _placemarks.value = placemarks;
  }

  void _onMarkerTap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    _selectedStore.value = store;

    // Refresh markers to show active state
    _addShopMarkers();

    if (_mapController != null && !_isDisposed && mounted) {
      final offsetLatitude = store.latitude + 0.0005;
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: offsetLatitude, longitude: store.longitude),
            zoom: 16.5,
          ),
        ),
        animation:
            const MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
      );
    }
  }

  void _onClusterTap(StoreCluster cluster) {
    if (_isDisposed || !mounted || _mapController == null) return;

    if (cluster.count == 1) {
      _onMarkerTap(cluster.stores.first);
      return;
    }

    double minLat = cluster.stores.first.latitude;
    double maxLat = cluster.stores.first.latitude;
    double minLon = cluster.stores.first.longitude;
    double maxLon = cluster.stores.first.longitude;

    for (final store in cluster.stores) {
      if (store.latitude < minLat) minLat = store.latitude;
      if (store.latitude > maxLat) maxLat = store.latitude;
      if (store.longitude < minLon) minLon = store.longitude;
      if (store.longitude > maxLon) maxLon = store.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    final currentZoom = _currentZoom.value;
    final double newZoom;
    if (currentZoom < 11.0) {
      newZoom = 12.0;
    } else if (currentZoom < 12.5) {
      newZoom = 13.5;
    } else if (currentZoom < 14.0) {
      newZoom = 15.0;
    } else {
      newZoom = 16.0;
    }

    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: centerLat, longitude: centerLon),
          zoom: newZoom,
        ),
      ),
      animation:
          const MapAnimation(type: MapAnimationType.smooth, duration: 0.4),
    );
  }

  void _clearSelectedStore() {
    if (!_isDisposed) {
      _selectedStore.value = null;
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
      _selectedStore.value = result.store;
    } else {
      _addSearchMarker(result);
    }

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
          scale: 0.28,
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
            RepaintBoundary(
              child: ValueListenableBuilder<List<PlacemarkMapObject>>(
                valueListenable: _placemarks,
                builder: (context, placemarks, _) {
                  return YandexMap(
                    onMapCreated: _onMapCreated,
                    mapType: MapType.map,
                    mapObjects: placemarks,
                    onCameraPositionChanged:
                        (cameraPosition, reason, finished) {
                      _onZoomChanged(cameraPosition.zoom);
                      if (reason == CameraUpdateReason.gestures &&
                          _selectedStore.value != null) {
                        _clearSelectedStore();
                      }
                    },
                  );
                },
              ),
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
