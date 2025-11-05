import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'dart:math' as math;

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  YandexMapController? _mapController;
  bool _isDisposed = false;
  final ValueNotifier<Position?> _userPositionNotifier =
      ValueNotifier<Position?>(null);
  final ValueNotifier<List<PlacemarkMapObject>> _placemarks =
      ValueNotifier<List<PlacemarkMapObject>>([]);
  final ValueNotifier<StoreModel?> _selectedStoreNotifier =
      ValueNotifier<StoreModel?>(null);
  final ValueNotifier<double> _sheetPosition = ValueNotifier<double>(0.4);

  // Expanded store list with more variety
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

  // Deal indicators for stores
  final Map<String, String> _storeDeals = {
    '1': '50% OFF',
    '3': 'Flash Sale',
    '5': 'Buy 2 Get 1',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userPositionNotifier.dispose();
    _placemarks.dispose();
    _selectedStoreNotifier.dispose();
    _sheetPosition.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _moveToDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _moveToDefaultLocation();
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
        await _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(
                  latitude: position.latitude, longitude: position.longitude),
              zoom: 12,
            ),
          ),
          animation:
              const MapAnimation(type: MapAnimationType.smooth, duration: 1.5),
        );

        // Re-add markers to include user location
        _addShopMarkers();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted && !_isDisposed) {
        _moveToDefaultLocation();
      }
    }
  }

  void _moveToDefaultLocation() {
    if (_mapController != null && !_isDisposed && mounted) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: Point(latitude: 41.2995, longitude: 69.2401),
            zoom: 12,
          ),
        ),
      );
    }
  }

  void _onMapCreated(YandexMapController controller) {
    if (_isDisposed) return;
    _mapController = controller;
    _addShopMarkers();
  }

  void _addShopMarkers() {
    if (_isDisposed) return;

    final placemarks = <PlacemarkMapObject>[];

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
                'assets/icons/ic_user_location.png'),
            scale: 0.3,
            anchor: const Offset(0.5, 0.5),
            rotationType: RotationType.noRotation,
          ),
        ),
      );
      placemarks.add(userPlacemark);
    }

    // Add store markers
    for (final store in _stores) {
      final hasDeal = _storeDeals.containsKey(store.id);

      final placemark = PlacemarkMapObject(
        mapId: MapObjectId('store_${store.id}'),
        point: Point(latitude: store.latitude, longitude: store.longitude),
        opacity: 1.0,
        consumeTapEvents: true,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage(hasDeal
                ? 'assets/icons/ic_store_deal_marker.png'
                : 'assets/icons/ic_store_marker.png'),
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

    _placemarks.value = placemarks;
  }

  void _onMarkerTap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    _selectedStoreNotifier.value = store;
    _sheetPosition.value = 0.1;

    if (_mapController != null && !_isDisposed && mounted) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: store.latitude, longitude: store.longitude),
            zoom: 14,
          ),
        ),
        animation:
            const MapAnimation(type: MapAnimationType.smooth, duration: 0.8),
      );
    }
  }

  void _focusStoreOnMap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    // Temporarily highlight the store marker
    _onMarkerTap(store);

    // Close sheet to show map
    _sheetPosition.value = 0.1;

    // After animation, show info card
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && !_isDisposed) {
        _selectedStoreNotifier.value = store;
      }
    });
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
      double lat1, double lon1, double lat2, double lon2) {
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

  void _closeInfoCard() {
    _selectedStoreNotifier.value = null;
    _sheetPosition.value = 0.4;
  }

  void _navigateToStoreDetails(StoreModel store) {
    Navigator.pushNamed(
      context,
      AppRoutes.storeDetails,
      arguments: store,
    );
  }

  List<StoreModel> get _topRatedStores {
    final sorted = List<StoreModel>.from(_stores);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(10).toList();
  }

  List<StoreModel> get _storesWithDeals {
    return _stores.where((s) => _storeDeals.containsKey(s.id)).toList();
  }

  List<StoreModel> get _featuredStores {
    return _stores.where((s) => s.totalRatings > 150).take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, John Doe',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _getCurrentLocation,
            icon: Icon(Icons.my_location),
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen map - ALWAYS RENDERED
          ValueListenableBuilder<List<PlacemarkMapObject>>(
            valueListenable: _placemarks,
            builder: (context, placemarks, _) {
              return YandexMap(
                onMapCreated: _onMapCreated,
                mapType: MapType.map,
                mapObjects: placemarks,
                onMapTap: (Point point) {
                  _closeInfoCard();
                },
              );
            },
          ),

          // Search bar at top - FIXED POSITIONING
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                child: SearchBarOverlay(
                  onTap: () {
                    // TODO: Navigate to search
                  },
                  isDark: isDark,
                ),
              ),
            ),
          ),

          // Store info card when marker tapped - FIXED POSITIONING
          ValueListenableBuilder<StoreModel?>(
            valueListenable: _selectedStoreNotifier,
            builder: (context, selectedStore, _) {
              if (selectedStore == null) return const SizedBox.shrink();

              final deal = _storeDeals[selectedStore.id];

              return Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 120.h,
                child: EnhancedStoreInfoCard(
                  store: selectedStore,
                  deal: deal,
                  onClose: _closeInfoCard,
                  onViewStore: () => _navigateToStoreDetails(selectedStore),
                  userPosition: _userPositionNotifier.value,
                  isDark: isDark,
                ),
              );
            },
          ),

          // Draggable bottom sheet
          ValueListenableBuilder<StoreModel?>(
            valueListenable: _selectedStoreNotifier,
            builder: (context, selectedStore, _) {
              if (selectedStore != null) return const SizedBox.shrink();

              return DraggableStoresSheet(
                stores: _stores,
                topRatedStores: _topRatedStores,
                featuredStores: _featuredStores,
                storesWithDeals: _storesWithDeals,
                storeDeals: _storeDeals,
                onStoreTap: _navigateToStoreDetails,
                onMarkerFocus: _focusStoreOnMap,
                sheetPositionNotifier: _sheetPosition,
                isDark: isDark,
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchBarOverlay extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const SearchBarOverlay({
    required this.onTap,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: isDark ? const Color(0xFFCBD5E1) : Colors.grey[600],
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Search stores...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? const Color(0xFFCBD5E1) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DraggableStoresSheet extends StatefulWidget {
  final List<StoreModel> stores;
  final List<StoreModel> topRatedStores;
  final List<StoreModel> featuredStores;
  final List<StoreModel> storesWithDeals;
  final Map<String, String> storeDeals;
  final Function(StoreModel) onStoreTap;
  final Function(StoreModel) onMarkerFocus;
  final ValueNotifier<double> sheetPositionNotifier;
  final bool isDark;

  const DraggableStoresSheet({
    required this.stores,
    required this.topRatedStores,
    required this.featuredStores,
    required this.storesWithDeals,
    required this.storeDeals,
    required this.onStoreTap,
    required this.onMarkerFocus,
    required this.sheetPositionNotifier,
    required this.isDark,
    super.key,
  });

  @override
  State<DraggableStoresSheet> createState() => _DraggableStoresSheetState();
}

class _DraggableStoresSheetState extends State<DraggableStoresSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  bool _showAllTopSellers = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.isAttached) {
        _controller.jumpTo(widget.sheetPositionNotifier.value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSheetDrag(double position) {
    widget.sheetPositionNotifier.value = position;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        _onSheetDrag(notification.extent);
        return true;
      },
      child: DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: 0.4,
        minChildSize: 0.1,
        maxChildSize: 0.85,
        snap: true,
        snapSizes: const [0.1, 0.4, 0.85],
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF334155)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      // Minimized hint
                      ValueListenableBuilder<double>(
                        valueListenable: widget.sheetPositionNotifier,
                        builder: (context, position, child) {
                          if (position > 0.15) return const SizedBox.shrink();

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 16.sp,
                                  color: widget.isDark
                                      ? const Color(0xFFCBD5E1)
                                      : Colors.grey[600],
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Swipe up to explore stores',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: widget.isDark
                                        ? const Color(0xFFCBD5E1)
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Hot Deals Section
                      if (widget.storesWithDeals.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                          child: Row(
                            children: [
                              Text(
                                '🔥 Hot Deals Nearby',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDark
                                      ? const Color(0xFFF1F5F9)
                                      : Colors.black,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '${widget.storesWithDeals.length}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 120.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: widget.storesWithDeals.length,
                            itemBuilder: (context, index) {
                              final store = widget.storesWithDeals[index];
                              final deal = widget.storeDeals[store.id]!;

                              return Padding(
                                padding: EdgeInsets.only(right: 12.w),
                                child: DealBannerCard(
                                  store: store,
                                  deal: deal,
                                  onTap: () => widget.onStoreTap(store),
                                  onMapFocus: () => widget.onMarkerFocus(store),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Featured Stores - Horizontal Scroll
                      if (widget.featuredStores.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '⭐ Featured Stores',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDark
                                      ? const Color(0xFFF1F5F9)
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                '${widget.featuredStores.length} stores',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: widget.isDark
                                      ? const Color(0xFFCBD5E1)
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 160.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: widget.featuredStores.length,
                            itemBuilder: (context, index) {
                              final store = widget.featuredStores[index];
                              return Padding(
                                padding: EdgeInsets.only(right: 12.w),
                                child: FeaturedStoreCompactCard(
                                  store: store,
                                  onTap: () => widget.onStoreTap(store),
                                  onMapFocus: () => widget.onMarkerFocus(store),
                                  isDark: widget.isDark,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Top Sellers - Compact with View All
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Top Sellers Near You',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: widget.isDark
                                    ? const Color(0xFFF1F5F9)
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              '${widget.topRatedStores.length} stores',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: widget.isDark
                                    ? const Color(0xFFCBD5E1)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Show only 5 or all based on state
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _showAllTopSellers
                            ? widget.topRatedStores.length
                            : (widget.topRatedStores.length > 3
                                ? 3
                                : widget.topRatedStores.length),
                        itemBuilder: (context, index) {
                          final store = widget.topRatedStores[index];
                          return TopSellerCompactItem(
                            store: store,
                            rank: index + 1,
                            onTap: () => widget.onStoreTap(store),
                            onMapFocus: () => widget.onMarkerFocus(store),
                            isDark: widget.isDark,
                          );
                        },
                      ),

                      // View All / Show Less button
                      if (widget.topRatedStores.length > 5) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showAllTopSellers = !_showAllTopSellers;
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: widget.isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey[100],
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _showAllTopSellers
                                      ? 'Show Less'
                                      : 'View All (${widget.topRatedStores.length})',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  _showAllTopSellers
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Theme.of(context).primaryColor,
                                  size: 18.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FeaturedStoreCompactCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;
  final bool isDark;

  const FeaturedStoreCompactCard({
    required this.store,
    required this.onTap,
    required this.onMapFocus,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200.w,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and map button
              Container(
                height: 80.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: isDark ? 0.1 : 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.storefront,
                          size: 32.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: onMapFocus,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
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
              ),

              // Store info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? const Color(0xFFF1F5F9) : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            '${store.rating}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFF1F5F9)
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '(${store.totalRatings})',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

class TopSellerCompactItem extends StatelessWidget {
  final StoreModel store;
  final int rank;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;
  final bool isDark;

  const TopSellerCompactItem({
    required this.store,
    required this.rank,
    required this.onTap,
    required this.onMapFocus,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getRankColors(),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Store icon
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.storefront,
                    color: Theme.of(context).primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? const Color(0xFFF1F5F9) : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, size: 12.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            '${store.rating}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFF1F5F9)
                                  : Colors.black,
                            ),
                          ),
                          if (store.distance != null) ...[
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.location_on,
                              size: 12.sp,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : Colors.grey[600],
                            ),
                            SizedBox(width: 2.w),
                            Flexible(
                              child: Text(
                                '${store.distance!.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : Colors.grey[600],
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

                // Map button
                IconButton(
                  onPressed: onMapFocus,
                  icon: Icon(
                    Icons.location_searching,
                    color: Theme.of(context).primaryColor,
                    size: 18.sp,
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

  List<Color> _getRankColors() {
    if (rank == 1) return [Colors.amber[700]!, Colors.yellow[600]!];
    if (rank == 2) return [Colors.grey[400]!, Colors.grey[300]!];
    if (rank == 3) return [Colors.brown[400]!, Colors.brown[300]!];
    return [Colors.blue[400]!, Colors.blue[300]!];
  }
}

class EnhancedStoreInfoCard extends StatelessWidget {
  final StoreModel store;
  final String? deal;
  final VoidCallback onClose;
  final VoidCallback onViewStore;
  final Position? userPosition;
  final bool isDark;

  const EnhancedStoreInfoCard({
    required this.store,
    this.deal,
    required this.onClose,
    required this.onViewStore,
    this.userPosition,
    required this.isDark,
    super.key,
  });

  double? _calculateDistance() {
    if (userPosition == null) return null;

    const double earthRadius = 6371;
    final dLat = _toRadians(store.latitude - userPosition!.latitude);
    final dLon = _toRadians(store.longitude - userPosition!.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(userPosition!.latitude)) *
            math.cos(_toRadians(store.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final distance = store.distance ?? _calculateDistance();

    return SafeArea(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16.r),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (deal != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          deal!,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.2),
                            Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.storefront,
                        color: Theme.of(context).primaryColor,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFF1F5F9)
                                  : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16.sp,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${store.rating}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFF1F5F9)
                                      : Colors.black,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  '(${store.totalRatings} reviews)',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(
                        Icons.close,
                        color: isDark ? const Color(0xFFF1F5F9) : Colors.black,
                      ),
                      iconSize: 20.sp,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color:
                          isDark ? const Color(0xFFCBD5E1) : Colors.grey[600],
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        store.address,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (distance != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewStore,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'View Store & Products',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DealBannerCard extends StatelessWidget {
  final StoreModel store;
  final String deal;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;

  const DealBannerCard({
    required this.store,
    required this.deal,
    required this.onTap,
    required this.onMapFocus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 280.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red,
                Colors.orange,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10.h,
                right: -10.w,
                child: Icon(
                  Icons.local_fire_department,
                  size: 80.sp,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            deal,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onMapFocus,
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            if (store.distance != null) ...[
                              Icon(
                                Icons.directions_walk,
                                size: 14.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${store.distance!.toStringAsFixed(1)} km away',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              SizedBox(width: 12.w),
                            ],
                            Icon(
                              Icons.star,
                              size: 14.sp,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${store.rating}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
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
