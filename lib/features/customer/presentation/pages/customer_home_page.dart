import 'dart:async';
import 'dart:ui' as ui;
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/core/utils/map_clustering_helper.dart';
import 'package:universal_go/features/customer/data/models/map_store_cluster.dart';
import 'package:universal_go/features/customer/presentation/pages/customer_map_full_page.dart';
import 'package:universal_go/features/customer/presentation/widgets/store_info_card.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_go/shared/widgets/gradient_app_bar.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'dart:math' as math;

enum StoreTab { all, deals, featured, nearby }

enum ViewMode { grid, list }

enum SortOption { distance, rating, name }

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  YandexMapController? _mapController;
  bool _isDisposed = false;
  final ValueNotifier<Position?> _userPositionNotifier =
      ValueNotifier<Position?>(null);
  final ValueNotifier<List<PlacemarkMapObject>> _placemarks =
      ValueNotifier<List<PlacemarkMapObject>>([]);
  final ValueNotifier<bool> _isLoadingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<double> _currentZoom = ValueNotifier<double>(11.5);

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ValueNotifier<double> _sheetPosition = ValueNotifier<double>(0.35);

  final ValueNotifier<StoreTab> _selectedTab = ValueNotifier(StoreTab.all);
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<String?> _selectedCategory = ValueNotifier(null);
  final ValueNotifier<ViewMode> _viewMode = ValueNotifier(ViewMode.list);
  final ValueNotifier<SortOption> _sortOption =
      ValueNotifier(SortOption.distance);
  final ValueNotifier<StoreModel?> _selectedStore = ValueNotifier(null);

  // Smooth pulsing animation for active marker
  late AnimationController _markerAnimationController;
  late Animation<double> _markerScaleAnimation;
  bool _isAnimatingMarker = false;

  // Cluster marker cache
  final Map<int, Uint8List> _clusterMarkerCache = {};
  bool _isGeneratingMarkers = false;

  // Zoom debouncing for smooth transitions
  Timer? _zoomDebounceTimer;
  double _lastProcessedZoom = 11.5;

  final List<StoreModel> _stores = [
    StoreModel(
      id: '1',
      ownerId: 'owner_1',
      name: 'TechStore Tashkent',
      category: 'Electronics',
      address: 'Chilonzor, Tashkent',
      latitude: 41.2995,
      longitude: 69.2401,
      rating: 4.5,
      totalRatings: 120,
      productCount: 25,
      description: 'Your trusted electronics shop',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '2',
      ownerId: 'owner_2',
      name: 'ElectroShop',
      category: 'Electronics',
      address: 'Mirabad, Tashkent',
      latitude: 41.3111,
      longitude: 69.2797,
      rating: 4.2,
      totalRatings: 85,
      productCount: 18,
      description: 'Quality electronics at affordable prices',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '3',
      ownerId: 'owner_3',
      name: 'HomeGoods Plus',
      category: 'Home & Garden',
      address: 'Yunusabad, Tashkent',
      latitude: 41.3775,
      longitude: 69.2097,
      rating: 4.7,
      totalRatings: 210,
      productCount: 32,
      description: 'Everything for your home',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '4',
      ownerId: 'owner_4',
      name: 'Fashion Store',
      category: 'Fashion',
      address: 'Shayxontohur, Tashkent',
      latitude: 41.2647,
      longitude: 69.2163,
      rating: 4.3,
      totalRatings: 95,
      productCount: 15,
      description: 'Latest fashion trends',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '5',
      ownerId: 'owner_5',
      name: 'BookWorld',
      category: 'Books',
      address: 'Olmazor, Tashkent',
      latitude: 41.3381,
      longitude: 69.2063,
      rating: 4.8,
      totalRatings: 305,
      productCount: 45,
      description: 'A world of knowledge',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 730)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '6',
      ownerId: 'owner_6',
      name: 'FreshMart',
      category: 'Groceries',
      address: 'Sergeli, Tashkent',
      latitude: 41.2237,
      longitude: 69.2193,
      rating: 4.6,
      totalRatings: 178,
      productCount: 52,
      description: 'Fresh groceries daily',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 420)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '7',
      ownerId: 'owner_7',
      name: 'QuickStop',
      category: 'Convenience',
      address: 'Yashnabad, Tashkent',
      latitude: 41.2848,
      longitude: 69.2347,
      rating: 4.1,
      totalRatings: 67,
      productCount: 12,
      description: '24/7 convenience store',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '8',
      ownerId: 'owner_8',
      name: 'Sports Arena',
      category: 'Sports',
      address: 'Mirobod, Tashkent',
      latitude: 41.3198,
      longitude: 69.2895,
      rating: 4.4,
      totalRatings: 143,
      productCount: 28,
      description: 'All sports equipment',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 310)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '9',
      ownerId: 'owner_9',
      name: 'Pet Paradise',
      category: 'Pets',
      address: 'Hamza, Tashkent',
      latitude: 41.3542,
      longitude: 69.2512,
      rating: 4.9,
      totalRatings: 267,
      productCount: 38,
      description: 'Everything for your pets',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 650)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '10',
      ownerId: 'owner_10',
      name: 'Beauty Corner',
      category: 'Beauty',
      address: 'Uchtepa, Tashkent',
      latitude: 41.2887,
      longitude: 69.1945,
      rating: 4.5,
      totalRatings: 192,
      productCount: 41,
      description: 'Beauty products & cosmetics',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 275)),
      updatedAt: DateTime.now(),
    ),
  ];

  final Map<String, String> _storeDeals = {
    '1': '50% OFF',
    '3': 'Flash Sale',
    '5': 'Buy 2 Get 1',
  };

  List<String> get _categories {
    final cats = _stores.map((s) => s.category).toSet().toList();
    cats.sort();
    return cats;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _sheetController.addListener(_onSheetChanged);
    _initializeMarkerAnimation();
    _generateClusterMarkers();

    // Set initial zoom level for proper clustering display
    _currentZoom.value = MapClusteringHelper.tashkentInitialZoom;
    _lastProcessedZoom = MapClusteringHelper.tashkentInitialZoom;

    // Get location after a small delay to ensure map is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        _getCurrentLocation();
      }
    });
  }

  void _initializeMarkerAnimation() {
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

    _markerAnimationController.addListener(_updateActiveMarker);
  }

  Future<void> _generateClusterMarkers() async {
    if (_isGeneratingMarkers) return;
    _isGeneratingMarkers = true;

    // Pre-generate markers for counts 2-100 (common cluster sizes)
    for (int count = 2; count <= 100; count++) {
      if (_clusterMarkerCache.containsKey(count)) continue;

      final bytes = await _createClusterMarkerBytesAsync(count);
      if (!_isDisposed && mounted) {
        _clusterMarkerCache[count] = bytes;
      }
    }

    _isGeneratingMarkers = false;
  }

  Future<Uint8List> _createClusterMarkerBytesAsync(int count) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // MUCH LARGER - 85-95px to be clearly visible and match pin marker height
    final double size = count > 50 ? 95.0 : (count > 10 ? 90.0 : 85.0);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Draw larger shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center.translate(0, 3), radius, shadowPaint);

    // Draw main circle
    final paint = Paint()
      ..color = const Color(0xFF6B4EFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    // Draw thick white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw text - much larger fonts
    final fontSize = count > 99 ? 22.0 : (count > 9 ? 24.0 : 26.0);

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

  Uint8List? _getClusterMarkerBytes(int count) {
    return _clusterMarkerCache[count];
  }

  void _updateActiveMarker() {
    if (!_isDisposed && _isAnimatingMarker && _selectedStore.value != null) {
      _addShopMarkers();
    }
  }

  void _startMarkerAnimation() {
    if (_isDisposed || _isAnimatingMarker) return;
    _isAnimatingMarker = true;
    _markerAnimationController.repeat();
  }

  void _stopMarkerAnimation() {
    if (_isDisposed || !_isAnimatingMarker) return;
    _isAnimatingMarker = false;
    _markerAnimationController.stop();
    _markerAnimationController.reset();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _zoomDebounceTimer?.cancel();
    _stopMarkerAnimation();
    _clusterMarkerCache.clear();
    _userPositionNotifier.dispose();
    _markerAnimationController.dispose();
    _placemarks.dispose();
    _isLoadingLocation.dispose();
    _selectedTab.dispose();
    _searchQuery.dispose();
    _selectedCategory.dispose();
    _viewMode.dispose();
    _sortOption.dispose();
    _selectedStore.dispose();
    _sheetController.dispose();
    _sheetPosition.dispose();
    _currentZoom.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    if (_sheetController.isAttached) {
      _sheetPosition.value = _sheetController.size;
    }
  }

  Future<void> _getCurrentLocation({bool showLoading = false}) async {
    if (showLoading) {
      _isLoadingLocation.value = true;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _moveToTashkentCenter();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _moveToTashkentCenter();
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
      _calculateDistances(position);

      if (_mapController != null && !_isDisposed && mounted) {
        // Check if user is in Tashkent area (within ~25km)
        final distanceFromTashkent = _calculateDistance(
          position.latitude,
          position.longitude,
          MapClusteringHelper.tashkentCenterLat,
          MapClusteringHelper.tashkentCenterLon,
        );

        final Point target;
        final double zoom;

        if (distanceFromTashkent < 25) {
          // User is in Tashkent - center on their location with closer zoom
          target = Point(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          zoom = 12.0;
        } else {
          // User is outside Tashkent - show whole Tashkent
          target = const Point(
            latitude: MapClusteringHelper.tashkentCenterLat,
            longitude: MapClusteringHelper.tashkentCenterLon,
          );
          zoom = MapClusteringHelper.tashkentInitialZoom;
        }

        await _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: zoom),
          ),
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 0.8,
          ),
        );

        _addShopMarkers();

        if (_sheetController.isAttached && !showLoading) {
          _sheetController.animateTo(
            0.35,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted && !_isDisposed) {
        _moveToTashkentCenter();
      }
    } finally {
      if (showLoading && !_isDisposed) {
        _isLoadingLocation.value = false;
      }
    }
  }

  void _moveToTashkentCenter() {
    if (_mapController != null && !_isDisposed && mounted) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: Point(
              latitude: MapClusteringHelper.tashkentCenterLat,
              longitude: MapClusteringHelper.tashkentCenterLon,
            ),
            zoom: MapClusteringHelper.tashkentInitialZoom,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.6,
        ),
      );
    }
  }

  void _onMapCreated(YandexMapController controller) {
    if (_isDisposed) return;
    _mapController = controller;
    _mapController!.toggleUserLayer(visible: true);

    // Set initial camera position to Tashkent
    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: Point(
            latitude: MapClusteringHelper.tashkentCenterLat,
            longitude: MapClusteringHelper.tashkentCenterLon,
          ),
          zoom: MapClusteringHelper.tashkentInitialZoom,
        ),
      ),
    );

    _addShopMarkers();
  }

  void _onZoomChanged(double newZoom) {
    _currentZoom.value = newZoom;

    // Debounce zoom changes for smooth clustering
    _zoomDebounceTimer?.cancel();
    _zoomDebounceTimer = Timer(const Duration(milliseconds: 120), () {
      if (!_isDisposed && mounted) {
        // Recalculate if crossed significant zoom boundary
        if (_shouldRecalculateClusters(_lastProcessedZoom, newZoom)) {
          _lastProcessedZoom = newZoom;
          _addShopMarkers();
        }
      }
    });
  }

  bool _shouldRecalculateClusters(double oldZoom, double newZoom) {
    // UPDATED: Main boundary at 13.0 (was 12.5)
    const mainBoundary = MapClusteringHelper.individualStoreThreshold;

    final wasAbove = oldZoom >= mainBoundary;
    final isAbove = newZoom >= mainBoundary;

    if (wasAbove != isAbove) {
      return true; // Crossed the main boundary
    }

    // UPDATED: Sub-boundaries aligned with new thresholds
    const subBoundaries = [9.5, 11.5, 13.0];

    for (final boundary in subBoundaries) {
      final wasBelow = oldZoom < boundary;
      final isBelow = newZoom < boundary;
      if (wasBelow != isBelow) {
        return true;
      }
    }

    // Recalculate if zoom changed significantly
    return (newZoom - oldZoom).abs() > 0.6; // CHANGED: From 0.5 to 0.6
  }

  void _addShopMarkers() {
    if (_isDisposed) return;

    final placemarks = <PlacemarkMapObject>[];
    final currentZoom = _currentZoom.value;

    // Add user location marker
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
            scale: 0.22,
            anchor: const Offset(0.5, 0.5),
            rotationType: RotationType.noRotation,
          ),
        ),
      );
      placemarks.add(userPlacemark);
    }

    // Get clusters based on current zoom
    final clusters = MapClusteringHelper.clusterStores(_stores, currentZoom);
    final selectedStore = _selectedStore.value;

    // VALIDATION: Check total stores in clusters
    final totalStoresInClusters = clusters.fold<int>(
      0,
      (sum, cluster) => sum + cluster.count,
    );

    developer.log(
      'Zoom: ${currentZoom.toStringAsFixed(2)} | '
      'Total stores: ${_stores.length} | '
      'Stores in clusters: $totalStoresInClusters | '
      'Cluster count: ${clusters.length}',
      name: 'MapClustering',
    );

    // Check if we should show individual stores
    final showIndividual =
        MapClusteringHelper.shouldShowIndividualStores(currentZoom);

    for (final cluster in clusters) {
      if (showIndividual && cluster.count == 1) {
        // Above threshold: render as individual marker
        final store = cluster.stores.first;
        final isSelected = selectedStore?.id == store.id;
        final hasDeal = _storeDeals.containsKey(store.id);

        if (isSelected && _isAnimatingMarker) {
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
                scale: 0.30 * animationScale,
                anchor: const Offset(0.5, 1.0),
                rotationType: RotationType.noRotation,
              ),
            ),
            onTap: (PlacemarkMapObject self, Point point) {
              _onMarkerTap(store);
            },
          );
          placemarks.add(placemark);
        } else if (isSelected && !_isAnimatingMarker) {
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
                scale: 0.30,
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
                scale: hasDeal ? 0.26 : 0.22,
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
      } else {
        // Below threshold OR multi-store cluster: render as cluster marker
        final markerBytes = _getClusterMarkerBytes(cluster.count);
        if (markerBytes == null) continue;

        final placemark = PlacemarkMapObject(
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
          onTap: (PlacemarkMapObject self, Point point) {
            if (cluster.count == 1) {
              _onMarkerTap(cluster.stores.first);
            } else {
              _onClusterTap(cluster);
            }
          },
        );
        placemarks.add(placemark);
      }
    }

    _placemarks.value = placemarks;
  }

  void _onMarkerTap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    _selectedStore.value = store;
    _startMarkerAnimation();
    _addShopMarkers();

    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.22,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (_mapController != null && !_isDisposed && mounted) {
      // IMPROVED: More precise zoom and better centering
      final offsetLatitude = store.latitude + 0.0006;

      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: offsetLatitude,
              longitude: store.longitude,
            ),
            zoom: 16.8, // CHANGED: From 15.5 to 16.8 for closer view
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.6,
        ),
      );
    }
  }

  void _onClusterTap(StoreCluster cluster) {
    if (_isDisposed || !mounted || _mapController == null) return;

    final currentZoom = _currentZoom.value;

    // Calculate center
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

    // Progressive zoom increment
    final double newZoom;
    if (currentZoom < 9.5) {
      newZoom = 10.8; // From single cluster to medium clusters
    } else if (currentZoom < 10.8) {
      newZoom = 11.8; // From medium to tight clusters
    } else {
      newZoom = 13.5; // To individual stores (above 12.5 threshold)
    }

    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: centerLat, longitude: centerLon),
          zoom: newZoom,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.5,
      ),
    );
  }

  void _closeStoreCard() {
    if (_isDisposed || !mounted) return;

    _stopMarkerAnimation();
    _selectedStore.value = null;
    _addShopMarkers();
  }

  void _focusStoreOnMap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    _selectedStore.value = store;
    _startMarkerAnimation();
    _addShopMarkers();

    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.22,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (_mapController != null && !_isDisposed && mounted) {
      // IMPROVED: More precise zoom and better centering
      final offsetLatitude = store.latitude + 0.0006;

      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: offsetLatitude,
              longitude: store.longitude,
            ),
            zoom: 16.8, // CHANGED: From 15.5 to 16.8 for closer view
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.6,
        ),
      );
    }
  }

  void _calculateDistances(Position userPosition) {
    for (int i = 0; i < _stores.length; i++) {
      final distance = _calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        _stores[i].latitude,
        _stores[i].longitude,
      );
      _stores[i] = _stores[i].copyWith(distance: distance);
    }

    _stores.sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));
    if (mounted) setState(() {});
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  void _navigateToStoreDetails(StoreModel store) {
    Navigator.pushNamed(
      context,
      AppRoutes.storeDetails,
      arguments: store,
    );
  }

  void _navigateToFullMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapFullScreenPage(
          stores: _stores,
          storeDeals: _storeDeals,
          userPosition: _userPositionNotifier.value,
          onStoreSelected: _navigateToStoreDetails,
        ),
      ),
    );
  }

  List<StoreModel> _getFilteredStores(
    StoreTab tab,
    String query,
    String? category,
    SortOption sortBy,
  ) {
    List<StoreModel> filtered = List.from(_stores);

    switch (tab) {
      case StoreTab.deals:
        filtered =
            filtered.where((s) => _storeDeals.containsKey(s.id)).toList();
        break;
      case StoreTab.featured:
        filtered = filtered.where((s) => s.totalRatings > 150).toList();
        break;
      case StoreTab.nearby:
        filtered = filtered.where((s) => (s.distance ?? 999) < 5).toList();
        break;
      case StoreTab.all:
        break;
    }

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(lowerQuery) ||
            s.category.toLowerCase().contains(lowerQuery) ||
            s.address.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (category != null) {
      filtered = filtered.where((s) => s.category == category).toList();
    }

    switch (sortBy) {
      case SortOption.distance:
        filtered
            .sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));
        break;
      case SortOption.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final appBarHeight = 56.h;
    final buttonTopPosition = safeAreaTop + appBarHeight + 24.h;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Map Layer with Gesture Detection
          ValueListenableBuilder<List<PlacemarkMapObject>>(
            valueListenable: _placemarks,
            builder: (context, placemarks, _) {
              return Listener(
                onPointerDown: (_) {
                  if (_selectedStore.value != null) {
                    _closeStoreCard();
                  }
                },
                child: YandexMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.map,
                  mapObjects: placemarks,
                  onCameraPositionChanged: (cameraPosition, reason, finished) {
                    // Update zoom level continuously
                    _onZoomChanged(cameraPosition.zoom);

                    // Close card when map is moved/scrolled
                    if (reason == CameraUpdateReason.gestures &&
                        _selectedStore.value != null) {
                      _closeStoreCard();
                    }
                  },
                ),
              );
            },
          ),

          // GradientAppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GradientAppBar(
              title: 'Welcome, John Doe',
              showBackButton: false,
              actions: [
                NotificationButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
              ],
            ),
          ),

          // Map Controls Layer
          Positioned(
            top: buttonTopPosition,
            right: 12.w,
            child: Row(
              spacing: 12.w,
              children: [
                MapActionsButton(
                  onPressed: () => _getCurrentLocation(showLoading: true),
                  icon: Image(
                    image: const AssetImage("assets/icons/ic_navigate.png"),
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
                MapActionsButton(
                  onPressed: _navigateToFullMap,
                  icon: Icon(
                    Icons.fullscreen,
                    color: Theme.of(context).primaryColor,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),

          // Compact Store Info Card
          ValueListenableBuilder<StoreModel?>(
            valueListenable: _selectedStore,
            builder: (context, selectedStore, _) {
              if (selectedStore == null) return const SizedBox.shrink();

              return FloatingStoreInfoCard(
                store: selectedStore,
                userPosition: _userPositionNotifier.value,
                onClose: _closeStoreCard,
                onViewStore: () {
                  _navigateToStoreDetails(selectedStore);
                },
              );
            },
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.35,
            minChildSize: 0.22,
            maxChildSize: 0.92,
            snap: true,
            snapSizes: const [0.35, 0.6, 0.92],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<StoreTab>(
                  valueListenable: _selectedTab,
                  builder: (context, tab, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _searchQuery,
                      builder: (context, query, _) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: _selectedCategory,
                          builder: (context, category, _) {
                            return ValueListenableBuilder<SortOption>(
                              valueListenable: _sortOption,
                              builder: (context, sortBy, _) {
                                final filteredStores = _getFilteredStores(
                                  tab,
                                  query,
                                  category,
                                  sortBy,
                                );

                                return ValueListenableBuilder<ViewMode>(
                                  valueListenable: _viewMode,
                                  builder: (context, viewMode, _) {
                                    return CustomScrollView(
                                      controller: scrollController,
                                      physics: const ScrollPhysics(),
                                      slivers: [
                                        // Drag Handle
                                        SliverToBoxAdapter(
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 40.w,
                                                height: 4.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    2.r,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Search Bar
                                        SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                            ),
                                            child: SearchBarWidget(
                                              searchQueryNotifier: _searchQuery,
                                            ),
                                          ),
                                        ),

                                        SliverToBoxAdapter(
                                          child: SizedBox(height: 12.h),
                                        ),

                                        // Segmented Control
                                        SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                            ),
                                            child: SegmentedControlWidget(
                                              selectedTabNotifier: _selectedTab,
                                            ),
                                          ),
                                        ),

                                        SliverToBoxAdapter(
                                          child: SizedBox(height: 12.h),
                                        ),

                                        // Category Chips + View Toggle + Sort
                                        SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: CategoryChipsWidget(
                                                    categories: _categories,
                                                    selectedCategoryNotifier:
                                                        _selectedCategory,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                ViewToggleButton(
                                                  viewModeNotifier: _viewMode,
                                                ),
                                                SizedBox(width: 8.w),
                                                SortButton(
                                                  sortOptionNotifier:
                                                      _sortOption,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        SliverToBoxAdapter(
                                          child: SizedBox(height: 12.h),
                                        ),

                                        // Store List/Grid
                                        if (filteredStores.isEmpty)
                                          SliverFillRemaining(
                                            hasScrollBody: false,
                                            child: EmptyStateWidget(
                                              tab: tab,
                                              hasSearch: query.isNotEmpty ||
                                                  category != null,
                                            ),
                                          )
                                        else if (viewMode == ViewMode.grid)
                                          SliverPadding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 8.h,
                                            ),
                                            sliver: SliverGrid(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 12.w,
                                                mainAxisSpacing: 12.h,
                                                childAspectRatio: 0.75,
                                              ),
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                                (context, index) {
                                                  final store =
                                                      filteredStores[index];
                                                  final deal =
                                                      _storeDeals[store.id];

                                                  return RepaintBoundary(
                                                    child: UnifiedStoreGridCard(
                                                      store: store,
                                                      deal: deal,
                                                      onTap: () =>
                                                          _navigateToStoreDetails(
                                                              store),
                                                      onMapFocus: () =>
                                                          _focusStoreOnMap(
                                                              store),
                                                    ),
                                                  );
                                                },
                                                childCount:
                                                    filteredStores.length,
                                              ),
                                            ),
                                          )
                                        else
                                          SliverPadding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 8.h,
                                            ),
                                            sliver: SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                                (context, index) {
                                                  final store =
                                                      filteredStores[index];
                                                  final deal =
                                                      _storeDeals[store.id];

                                                  return UnifiedStoreListCard(
                                                    store: store,
                                                    deal: deal,
                                                    onTap: () =>
                                                        _navigateToStoreDetails(
                                                            store),
                                                    onMapFocus: () =>
                                                        _focusStoreOnMap(store),
                                                  );
                                                },
                                                childCount:
                                                    filteredStores.length,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGETS
// ============================================================================

class AnimatedSlideCard extends StatefulWidget {
  final Widget child;

  const AnimatedSlideCard({
    required this.child,
    super.key,
  });

  @override
  State<AnimatedSlideCard> createState() => _AnimatedSlideCardState();
}

class _AnimatedSlideCardState extends State<AnimatedSlideCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

class NotificationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NotificationButton({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.notifications, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final ValueNotifier<String> searchQueryNotifier;

  const SearchBarWidget({
    required this.searchQueryNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => searchQueryNotifier.value = value,
        decoration: InputDecoration(
          hintText: 'Search stores, categories...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20.sp,
          ),
          suffixIcon: ValueListenableBuilder<String>(
            valueListenable: searchQueryNotifier,
            builder: (context, query, _) {
              if (query.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey[600],
                  size: 20.sp,
                ),
                onPressed: () => searchQueryNotifier.value = '',
              );
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

class SegmentedControlWidget extends StatelessWidget {
  final ValueNotifier<StoreTab> selectedTabNotifier;

  const SegmentedControlWidget({
    required this.selectedTabNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StoreTab>(
      valueListenable: selectedTabNotifier,
      builder: (context, selectedTab, _) {
        return Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              TabButton(
                label: 'All',
                isSelected: selectedTab == StoreTab.all,
                onTap: () => selectedTabNotifier.value = StoreTab.all,
              ),
              TabButton(
                label: 'Deals',
                isSelected: selectedTab == StoreTab.deals,
                onTap: () => selectedTabNotifier.value = StoreTab.deals,
              ),
              TabButton(
                label: 'Featured',
                isSelected: selectedTab == StoreTab.featured,
                onTap: () => selectedTabNotifier.value = StoreTab.featured,
              ),
              TabButton(
                label: 'Nearby',
                isSelected: selectedTab == StoreTab.nearby,
                onTap: () => selectedTabNotifier.value = StoreTab.nearby,
              ),
            ],
          ),
        );
      },
    );
  }
}

class TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryChipsWidget extends StatelessWidget {
  final List<String> categories;
  final ValueNotifier<String?> selectedCategoryNotifier;

  const CategoryChipsWidget({
    required this.categories,
    required this.selectedCategoryNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedCategoryNotifier,
      builder: (context, selectedCategory, _) {
        return SizedBox(
          height: 32.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () {
                    selectedCategoryNotifier.value =
                        isSelected ? null : category;
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ViewToggleButton extends StatelessWidget {
  final ValueNotifier<ViewMode> viewModeNotifier;

  const ViewToggleButton({
    required this.viewModeNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ViewMode>(
      valueListenable: viewModeNotifier,
      builder: (context, viewMode, _) {
        return GestureDetector(
          onTap: () {
            viewModeNotifier.value =
                viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
          },
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              viewMode == ViewMode.grid ? Icons.grid_view : Icons.view_list,
              size: 18.sp,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }
}

class SortButton extends StatelessWidget {
  final ValueNotifier<SortOption> sortOptionNotifier;

  const SortButton({
    required this.sortOptionNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SortOption>(
      valueListenable: sortOptionNotifier,
      builder: (context, sortOption, _) {
        return GestureDetector(
          onTap: () => _showSortMenu(context),
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              Icons.sort,
              size: 18.sp,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            SortOptionTile(
              label: 'Distance',
              icon: Icons.location_on,
              isSelected: sortOptionNotifier.value == SortOption.distance,
              onTap: () {
                sortOptionNotifier.value = SortOption.distance;
                Navigator.pop(context);
              },
            ),
            SortOptionTile(
              label: 'Rating',
              icon: Icons.star,
              isSelected: sortOptionNotifier.value == SortOption.rating,
              onTap: () {
                sortOptionNotifier.value = SortOption.rating;
                Navigator.pop(context);
              },
            ),
            SortOptionTile(
              label: 'Name (A-Z)',
              icon: Icons.sort_by_alpha,
              isSelected: sortOptionNotifier.value == SortOption.name,
              onTap: () {
                sortOptionNotifier.value = SortOption.name;
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class SortOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SortOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: onTap,
    );
  }
}

class UnifiedStoreListCard extends StatelessWidget {
  final StoreModel store;
  final String? deal;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;

  const UnifiedStoreListCard({
    required this.store,
    this.deal,
    required this.onTap,
    required this.onMapFocus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.storefront,
                    color: Theme.of(context).primaryColor,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (deal != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.red, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                deal ?? '',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        store.category,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            '${store.rating}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          if (store.distance != null) ...[
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.location_on,
                              size: 14.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 2.w),
                            Flexible(
                              child: Text(
                                '${store.distance!.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: onMapFocus,
                  icon: Icon(
                    Icons.location_searching,
                    color: Theme.of(context).primaryColor,
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UnifiedStoreGridCard extends StatelessWidget {
  final StoreModel store;
  final String? deal;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;

  const UnifiedStoreGridCard({
    required this.store,
    this.deal,
    required this.onTap,
    required this.onMapFocus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.15),
                          Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.storefront,
                        color: Theme.of(context).primaryColor,
                        size: 40.sp,
                      ),
                    ),
                  ),
                  if (deal != null)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          deal ?? '',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onMapFocus,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 16.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            store.category,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star,
                                  size: 13.sp, color: Colors.amber),
                              SizedBox(width: 4.w),
                              Text(
                                '${store.rating}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          if (store.distance != null) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 13.sp,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 2.w),
                                Flexible(
                                  child: Text(
                                    '${store.distance!.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
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

class EmptyStateWidget extends StatelessWidget {
  final StoreTab tab;
  final bool hasSearch;

  const EmptyStateWidget({
    required this.tab,
    required this.hasSearch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    if (hasSearch) {
      message = 'No stores found\nTry adjusting your filters';
      icon = Icons.search_off;
    } else {
      switch (tab) {
        case StoreTab.deals:
          message = 'No deals available\nCheck back later';
          icon = Icons.local_offer_outlined;
          break;
        case StoreTab.featured:
          message = 'No featured stores\nCheck back later';
          icon = Icons.star_outline;
          break;
        case StoreTab.nearby:
          message = 'No stores nearby\nTry expanding your search';
          icon = Icons.location_off;
          break;
        default:
          message = 'No stores available';
          icon = Icons.store_outlined;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class MapActionsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const MapActionsButton({
    required this.onPressed,
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
            ),
          ],
        ),
        child: icon,
      ),
    );
  }
}
