import 'dart:async';
import 'dart:isolate';
import 'package:universal_go/features/customer/data/models/map_store_cluster.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';
import 'package:universal_go/core/utils/map_clustering_helper.dart';

class _ClusterRequest {
  final List<StoreModel> stores;
  final double zoom;
  final SendPort sendPort;

  _ClusterRequest({
    required this.stores,
    required this.zoom,
    required this.sendPort,
  });
}

class _ClusterResult {
  final List<StoreCluster> clusters;
  final double zoom;

  _ClusterResult({required this.clusters, required this.zoom});
}

/// Optimized clustering service with LRU cache and progressive loading
class MapClusteringService {
  Isolate? _isolate;
  SendPort? _sendPort;
  final _resultController = StreamController<_ClusterResult>.broadcast();
  ReceivePort? _receivePort;

  // LRU cache with size limit to prevent memory issues
  final _LRUCache<String, _ClusterResult> _cache = _LRUCache(maxSize: 20);
  bool _isInitialized = false;

  // Debounce timer for rapid zoom changes
  Timer? _debounceTimer;
  _ClusterRequest? _pendingRequest;

  Stream<_ClusterResult> get resultStream => _resultController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      _clusteringIsolate,
      _receivePort!.sendPort,
    );

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isInitialized = true;
      } else if (message is _ClusterResult) {
        final cacheKey = _getCacheKey(message.zoom);
        _cache.put(cacheKey, message);
        _resultController.add(message);
      }
    });

    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Request clustering with progressive loading
  Future<List<StoreCluster>> clusterStores({
    required List<StoreModel> stores,
    required double zoom,
    bool forceRecalculate = false,
    bool debounce = true,
  }) async {
    if (!_isInitialized || _sendPort == null) {
      await initialize();
    }

    final cacheKey = _getCacheKey(zoom);

    // Return cached immediately if available
    if (!forceRecalculate && _cache.containsKey(cacheKey)) {
      return _cache.get(cacheKey)!.clusters;
    }

    // Check nearby zoom levels for progressive loading
    if (!forceRecalculate) {
      final nearbyCache = _findNearbyCache(zoom);
      if (nearbyCache != null) {
        // Return nearby cached result immediately, then recalculate in background
        _scheduleBackgroundCalculation(stores, zoom, debounce);
        return nearbyCache.clusters;
      }
    }

    // No cache available - calculate immediately
    return _calculateClusters(stores, zoom, debounce);
  }

  /// Find cached result for nearby zoom level
  _ClusterResult? _findNearbyCache(double zoom) {
    // Check zoom levels within 0.5 range
    for (double delta = 0.1; delta <= 0.5; delta += 0.1) {
      final upperKey = _getCacheKey(zoom + delta);
      if (_cache.containsKey(upperKey)) {
        return _cache.get(upperKey);
      }

      final lowerKey = _getCacheKey(zoom - delta);
      if (_cache.containsKey(lowerKey)) {
        return _cache.get(lowerKey);
      }
    }
    return null;
  }

  /// Schedule background calculation (debounced)
  void _scheduleBackgroundCalculation(
    List<StoreModel> stores,
    double zoom,
    bool debounce,
  ) {
    _pendingRequest = _ClusterRequest(
      stores: stores,
      zoom: zoom,
      sendPort: ReceivePort().sendPort,
    );

    if (debounce) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 200), () {
        if (_pendingRequest != null) {
          _sendClusterRequest(_pendingRequest!);
          _pendingRequest = null;
        }
      });
    } else {
      _sendClusterRequest(_pendingRequest!);
      _pendingRequest = null;
    }
  }

  /// Calculate clusters immediately
  Future<List<StoreCluster>> _calculateClusters(
    List<StoreModel> stores,
    double zoom,
    bool debounce,
  ) async {
    final completer = Completer<List<StoreCluster>>();
    final responsePort = ReceivePort();

    final request = _ClusterRequest(
      stores: stores,
      zoom: zoom,
      sendPort: responsePort.sendPort,
    );

    if (debounce) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 200), () {
        _sendClusterRequest(request);
      });
    } else {
      _sendClusterRequest(request);
    }

    responsePort.listen((message) {
      if (message is _ClusterResult) {
        completer.complete(message.clusters);
        responsePort.close();
      }
    });

    return completer.future;
  }

  void _sendClusterRequest(_ClusterRequest request) {
    if (_sendPort != null) {
      _sendPort!.send(request);
    }
  }

  String _getCacheKey(double zoom) {
    return zoom.toStringAsFixed(1);
  }

  void clearCache() {
    _cache.clear();
    _debounceTimer?.cancel();
    _pendingRequest = null;
    MapClusteringHelper.clearCache();
  }

  void dispose() {
    _debounceTimer?.cancel();
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _resultController.close();
    _cache.clear();
    _isInitialized = false;
  }

  static void _clusteringIsolate(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is _ClusterRequest) {
        final clusters = MapClusteringHelper.clusterStores(
          message.stores,
          message.zoom,
        );

        final result = _ClusterResult(
          clusters: clusters,
          zoom: message.zoom,
        );

        message.sendPort.send(result);
        mainSendPort.send(result);
      }
    });
  }
}

/// Simple LRU Cache implementation
class _LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _accessOrder = [];

  _LRUCache({required this.maxSize});

  bool containsKey(K key) => _cache.containsKey(key);

  V? get(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return _cache[key];
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used
      final lru = _accessOrder.removeAt(0);
      _cache.remove(lru);
    }

    _cache[key] = value;
    _accessOrder.add(key);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }
}