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
  final ValueNotifier<bool> _isLoadingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isMapExpanded = ValueNotifier<bool>(false);

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
    _isLoadingLocation.dispose();
    _isMapExpanded.dispose();
    _mapController?.dispose();
    super.dispose();
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
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted && !_isDisposed) {
        _moveToDefaultLocation();
      }
    } finally {
      if (showLoading && !_isDisposed) {
        _isLoadingLocation.value = false;
      }
    }
  }

  void _moveToDefaultLocation() {
    if (_mapController != null && !_isDisposed && mounted) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: Point(latitude: 41.2995, longitude: 69.2401),
            zoom: 11.5,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1.0,
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

    for (final store in _stores) {
      final hasDeal = _storeDeals.containsKey(store.id);

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

    _placemarks.value = placemarks;
  }

  void _onMarkerTap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    _showStoreDetailsSheet(store);

    if (_mapController != null && !_isDisposed && mounted) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: store.latitude, longitude: store.longitude),
            zoom: 14,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.8,
        ),
      );
    }
  }

  void _showStoreDetailsSheet(StoreModel store) {
    final deal = _storeDeals[store.id];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoreDetailsBottomSheet(
        store: store,
        deal: deal,
        userPosition: _userPositionNotifier.value,
        isDark: isDark,
        onViewStore: () {
          Navigator.pop(context);
          _navigateToStoreDetails(store);
        },
      ),
    );
  }

  void _focusStoreOnMap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    if (_mapController != null && !_isDisposed && mounted) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: store.latitude, longitude: store.longitude),
            zoom: 14,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.8,
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && !_isDisposed) {
        _showStoreDetailsSheet(store);
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

  void _toggleMapSize() {
    _isMapExpanded.value = !_isMapExpanded.value;
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Welcome, John Doe',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          LocationRefreshButton(
            onPressed: () => _getCurrentLocation(showLoading: true),
          ),
          NotificationButton(onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search Bar - Fixed
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: SearchBarWidget(
              onTap: () {
                // TODO: Navigate to search
              },
              isDark: isDark,
            ),
          ),

          // Map - Fixed with expand/collapse
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isMapExpanded,
              builder: (context, isExpanded, _) {
                final mapHeight = isExpanded
                    ? screenHeight * 0.55
                    : screenHeight * 0.35;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: mapHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Stack(
                      children: [
                        // Map
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

                        // Expand/Collapse button - Top right
                        Positioned(
                          top: 16.h,
                          right: 16.w,
                          child: MapExpandButton(
                            isExpandedNotifier: _isMapExpanded,
                            onPressed: _toggleMapSize,
                            isDark: isDark,
                          ),
                        ),

                        // Navigation button - Bottom right
                        Positioned(
                          bottom: 16.h,
                          right: 16.w,
                          child: MapNavigationButton(
                            isLoadingNotifier: _isLoadingLocation,
                            onPressed: () =>
                                _getCurrentLocation(showLoading: true),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16.h),

          // Scrollable sections
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hot Deals Section
                    if (_storesWithDeals.isNotEmpty) ...[
                      SectionHeader(
                        title: '🔥 Hot Deals Nearby',
                        count: _storesWithDeals.length,
                        isDark: isDark,
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 120.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _storesWithDeals.length,
                          itemBuilder: (context, index) {
                            final store = _storesWithDeals[index];
                            final deal = _storeDeals[store.id]!;

                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: DealBannerCard(
                                store: store,
                                deal: deal,
                                onTap: () => _navigateToStoreDetails(store),
                                onMapFocus: () => _focusStoreOnMap(store),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Featured Stores
                    if (_featuredStores.isNotEmpty) ...[
                      SectionHeader(
                        title: '⭐ Featured Stores',
                        count: _featuredStores.length,
                        isDark: isDark,
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 160.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _featuredStores.length,
                          itemBuilder: (context, index) {
                            final store = _featuredStores[index];
                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: FeaturedStoreCard(
                                store: store,
                                onTap: () => _navigateToStoreDetails(store),
                                onMapFocus: () => _focusStoreOnMap(store),
                                isDark: isDark,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Top Sellers
                    SectionHeader(
                      title: 'Top Sellers Near You',
                      count: _topRatedStores.length,
                      isDark: isDark,
                    ),
                    SizedBox(height: 12.h),
                    TopSellersList(
                      stores: _topRatedStores,
                      onStoreTap: _navigateToStoreDetails,
                      onMapFocus: _focusStoreOnMap,
                      isDark: isDark,
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Map Expand Button
class MapExpandButton extends StatelessWidget {
  final ValueNotifier<bool> isExpandedNotifier;
  final VoidCallback onPressed;
  final bool isDark;

  const MapExpandButton({
    required this.isExpandedNotifier,
    required this.onPressed,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isExpandedNotifier,
      builder: (context, isExpanded, _) {
        return Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12.r),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Map Navigation Button
class MapNavigationButton extends StatelessWidget {
  final ValueNotifier<bool> isLoadingNotifier;
  final VoidCallback onPressed;
  final bool isDark;

  const MapNavigationButton({
    required this.isLoadingNotifier,
    required this.onPressed,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, _) {
        return Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12.r),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: isLoading
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.navigation,
                      color: Theme.of(context).primaryColor,
                      size: 24.sp,
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Action Button Widgets
class LocationRefreshButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LocationRefreshButton({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.my_location),
      color: Theme.of(context).primaryColor,
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
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.notifications),
      color: Theme.of(context).primaryColor,
    );
  }
}

// Search Bar Widget
class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const SearchBarWidget({
    required this.onTap,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Search stores, deals, products...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.tune,
                color: Colors.grey[600],
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;

  const SectionHeader({
    required this.title,
    required this.count,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

// Deal Banner Card
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
              colors: [Colors.red, Colors.orange],
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
                        GestureDetector(
                          onTap: onMapFocus,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
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
                                '${store.distance!.toStringAsFixed(1)} km',
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

// Featured Store Card
class FeaturedStoreCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;
  final bool isDark;

  const FeaturedStoreCard({
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
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
                            color: Colors.white,
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
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '(${store.totalRatings})',
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

// Top Sellers List
class TopSellersList extends StatefulWidget {
  final List<StoreModel> stores;
  final Function(StoreModel) onStoreTap;
  final Function(StoreModel) onMapFocus;
  final bool isDark;

  const TopSellersList({
    required this.stores,
    required this.onStoreTap,
    required this.onMapFocus,
    required this.isDark,
    super.key,
  });

  @override
  State<TopSellersList> createState() => _TopSellersListState();
}

class _TopSellersListState extends State<TopSellersList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final displayCount = _showAll ? widget.stores.length : 3;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final store = widget.stores[index];
            return TopSellerItem(
              store: store,
              rank: index + 1,
              onTap: () => widget.onStoreTap(store),
              onMapFocus: () => widget.onMapFocus(store),
              isDark: widget.isDark,
            );
          },
        ),
        if (widget.stores.length > 3)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAll = !_showAll;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[100],
                padding: EdgeInsets.symmetric(vertical: 14.h),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showAll
                        ? 'Show Less'
                        : 'View All (${widget.stores.length})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    _showAll
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
    );
  }
}

// Top Seller Item
class TopSellerItem extends StatelessWidget {
  final StoreModel store;
  final int rank;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;
  final bool isDark;

  const TopSellerItem({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
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
                Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _getRankColors()),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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
                              color: Colors.black,
                            ),
                          ),
                          if (store.distance != null) ...[
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.location_on,
                              size: 12.sp,
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
                        ],
                      ),
                    ],
                  ),
                ),
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

// Store Details Bottom Sheet
class StoreDetailsBottomSheet extends StatelessWidget {
  final StoreModel store;
  final String? deal;
  final Position? userPosition;
  final bool isDark;
  final VoidCallback onViewStore;

  const StoreDetailsBottomSheet({
    required this.store,
    this.deal,
    this.userPosition,
    required this.isDark,
    required this.onViewStore,
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.all(20.w),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            if (deal != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [Colors.red, Colors.orange]),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Colors.white, size: 20.sp),
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
              SizedBox(height: 16.h),
            ],
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            '${store.rating}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '(${store.totalRatings} reviews)',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
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
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
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
                if (distance != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
            ),
            SizedBox(height: 20.h),
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
    );
  }
}