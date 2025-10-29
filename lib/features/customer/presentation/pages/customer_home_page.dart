import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:universal_go/features/customer/data/models/store_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_go/core/navigation/app_routes.dart';
import 'dart:math' as math;

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  YandexMapController? _mapController;
  final ValueNotifier<Position?> _userPositionNotifier = ValueNotifier<Position?>(null);
  final ValueNotifier<List<PlacemarkMapObject>> _placemarks = ValueNotifier<List<PlacemarkMapObject>>([]);
  final ValueNotifier<StoreModel?> _selectedStoreNotifier = ValueNotifier<StoreModel?>(null);
  
  // Mock data - replace with actual data from repository/bloc
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
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
        desiredAccuracy: LocationAccuracy.high,
      );

      _userPositionNotifier.value = position;

      if (_mapController != null) {
        await _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(latitude: position.latitude, longitude: position.longitude),
              zoom: 12,
            ),
          ),
          animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.5),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _moveToDefaultLocation();
    }
  }

  void _moveToDefaultLocation() {
    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: Point(latitude: 41.2995, longitude: 69.2401),
          zoom: 12,
        ),
      ),
    );
  }

  void _onMapCreated(YandexMapController controller) {
    _mapController = controller;
    _addShopMarkers();
  }

  void _addShopMarkers() {
    final placemarks = <PlacemarkMapObject>[];
    
    for (final store in _stores) {
      final placemark = PlacemarkMapObject(
        mapId: MapObjectId('store_${store.id}'),
        point: Point(latitude: store.latitude, longitude: store.longitude),
        opacity: 1.0,
        consumeTapEvents: true,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/icons/ic_store_marker.png'),
            scale: 0.35,
            anchor: const Offset(0.5, 1.0),
            rotationType: RotationType.noRotation,
          ),
        ),
        onTap: (PlacemarkMapObject self, Point point) {
          debugPrint('Marker tapped: ${store.name}');
          _onMarkerTap(store);
        },
      );
      placemarks.add(placemark);
    }
    
    _placemarks.value = placemarks;
  }

  void _onMarkerTap(StoreModel store) {
    debugPrint('_onMarkerTap called for: ${store.name}');
    
    _selectedStoreNotifier.value = store;
    
    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: store.latitude, longitude: store.longitude),
          zoom: 14,
        ),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.8),
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  List<StoreModel> _getNearbyStores([double radiusKm = 10.0]) {
    final position = _userPositionNotifier.value;
    if (position == null) return _stores;

    final nearby = <StoreModel>[];
    for (final store in _stores) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        store.latitude,
        store.longitude,
      );
      if (distance <= radiusKm) {
        nearby.add(store.copyWith(distance: distance));
      }
    }

    nearby.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    return nearby;
  }

  void _closeInfoCard() {
    _selectedStoreNotifier.value = null;
  }

  void _navigateToStoreDetails(StoreModel store) {
    Navigator.pushNamed(
      context,
      AppRoutes.storeDetails,
      arguments: store,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Stores'),
        actions: [
          MyLocationButton(onPressed: _getCurrentLocation),
          const NotificationButton(),
        ],
      ),
      body: Stack(
        children: [
          // Map with markers
          ValueListenableBuilder<List<PlacemarkMapObject>>(
            valueListenable: _placemarks,
            builder: (context, placemarks, _) {
              return YandexMap(
                onMapCreated: _onMapCreated,
                mapType: MapType.map,
                mapObjects: placemarks,
                onMapTap: (Point point) {
                  debugPrint('Map tapped, closing info card');
                  _closeInfoCard();
                },
              );
            },
          ),
          
          // Search bar overlay
          const SearchBarOverlay(),
          
          // Store info card overlay (bottom)
          ValueListenableBuilder<StoreModel?>(
            valueListenable: _selectedStoreNotifier,
            builder: (context, selectedStore, _) {
              debugPrint('Info card builder - selectedStore: $selectedStore');
              if (selectedStore == null) return const SizedBox.shrink();
              
              return StoreInfoCard(
                store: selectedStore,
                onClose: _closeInfoCard,
                onViewStore: () => _navigateToStoreDetails(selectedStore),
                userPosition: _userPositionNotifier.value,
              );
            },
          ),
        ],
      ),
      floatingActionButton: NearbyShopsFAB(
        onPressed: () => _showNearbyStores(),
      ),
    );
  }

  void _showNearbyStores() {
    final nearbyStores = _getNearbyStores();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => NearbyStoresSheet(
        stores: nearbyStores,
        onStoreTap: (store) {
          Navigator.pop(context);
          _navigateToStoreDetails(store);
        },
      ),
    );
  }

  @override
  void dispose() {
    _userPositionNotifier.dispose();
    _placemarks.dispose();
    _selectedStoreNotifier.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}

// Reusable Widgets

class MyLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MyLocationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.my_location),
      onPressed: onPressed,
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_outlined),
      onPressed: () {
        // TODO: Navigate to notifications
      },
    );
  }
}

class SearchBarOverlay extends StatelessWidget {
  const SearchBarOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search stores...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ),
    );
  }
}

class StoreInfoCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onClose;
  final VoidCallback onViewStore;
  final Position? userPosition;

  const StoreInfoCard({
    super.key,
    required this.store,
    required this.onClose,
    required this.onViewStore,
    this.userPosition,
  });

  double? _calculateDistance() {
    if (userPosition == null) return null;
    
    const double earthRadius = 6371;
    final dLat = _toRadians(store.latitude - userPosition!.latitude);
    final dLon = _toRadians(store.longitude - userPosition!.longitude);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(userPosition!.latitude)) * 
        math.cos(_toRadians(store.latitude)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final distance = store.distance ?? _calculateDistance();
    
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 100.h,
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
          color: Theme.of(context).colorScheme.surface,
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Store icon
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.storefront,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    
                    // Store info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            store.category,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Close button
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      iconSize: 20.sp,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                SizedBox(height: 12.h),
                
                // Address with icon
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        store.address,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                // Stats row
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '${store.rating}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 8.w),
                    
                    // Products count
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${store.productCount} products',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    // Distance (if available)
                    if (distance != null) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_walk,
                              size: 12.sp,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // View Store button
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
                      'View Store',
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

class NearbyShopsFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const NearbyShopsFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: 'Show Nearby Shops',
      icon: const Icon(Icons.store),
      label: const Text('Nearby'),
    );
  }
}

class NearbyStoresSheet extends StatelessWidget {
  final List<StoreModel> stores;
  final void Function(StoreModel) onStoreTap;

  const NearbyStoresSheet({
    super.key,
    required this.stores,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          Text(
            'Nearby Shops',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          Expanded(
            child: stores.isEmpty
                ? const Center(child: Text('No nearby shops found'))
                : ListView.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      return StoreListTile(
                        store: store,
                        onTap: () => onStoreTap(store),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class StoreListTile extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const StoreListTile({
    super.key,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.storefront,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(store.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.address),
            if (store.distance != null) ...[
              SizedBox(height: 4.h),
              Text(
                '${store.distance!.toStringAsFixed(1)} km away',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16.sp),
            SizedBox(width: 4.w),
            Text('${store.rating}'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}