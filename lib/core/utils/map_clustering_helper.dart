import 'dart:math' as math;
import 'package:universal_go/features/customer/data/models/map_store_cluster.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';

class MapClusteringHelper {
  static const double tashkentCenterLat = 41.2995;
  static const double tashkentCenterLon = 69.2401;
  static const double tashkentInitialZoom = 11.5;
  
  // FIXED: Lower threshold - shows individual stores earlier
  static const double individualStoreThreshold = 12.5;

  // Viewport-based clustering params
  static const double viewportPadding = 0.15; // 15% padding around viewport

  // Memoization for bounds calculation
  static int? _cachedStoresHash;

  // Quadtree cache for spatial indexing
  static _Quadtree? _cachedQuadtree;

  static bool shouldShowIndividualStores(double zoom) {
    return zoom >= individualStoreThreshold;
  }

  /// Main clustering entry point with viewport optimization
  static List<StoreCluster> clusterStores(
    List<StoreModel> stores,
    double currentZoom, {
    ViewportBounds? viewport,
  }) {
    if (stores.isEmpty) return [];

    // Filter stores by viewport if provided (huge performance gain for large datasets)
    final visibleStores = viewport != null
        ? _filterStoresByViewport(stores, viewport)
        : stores;

    if (visibleStores.isEmpty) return [];

    // Individual mode for high zoom
    if (shouldShowIndividualStores(currentZoom)) {
      return _createIndividualClusters(visibleStores);
    }

    // Single cluster for very low zoom
    if (currentZoom <= 10.5) {
      return _createSingleCluster(visibleStores);
    }

    // Adaptive grid-based clustering for medium zoom
    final gridSize = _calculateOptimalGridSize(currentZoom);
    return _createGridBasedClusters(visibleStores, gridSize);
  }

  /// Filter stores within viewport bounds (with padding)
  static List<StoreModel> _filterStoresByViewport(
    List<StoreModel> stores,
    ViewportBounds viewport,
  ) {
    // Add padding to viewport
    final latPadding = (viewport.maxLat - viewport.minLat) * viewportPadding;
    final lonPadding = (viewport.maxLon - viewport.minLon) * viewportPadding;

    final paddedMinLat = viewport.minLat - latPadding;
    final paddedMaxLat = viewport.maxLat + latPadding;
    final paddedMinLon = viewport.minLon - lonPadding;
    final paddedMaxLon = viewport.maxLon + lonPadding;

    // Use quadtree for efficient spatial queries on large datasets
    if (stores.length > 100) {
      final quadtree = _getOrBuildQuadtree(stores);
      return quadtree.queryRange(
        paddedMinLat,
        paddedMaxLat,
        paddedMinLon,
        paddedMaxLon,
      );
    }

    // Direct filtering for small datasets
    return stores.where((store) {
      return store.latitude >= paddedMinLat &&
          store.latitude <= paddedMaxLat &&
          store.longitude >= paddedMinLon &&
          store.longitude <= paddedMaxLon;
    }).toList();
  }

  /// Get or build quadtree for spatial indexing
  static _Quadtree _getOrBuildQuadtree(List<StoreModel> stores) {
    final storesHash = Object.hashAll(stores.map((s) => s.id));
    
    if (_cachedQuadtree != null && _cachedStoresHash == storesHash) {
      return _cachedQuadtree!;
    }

    // Build new quadtree
    final bounds = _calculateBounds(stores);
    _cachedQuadtree = _Quadtree(
      bounds.minLat,
      bounds.maxLat,
      bounds.minLon,
      bounds.maxLon,
      capacity: 10,
    );

    for (final store in stores) {
      _cachedQuadtree!.insert(store);
    }

    return _cachedQuadtree!;
  }

  /// Calculate optimal grid size based on zoom
  static int _calculateOptimalGridSize(double zoom) {
    if (zoom < 11.0) return 2;
    if (zoom < 11.5) return 3;
    if (zoom < 12.0) return 4;
    return 5; // Finer grid for higher zoom
  }

  static List<StoreCluster> _createIndividualClusters(List<StoreModel> stores) {
    return List.generate(
      stores.length,
      (i) => StoreCluster(
        id: 'single_${stores[i].id}',
        latitude: stores[i].latitude,
        longitude: stores[i].longitude,
        stores: [stores[i]],
        count: 1,
      ),
      growable: false,
    );
  }

  static List<StoreCluster> _createSingleCluster(List<StoreModel> stores) {
    final centerPoint = _calculateCenterPoint(stores);
    return [
      StoreCluster(
        id: 'cluster_all',
        latitude: centerPoint.$1,
        longitude: centerPoint.$2,
        stores: stores,
        count: stores.length,
      ),
    ];
  }

  static List<StoreCluster> _createGridBasedClusters(
    List<StoreModel> stores,
    int gridSize,
  ) {
    if (stores.isEmpty) return [];

    final bounds = _calculateBounds(stores);

    final latCellSize = (bounds.maxLat - bounds.minLat) / gridSize;
    final lonCellSize = (bounds.maxLon - bounds.minLon) / gridSize;

    // Pre-allocate map for better performance
    final cellGroups = <String, List<StoreModel>>{};

    // Group stores by grid cell
    for (final store in stores) {
      final cellRow = ((store.latitude - bounds.minLat) / latCellSize)
          .floor()
          .clamp(0, gridSize - 1);
      final cellCol = ((store.longitude - bounds.minLon) / lonCellSize)
          .floor()
          .clamp(0, gridSize - 1);
      final cellKey = '$cellRow,$cellCol';

      (cellGroups[cellKey] ??= []).add(store);
    }

    // Create clusters from non-empty cells
    return cellGroups.entries.map((entry) {
      final cellStores = entry.value;
      final centerPoint = _calculateCenterPoint(cellStores);

      return StoreCluster(
        id: 'cluster_${entry.key}',
        latitude: centerPoint.$1,
        longitude: centerPoint.$2,
        stores: cellStores,
        count: cellStores.length,
      );
    }).toList(growable: false);
  }

  static _StoreBounds _calculateBounds(List<StoreModel> stores) {
    double minLat = stores.first.latitude;
    double maxLat = stores.first.latitude;
    double minLon = stores.first.longitude;
    double maxLon = stores.first.longitude;

    for (final store in stores) {
      if (store.latitude < minLat) minLat = store.latitude;
      if (store.latitude > maxLat) maxLat = store.latitude;
      if (store.longitude < minLon) minLon = store.longitude;
      if (store.longitude > maxLon) maxLon = store.longitude;
    }

    // Add padding
    final latPadding = (maxLat - minLat) * 0.1;
    final lonPadding = (maxLon - minLon) * 0.1;

    return _StoreBounds(
      minLat: minLat - latPadding,
      maxLat: maxLat + latPadding,
      minLon: minLon - lonPadding,
      maxLon: maxLon + lonPadding,
    );
  }

  static (double, double) _calculateCenterPoint(List<StoreModel> stores) {
    if (stores.isEmpty) return (tashkentCenterLat, tashkentCenterLon);

    double sumLat = 0.0;
    double sumLon = 0.0;

    for (final store in stores) {
      sumLat += store.latitude;
      sumLon += store.longitude;
    }

    return (sumLat / stores.length, sumLon / stores.length);
  }

  static double calculateDistance(
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

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  /// Clear all caches (call when stores list changes)
  static void clearCache() {
    _cachedStoresHash = null;
    _cachedQuadtree = null;
  }
}

class _StoreBounds {
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;

  const _StoreBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });
}

class ViewportBounds {
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;

  const ViewportBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });
}

/// Quadtree for efficient spatial indexing (O(log n) queries)
class _Quadtree {
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;
  final int capacity;

  final List<StoreModel> _stores = [];
  bool _divided = false;

  _Quadtree? _northeast;
  _Quadtree? _northwest;
  _Quadtree? _southeast;
  _Quadtree? _southwest;

  _Quadtree(
    this.minLat,
    this.maxLat,
    this.minLon,
    this.maxLon, {
    this.capacity = 10,
  });

  bool insert(StoreModel store) {
    // Check if store is within bounds
    if (store.latitude < minLat ||
        store.latitude > maxLat ||
        store.longitude < minLon ||
        store.longitude > maxLon) {
      return false;
    }

    // If capacity not reached, add to this node
    if (_stores.length < capacity && !_divided) {
      _stores.add(store);
      return true;
    }

    // Subdivide if not already divided
    if (!_divided) {
      _subdivide();
    }

    // Insert into appropriate quadrant
    if (_northeast!.insert(store)) return true;
    if (_northwest!.insert(store)) return true;
    if (_southeast!.insert(store)) return true;
    if (_southwest!.insert(store)) return true;

    return false;
  }

  void _subdivide() {
    final midLat = (minLat + maxLat) / 2;
    final midLon = (minLon + maxLon) / 2;

    _northeast = _Quadtree(midLat, maxLat, midLon, maxLon, capacity: capacity);
    _northwest = _Quadtree(midLat, maxLat, minLon, midLon, capacity: capacity);
    _southeast = _Quadtree(minLat, midLat, midLon, maxLon, capacity: capacity);
    _southwest = _Quadtree(minLat, midLat, minLon, midLon, capacity: capacity);

    // Redistribute existing stores
    for (final store in _stores) {
      _northeast!.insert(store) ||
          _northwest!.insert(store) ||
          _southeast!.insert(store) ||
          _southwest!.insert(store);
    }
    _stores.clear();
    _divided = true;
  }

  List<StoreModel> queryRange(
    double qMinLat,
    double qMaxLat,
    double qMinLon,
    double qMaxLon,
  ) {
    final result = <StoreModel>[];

    // If no intersection, return empty
    if (qMaxLat < minLat ||
        qMinLat > maxLat ||
        qMaxLon < minLon ||
        qMinLon > maxLon) {
      return result;
    }

    // Add stores from this node
    for (final store in _stores) {
      if (store.latitude >= qMinLat &&
          store.latitude <= qMaxLat &&
          store.longitude >= qMinLon &&
          store.longitude <= qMaxLon) {
        result.add(store);
      }
    }

    // Query subdivisions if divided
    if (_divided) {
      result.addAll(_northeast!.queryRange(qMinLat, qMaxLat, qMinLon, qMaxLon));
      result.addAll(_northwest!.queryRange(qMinLat, qMaxLat, qMinLon, qMaxLon));
      result.addAll(_southeast!.queryRange(qMinLat, qMaxLat, qMinLon, qMaxLon));
      result.addAll(_southwest!.queryRange(qMinLat, qMaxLat, qMinLon, qMaxLon));
    }

    return result;
  }
}