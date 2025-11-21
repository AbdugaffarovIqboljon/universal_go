import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:universal_go/core/services/map/cluster_stores_service.dart';
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

enum SortOption { distance, rating, name }

enum SheetState { collapsed, expanded }

class StoreFilterState {
  final StoreTab tab;
  final String searchQuery;
  final String? category;
  final SortOption sortOption;

  const StoreFilterState({
    required this.tab,
    required this.searchQuery,
    required this.category,
    required this.sortOption,
  });

  StoreFilterState copyWith({
    StoreTab? tab,
    String? searchQuery,
    String? category,
    SortOption? sortOption,
    bool clearCategory = false,
  }) {
    return StoreFilterState(
      tab: tab ?? this.tab,
      searchQuery: searchQuery ?? this.searchQuery,
      category: clearCategory ? null : (category ?? this.category),
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreFilterState &&
          runtimeType == other.runtimeType &&
          tab == other.tab &&
          searchQuery == other.searchQuery &&
          category == other.category &&
          sortOption == other.sortOption;

  @override
  int get hashCode =>
      tab.hashCode ^
      searchQuery.hashCode ^
      category.hashCode ^
      sortOption.hashCode;
}

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  YandexMapController? _mapController;
  bool _isDisposed = false;

  // Services
  final _clusteringService = MapClusteringService();
  StreamSubscription? _clusteringSubscription;

  // Core state
  final ValueNotifier<Position?> _userPositionNotifier =
      ValueNotifier<Position?>(null);
  final ValueNotifier<List<PlacemarkMapObject>> _placemarks =
      ValueNotifier<List<PlacemarkMapObject>>([]);
  final ValueNotifier<bool> _isLoadingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<double> _currentZoom = ValueNotifier<double>(11.5);

  // Sheet animation
  late AnimationController _sheetAnimationController;
  late Animation<double> _sheetAnimation;
  final ValueNotifier<SheetState> _sheetState =
      ValueNotifier<SheetState>(SheetState.collapsed);

  // Scroll tracking
  final ScrollController _scrollController = ScrollController();
  double _lastScrollOffset = 0.0;
  Timer? _scrollDebounce;
  bool _isAnimatingSheet = false;

  // FIXED: Overscroll tracking for collapse gesture
  double _overscrollAccumulator = 0.0;
  static const double _collapseThreshold = 40.0;

  // Filter state
  final ValueNotifier<StoreFilterState> _filterState =
      ValueNotifier<StoreFilterState>(
    const StoreFilterState(
      tab: StoreTab.all,
      searchQuery: '',
      category: null,
      sortOption: SortOption.distance,
    ),
  );

  final ValueNotifier<StoreModel?> _selectedStore = ValueNotifier(null);

  // Cached filtered stores
  List<StoreModel> _cachedFilteredStores = [];
  StoreFilterState? _lastFilterState;

  // Cluster marker cache
  final Map<int, Uint8List> _clusterMarkerCache = {};
  final Set<int> _generatingMarkers = {};

  // Current clusters
  List<StoreCluster> _currentClusters = [];

  // Zoom debouncing
  Timer? _zoomDebounceTimer;
  double _lastProcessedZoom = 11.5;

  // Sheet sizes
  static const double _collapsedSize = 0.30;
  static const double _expandedSize = 0.75;

  // Store data (keeping as is - your 25 stores)
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1526738549149-8e07eca6c147?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad9d0e9d?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400&q=80',
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
      coverImageUrl:
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 275)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '11',
      ownerId: 'owner_11',
      name: 'Gadget Hub',
      category: 'Electronics',
      address: 'Yakkasaray, Tashkent',
      latitude: 41.3056,
      longitude: 69.2408,
      rating: 4.6,
      totalRatings: 156,
      productCount: 28,
      description: 'Latest gadgets and tech accessories',
      coverImageUrl:
          'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '12',
      ownerId: 'owner_12',
      name: 'Furniture World',
      category: 'Home & Garden',
      address: 'Olmazor, Tashkent',
      latitude: 41.3305,
      longitude: 69.2201,
      rating: 4.4,
      totalRatings: 98,
      productCount: 35,
      description: 'Modern furniture for your home',
      coverImageUrl:
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 320)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '13',
      ownerId: 'owner_13',
      name: 'Style Boutique',
      category: 'Fashion',
      address: 'Chilonzor, Tashkent',
      latitude: 41.2923,
      longitude: 69.2356,
      rating: 4.7,
      totalRatings: 223,
      productCount: 48,
      description: 'Trendy fashion and accessories',
      coverImageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 450)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '14',
      ownerId: 'owner_14',
      name: 'Kitchen Essentials',
      category: 'Home & Garden',
      address: 'Mirabad, Tashkent',
      latitude: 41.3089,
      longitude: 69.2756,
      rating: 4.3,
      totalRatings: 134,
      productCount: 42,
      description: 'Everything for your kitchen',
      coverImageUrl:
          'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 280)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '15',
      ownerId: 'owner_15',
      name: 'Toy Kingdom',
      category: 'Toys & Games',
      address: 'Yunusabad, Tashkent',
      latitude: 41.3689,
      longitude: 69.2156,
      rating: 4.8,
      totalRatings: 312,
      productCount: 65,
      description: 'Toys and games for all ages',
      coverImageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 600)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '16',
      ownerId: 'owner_16',
      name: 'Health & Wellness',
      category: 'Health',
      address: 'Shayxontohur, Tashkent',
      latitude: 41.2701,
      longitude: 69.2256,
      rating: 4.6,
      totalRatings: 187,
      productCount: 38,
      description: 'Health supplements and wellness products',
      coverImageUrl:
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 340)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '17',
      ownerId: 'owner_17',
      name: 'Auto Parts Pro',
      category: 'Automotive',
      address: 'Sergeli, Tashkent',
      latitude: 41.2289,
      longitude: 69.2245,
      rating: 4.5,
      totalRatings: 145,
      productCount: 55,
      description: 'Quality auto parts and accessories',
      coverImageUrl:
          'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 390)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '18',
      ownerId: 'owner_18',
      name: 'Jewelry Palace',
      category: 'Jewelry',
      address: 'Yashnabad, Tashkent',
      latitude: 41.2798,
      longitude: 69.2398,
      rating: 4.9,
      totalRatings: 278,
      productCount: 32,
      description: 'Exquisite jewelry and watches',
      coverImageUrl:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 520)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '19',
      ownerId: 'owner_19',
      name: 'Music Store',
      category: 'Music',
      address: 'Mirobod, Tashkent',
      latitude: 41.3245,
      longitude: 69.2845,
      rating: 4.4,
      totalRatings: 112,
      productCount: 26,
      description: 'Musical instruments and equipment',
      coverImageUrl:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 240)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '20',
      ownerId: 'owner_20',
      name: 'Art Supplies Co',
      category: 'Arts & Crafts',
      address: 'Hamza, Tashkent',
      latitude: 41.3498,
      longitude: 69.2567,
      rating: 4.7,
      totalRatings: 201,
      productCount: 58,
      description: 'Art supplies and craft materials',
      coverImageUrl:
          'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 380)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '21',
      ownerId: 'owner_21',
      name: 'Coffee & Tea House',
      category: 'Food & Beverage',
      address: 'Uchtepa, Tashkent',
      latitude: 41.2834,
      longitude: 69.1998,
      rating: 4.8,
      totalRatings: 334,
      productCount: 72,
      description: 'Premium coffee and tea selection',
      coverImageUrl:
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 560)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '22',
      ownerId: 'owner_22',
      name: 'Fitness Gear',
      category: 'Sports',
      address: 'Yakkasaray, Tashkent',
      latitude: 41.3012,
      longitude: 69.2456,
      rating: 4.5,
      totalRatings: 167,
      productCount: 44,
      description: 'Fitness equipment and gear',
      coverImageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 290)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '23',
      ownerId: 'owner_23',
      name: 'Garden Center',
      category: 'Home & Garden',
      address: 'Olmazor, Tashkent',
      latitude: 41.3356,
      longitude: 69.2145,
      rating: 4.6,
      totalRatings: 189,
      productCount: 51,
      description: 'Plants, seeds, and garden tools',
      coverImageUrl:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 410)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '24',
      ownerId: 'owner_24',
      name: 'Baby Store',
      category: 'Baby & Kids',
      address: 'Chilonzor, Tashkent',
      latitude: 41.2956,
      longitude: 69.2389,
      rating: 4.7,
      totalRatings: 245,
      productCount: 68,
      description: 'Everything for babies and kids',
      coverImageUrl:
          'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 470)),
      updatedAt: DateTime.now(),
    ),
    StoreModel(
      id: '25',
      ownerId: 'owner_25',
      name: 'Office Supplies Plus',
      category: 'Office Supplies',
      address: 'Mirabad, Tashkent',
      latitude: 41.3123,
      longitude: 69.2723,
      rating: 4.3,
      totalRatings: 128,
      productCount: 37,
      description: 'Office supplies and stationery',
      coverImageUrl:
          'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&q=80',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 220)),
      updatedAt: DateTime.now(),
    ),
  ];

  final Map<String, String> _storeDeals = {
    '1': '50% OFF',
    '3': 'Flash Sale',
    '5': 'Buy 2 Get 1',
    '11': 'New Arrival',
    '15': 'Special Deal',
    '18': 'Limited Time',
  };

  List<String> get _categories {
    final cats = _stores.map((s) => s.category).toSet().toList();
    cats.sort();
    return cats;
  }

  @override
  void initState() {
    super.initState();

    _sheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _sheetAnimation = Tween<double>(
      begin: _collapsedSize,
      end: _expandedSize,
    ).animate(CurvedAnimation(
      parent: _sheetAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _scrollController.addListener(_onScroll);

    _currentZoom.value = MapClusteringHelper.tashkentInitialZoom;
    _lastProcessedZoom = MapClusteringHelper.tashkentInitialZoom;

    _initializeClustering();
    _generateEssentialClusterMarkers();
    _updateFilteredStores(_filterState.value);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_isDisposed) {
        _getCurrentLocation();
      }
    });
  }

  void _onScroll() {
    if (_isDisposed || _isAnimatingSheet) return;

    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 50), () {
      if (_isDisposed) return;

      final currentOffset = _scrollController.offset;
      final delta = currentOffset - _lastScrollOffset;

      if (delta.abs() < 30) {
        _lastScrollOffset = currentOffset;
        return;
      }

      // Expand when scrolling down in content
      if (delta > 0 && _sheetState.value == SheetState.collapsed) {
        if (currentOffset > 60) {
          _animateSheetTo(SheetState.expanded);
        }
      }

      _lastScrollOffset = currentOffset;
    });
  }

  void _animateSheetTo(SheetState newState, {bool force = false}) {
    // Allow force to override animation lock
    if (!force && (_isAnimatingSheet || _sheetState.value == newState)) return;

    _isAnimatingSheet = true;
    _sheetState.value = newState;

    if (newState == SheetState.expanded) {
      _sheetAnimationController.forward().then((_) {
        _isAnimatingSheet = false;
      });
    } else {
      _sheetAnimationController.reverse().then((_) {
        _isAnimatingSheet = false;
      });
    }
  }

  void _toggleSheet() {
    final newState = _sheetState.value == SheetState.collapsed
        ? SheetState.expanded
        : SheetState.collapsed;
    _animateSheetTo(newState);
  }

  // FIXED: Handle scroll notifications for collapse gesture
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isDisposed || _isAnimatingSheet) return false;

    // Only handle when sheet is expanded
    if (_sheetState.value != SheetState.expanded) {
      _overscrollAccumulator = 0.0;
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;

      // Check if we're at the top (scroll position is 0 or very close)
      if (metrics.pixels <= 0) {
        // User is trying to scroll up when already at top
        if (notification.scrollDelta != null && notification.scrollDelta! < 0) {
          _overscrollAccumulator += notification.scrollDelta!.abs();

          // Collapse if threshold reached
          if (_overscrollAccumulator >= _collapseThreshold) {
            _overscrollAccumulator = 0.0;
            _animateSheetTo(SheetState.collapsed);
            return true;
          }
        }
      } else {
        // Reset accumulator if scrolled away from top
        _overscrollAccumulator = 0.0;
      }
    } else if (notification is ScrollEndNotification) {
      // Reset accumulator when scroll ends
      _overscrollAccumulator = 0.0;
    } else if (notification is OverscrollNotification) {
      // Handle overscroll (iOS bounce effect)
      if (notification.overscroll < 0) {
        _overscrollAccumulator += notification.overscroll.abs();

        if (_overscrollAccumulator >= _collapseThreshold) {
          _overscrollAccumulator = 0.0;
          _animateSheetTo(SheetState.collapsed);
          return true;
        }
      }
    }

    return false;
  }

  Future<void> _initializeClustering() async {
    await _clusteringService.initialize();
    _performClustering(_currentZoom.value);
  }

  Future<void> _performClustering(double zoom) async {
    final clusters = await _clusteringService.clusterStores(
      stores: _stores,
      zoom: zoom,
    );

    if (!_isDisposed && mounted) {
      _currentClusters = clusters;
      _addShopMarkers();
    }
  }

  Future<void> _generateEssentialClusterMarkers() async {
    const essentialSizes = [2, 3, 4, 5, 8, 10, 15, 20, 25, 30, 40, 50, 100];

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

    final double size =
        count > 100 ? 75.0 : (count > 50 ? 70.0 : (count > 10 ? 65.0 : 60.0));
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(0, 2), radius, shadowPaint);

    final paint = Paint()
      ..color = const Color(0xFF6B4EFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, borderPaint);

    final fontSize =
        count > 999 ? 18.0 : (count > 99 ? 20.0 : (count > 9 ? 23.0 : 26.0));
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
    _scrollDebounce?.cancel();
    _clusteringSubscription?.cancel();
    _clusteringService.dispose();
    _clusterMarkerCache.clear();
    _generatingMarkers.clear();
    _userPositionNotifier.dispose();
    _placemarks.dispose();
    _isLoadingLocation.dispose();
    _filterState.dispose();
    _selectedStore.dispose();
    _sheetState.dispose();
    _sheetAnimationController.dispose();
    _scrollController.dispose();
    _currentZoom.dispose();
    _mapController?.dispose();
    MapClusteringHelper.clearCache();
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
          _moveToTashkentCenter();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _moveToTashkentCenter();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      if (!mounted || _isDisposed) return;

      _userPositionNotifier.value = position;
      _calculateDistances(position);

      if (_mapController != null && !_isDisposed && mounted) {
        final distanceFromTashkent = _calculateDistance(
          position.latitude,
          position.longitude,
          MapClusteringHelper.tashkentCenterLat,
          MapClusteringHelper.tashkentCenterLon,
        );

        final Point target;
        final double zoom;

        if (distanceFromTashkent < 25) {
          target =
              Point(latitude: position.latitude, longitude: position.longitude);
          zoom = 12.0;
        } else {
          target = const Point(
            latitude: MapClusteringHelper.tashkentCenterLat,
            longitude: MapClusteringHelper.tashkentCenterLon,
          );
          zoom = MapClusteringHelper.tashkentInitialZoom;
        }

        await _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: target, zoom: zoom)),
          animation:
              const MapAnimation(type: MapAnimationType.smooth, duration: 0.6),
        );
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
        animation:
            const MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
      );
    }
  }

  void _onMapCreated(YandexMapController controller) {
    if (_isDisposed) return;
    _mapController = controller;
    _mapController!.toggleUserLayer(visible: true);

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
  }

  void _onMapTap() {
    if (_selectedStore.value != null) {
      _closeStoreCard();
    } else if (_sheetState.value == SheetState.expanded) {
      _animateSheetTo(SheetState.collapsed);
    }
  }

  void _onZoomChanged(double newZoom) {
    _currentZoom.value = newZoom;

    _zoomDebounceTimer?.cancel();
    _zoomDebounceTimer = Timer(const Duration(milliseconds: 250), () {
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

    const boundaries = [10.5, 11.5, 12.0, 12.5];
    for (final boundary in boundaries) {
      final wasBelow = oldZoom < boundary;
      final isBelow = newZoom < boundary;
      if (wasBelow != isBelow) return true;
    }

    return (newZoom - oldZoom).abs() > 0.8;
  }

  void _addShopMarkers() {
    if (_isDisposed) return;

    final placemarks = <PlacemarkMapObject>[];

    final userPosition = _userPositionNotifier.value;
    if (userPosition != null) {
      placemarks.add(
        PlacemarkMapObject(
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
        ),
      );
    }

    final selectedStore = _selectedStore.value;
    final showIndividual =
        MapClusteringHelper.shouldShowIndividualStores(_currentZoom.value);

    for (final cluster in _currentClusters) {
      if (showIndividual && cluster.count == 1) {
        final store = cluster.stores.first;
        final isSelected = selectedStore?.id == store.id;
        final hasDeal = _storeDeals.containsKey(store.id);

        final iconAsset = isSelected
            ? 'assets/icons/ic_active_marker.png'
            : (hasDeal
                ? 'assets/icons/ic_store_deal_marker.png'
                : 'assets/icons/ic_store_marker.png');

        placemarks.add(
          PlacemarkMapObject(
            mapId: MapObjectId('store_${store.id}'),
            point: Point(latitude: store.latitude, longitude: store.longitude),
            opacity: 1.0,
            consumeTapEvents: true,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(iconAsset),
                scale: hasDeal ? 0.26 : 0.22,
                anchor: const Offset(0.5, 1.0),
                rotationType: RotationType.noRotation,
              ),
            ),
            onTap: (_, __) => _onMarkerTap(store),
          ),
        );
      } else {
        _getOrCreateClusterMarker(cluster.count).then((markerBytes) {
          if (_isDisposed || !mounted) return;

          final updatedPlacemarks =
              List<PlacemarkMapObject>.from(_placemarks.value);
          updatedPlacemarks.add(
            PlacemarkMapObject(
              mapId: MapObjectId('cluster_${cluster.id}'),
              point: Point(
                  latitude: cluster.latitude, longitude: cluster.longitude),
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

  void _focusStoreOnMap(StoreModel store) {
    if (_isDisposed || !mounted) return;

    // Immediately reset scroll to top for proper collapsed view
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    // Reset overscroll accumulator
    _overscrollAccumulator = 0.0;

    // Select the store
    _selectedStore.value = store;
    _addShopMarkers();

    // Force collapse the sheet even if it's animating
    _animateSheetTo(SheetState.collapsed, force: true);

    // Delay map focus slightly to ensure sheet collapse animation starts
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_mapController != null && !_isDisposed && mounted) {
        final offsetLatitude = store.latitude + 0.0005;
        _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  Point(latitude: offsetLatitude, longitude: store.longitude),
              zoom: 16.5,
            ),
          ),
          animation:
              const MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
        );
      }
    });
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

  void _closeStoreCard() {
    if (_isDisposed || !mounted) return;
    _selectedStore.value = null;
    _addShopMarkers();
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

    _updateFilteredStores(_filterState.value);

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

  void _navigateToStoreDetails(StoreModel store) {
    Navigator.pushNamed(context, AppRoutes.storeDetails, arguments: store);
  }

  void _navigateToFullMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerMapFullPage(
          stores: _stores,
          storeDeals: _storeDeals,
          userPosition: _userPositionNotifier.value,
          onStoreSelected: _navigateToStoreDetails,
        ),
      ),
    );
  }

  void _updateFilteredStores(StoreFilterState state) {
    if (_lastFilterState == state) return;

    List<StoreModel> filtered = List.from(_stores);

    switch (state.tab) {
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

    if (state.searchQuery.isNotEmpty) {
      final lowerQuery = state.searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(lowerQuery) ||
            s.category.toLowerCase().contains(lowerQuery) ||
            s.address.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (state.category != null) {
      filtered = filtered.where((s) => s.category == state.category).toList();
    }

    switch (state.sortOption) {
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

    _cachedFilteredStores = filtered;
    _lastFilterState = state;
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final appBarHeight = 56.h;
    final buttonTopPosition = safeAreaTop + appBarHeight + 24.h;
    final screenHeight = MediaQuery.of(context).size.height;

    final sheetTopMargin = safeAreaTop + appBarHeight + 20.h;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          RepaintBoundary(
            child: ValueListenableBuilder<List<PlacemarkMapObject>>(
              valueListenable: _placemarks,
              builder: (context, placemarks, _) {
                return GestureDetector(
                  onTap: _onMapTap,
                  child: YandexMap(
                    onMapCreated: _onMapCreated,
                    mapType: MapType.map,
                    mapObjects: placemarks,
                    onCameraPositionChanged:
                        (cameraPosition, reason, finished) {
                      _onZoomChanged(cameraPosition.zoom);
                      if (reason == CameraUpdateReason.gestures &&
                          _selectedStore.value != null) {
                        _closeStoreCard();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GradientAppBar(
              title: 'Welcome, John Doe',
              showBackButton: false,
              actions: [NotificationButton()],
            ),
          ),

          Positioned(
            top: buttonTopPosition,
            right: 12.w,
            child: Column(
              spacing: 12.h,
              children: [
                MapActionButton(
                  onPressed: () => _getCurrentLocation(showLoading: true),
                  icon: Image.asset(
                    'assets/icons/ic_navigate.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
                MapActionButton(
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

          ValueListenableBuilder<StoreModel?>(
            valueListenable: _selectedStore,
            builder: (context, selectedStore, _) {
              if (selectedStore == null) return const SizedBox.shrink();
              return FloatingStoreInfoCard(
                store: selectedStore,
                userPosition: _userPositionNotifier.value,
                onClose: _closeStoreCard,
                onViewStore: () => _navigateToStoreDetails(selectedStore),
              );
            },
          ),

          // FIXED: Sheet with NotificationListener for pull-to-collapse
          AnimatedBuilder(
            animation: _sheetAnimation,
            builder: (context, child) {
              final maxSheetHeight = screenHeight - sheetTopMargin;
              final sheetHeight = maxSheetHeight * _sheetAnimation.value;

              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: sheetHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _handleScrollNotification,
                    child: ValueListenableBuilder<StoreFilterState>(
                      valueListenable: _filterState,
                      builder: (context, filterState, _) {
                        _updateFilteredStores(filterState);

                        return OptimizedStoreListView(
                          scrollController: _scrollController,
                          filterState: filterState,
                          filteredStores: _cachedFilteredStores,
                          storeDeals: _storeDeals,
                          categories: _categories,
                          onFilterChanged: (newState) =>
                              _filterState.value = newState,
                          onStoreSelected: _navigateToStoreDetails,
                          onStoreFocused: _focusStoreOnMap,
                          onHandleTap: _toggleSheet,
                        );
                      },
                    ),
                  ),
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
// OPTIMIZED STORE LIST VIEW (Keep exactly the same)
// ============================================================================

class OptimizedStoreListView extends StatelessWidget {
  final ScrollController scrollController;
  final StoreFilterState filterState;
  final List<StoreModel> filteredStores;
  final Map<String, String> storeDeals;
  final List<String> categories;
  final ValueChanged<StoreFilterState> onFilterChanged;
  final ValueChanged<StoreModel> onStoreSelected;
  final ValueChanged<StoreModel> onStoreFocused;
  final VoidCallback onHandleTap;

  const OptimizedStoreListView({
    required this.scrollController,
    required this.filterState,
    required this.filteredStores,
    required this.storeDeals,
    required this.categories,
    required this.onFilterChanged,
    required this.onStoreSelected,
    required this.onStoreFocused,
    required this.onHandleTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GestureDetector(
            onTap: onHandleTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SegmentedControlWidget(
              selectedTab: filterState.tab,
              onTabChanged: (tab) {
                onFilterChanged(filterState.copyWith(tab: tab));
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: CategoryChipsWidget(
                    categories: categories,
                    selectedCategory: filterState.category,
                    onCategoryChanged: (category) {
                      onFilterChanged(filterState.copyWith(
                        category: category,
                        clearCategory: category == null,
                      ));
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                SortButton(
                  currentSort: filterState.sortOption,
                  onSortChanged: (sort) {
                    onFilterChanged(filterState.copyWith(sortOption: sort));
                  },
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        if (filteredStores.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              tab: filterState.tab,
              hasSearch: filterState.searchQuery.isNotEmpty ||
                  filterState.category != null,
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final store = filteredStores[index];
                  return KeepAliveStoreCard(
                    key: ValueKey('store_${store.id}'),
                    store: store,
                    deal: storeDeals[store.id],
                    onTap: () => onStoreSelected(store),
                    onMapFocus: () => onStoreFocused(store),
                  );
                },
                childCount: filteredStores.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
              ),
            ),
          )
      ],
    );
  }
}

// ============================================================================
// ALL OTHER WIDGETS REMAIN EXACTLY THE SAME
// ============================================================================

class KeepAliveStoreCard extends StatefulWidget {
  final StoreModel store;
  final String? deal;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;

  const KeepAliveStoreCard({
    required this.store,
    this.deal,
    required this.onTap,
    required this.onMapFocus,
    super.key,
  });

  @override
  State<KeepAliveStoreCard> createState() => _KeepAliveStoreCardState();
}

class _KeepAliveStoreCardState extends State<KeepAliveStoreCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RepaintBoundary(
      child: StoreGridCard(
        store: widget.store,
        deal: widget.deal,
        onTap: widget.onTap,
        onMapFocus: widget.onMapFocus,
      ),
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.notifications, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
      ),
    );
  }
}

class MapActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const MapActionButton({
    required this.onPressed,
    required this.icon,
    super.key,
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
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: icon,
      ),
    );
  }
}

class SegmentedControlWidget extends StatelessWidget {
  final StoreTab selectedTab;
  final ValueChanged<StoreTab> onTabChanged;

  const SegmentedControlWidget({
    required this.selectedTab,
    required this.onTabChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: () => onTabChanged(StoreTab.all),
          ),
          TabButton(
            label: 'Deals',
            isSelected: selectedTab == StoreTab.deals,
            onTap: () => onTabChanged(StoreTab.deals),
          ),
          TabButton(
            label: 'Featured',
            isSelected: selectedTab == StoreTab.featured,
            onTap: () => onTabChanged(StoreTab.featured),
          ),
          TabButton(
            label: 'Nearby',
            isSelected: selectedTab == StoreTab.nearby,
            onTap: () => onTabChanged(StoreTab.nearby),
          ),
        ],
      ),
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
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
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
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const CategoryChipsWidget({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              onTap: () => onCategoryChanged(isSelected ? null : category),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
  }
}

class SortButton extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortChanged;

  const SortButton({
    required this.currentSort,
    required this.onSortChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Icon(Icons.sort,
            size: 18.sp, color: Theme.of(context).primaryColor),
      ),
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
            Text('Sort By',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            SortOptionTile(
              label: 'Distance',
              icon: Icons.location_on,
              isSelected: currentSort == SortOption.distance,
              onTap: () {
                onSortChanged(SortOption.distance);
                Navigator.pop(context);
              },
            ),
            SortOptionTile(
              label: 'Rating',
              icon: Icons.star,
              isSelected: currentSort == SortOption.rating,
              onTap: () {
                onSortChanged(SortOption.rating);
                Navigator.pop(context);
              },
            ),
            SortOptionTile(
              label: 'Name (A-Z)',
              icon: Icons.sort_by_alpha,
              isSelected: currentSort == SortOption.name,
              onTap: () {
                onSortChanged(SortOption.name);
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

class StoreGridCard extends StatelessWidget {
  final StoreModel store;
  final String? deal;
  final VoidCallback onTap;
  final VoidCallback onMapFocus;

  const StoreGridCard({
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
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
                  OptimizedStoreImage(
                    imageUrl: store.coverImageUrl,
                    size: double.infinity,
                    height: 100,
                    borderRadius: 16,
                    topOnly: true,
                  ),
                  if (deal != null)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: DealBadge(deal: deal!),
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
                                fontSize: 11.sp, color: Colors.grey[600]),
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
                                Icon(Icons.location_on,
                                    size: 13.sp, color: Colors.grey[600]),
                                SizedBox(width: 2.w),
                                Flexible(
                                  child: Text(
                                    '${store.distance!.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey[600]),
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

class OptimizedStoreImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double? height;
  final double borderRadius;
  final bool topOnly;

  const OptimizedStoreImage({
    required this.imageUrl,
    required this.size,
    this.height,
    required this.borderRadius,
    this.topOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = topOnly
        ? BorderRadius.vertical(top: Radius.circular(borderRadius.r))
        : BorderRadius.circular(borderRadius.r);

    return ClipRRect(
      borderRadius: radius,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: size == double.infinity ? double.infinity : size.w,
              height: (height ?? size).h,
              fit: BoxFit.cover,
              memCacheWidth: 150,
              memCacheHeight: 150,
              maxHeightDiskCache: 150,
              maxWidthDiskCache: 150,
              placeholder: (context, url) => Container(color: Colors.grey[100]),
              errorWidget: (context, url, error) => _buildPlaceholder(context),
              fadeInDuration: const Duration(milliseconds: 100),
              fadeOutDuration: const Duration(milliseconds: 50),
            )
          : _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: size == double.infinity ? double.infinity : size.w,
      height: (height ?? size).h,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
      child: Icon(
        Icons.storefront,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
        size: (size == double.infinity ? 40 : size * 0.4).sp,
      ),
    );
  }
}

class DealBadge extends StatelessWidget {
  final String deal;

  const DealBadge({required this.deal, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.red, Colors.orange]),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        deal,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15.sp, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }
}
