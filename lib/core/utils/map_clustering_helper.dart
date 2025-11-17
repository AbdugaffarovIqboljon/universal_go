import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:universal_go/features/customer/data/models/map_store_cluster.dart';
import 'package:universal_go/features/shops/data/models/store_model.dart';

class MapClusteringHelper {
  // Tashkent city center
  static const double tashkentCenterLat = 41.3111;
  static const double tashkentCenterLon = 69.2797;
  static const double tashkentInitialZoom = 10.8;

  // ADJUSTED: Show individual stores at closer zoom (was 12.5)
  static const double individualStoreThreshold = 13.0;

  static bool shouldShowIndividualStores(double zoom) {
    return zoom >= individualStoreThreshold;
  }

  static List<StoreCluster> clusterStores(
    List<StoreModel> stores,
    double currentZoom,
  ) {
    if (stores.isEmpty) return [];

    // Show individual stores at close zoom levels
    if (shouldShowIndividualStores(currentZoom)) {
      return stores
          .map((store) => StoreCluster(
                id: 'single_${store.id}',
                latitude: store.latitude,
                longitude: store.longitude,
                stores: [store],
                count: 1,
              ))
          .toList();
    }

    // IMPROVED: Better zoom-based clustering thresholds
    if (currentZoom < 9.5) {
      // Very far: ONE cluster with ALL stores
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
    } else if (currentZoom < 11.5) {
      // Medium zoom (initial view): Large clusters (6.5km radius)
      // At zoom 10.8, this creates 2-4 clusters for Tashkent
      return _createDistanceBasedClusters(stores, 6.5);
    } else if (currentZoom < 13.0) {
      // Close zoom: Medium clusters (3.5km radius)
      return _createDistanceBasedClusters(stores, 3.5);
    } else {
      // Very close: Tight clusters or individual stores
      return _createDistanceBasedClusters(stores, 1.5);
    }
  }

  static List<StoreCluster> _createDistanceBasedClusters(
    List<StoreModel> stores,
    double maxDistanceKm,
  ) {
    final List<StoreCluster> clusters = [];
    final Set<String> processedIds = {};

    // Sort stores by latitude to process them in a spatial order
    final sortedStores = List<StoreModel>.from(stores)
      ..sort((a, b) => a.latitude.compareTo(b.latitude));

    for (final store in sortedStores) {
      if (processedIds.contains(store.id)) continue;

      // Start a new cluster with this store
      final List<StoreModel> clusterStores = [store];
      processedIds.add(store.id);

      // IMPROVED: Find all nearby stores within radius of ANY store in cluster
      bool addedInThisPass = true;
      while (addedInThisPass) {
        addedInThisPass = false;

        for (final otherStore in sortedStores) {
          if (processedIds.contains(otherStore.id)) continue;

          // Check if otherStore is within distance of ANY store in current cluster
          bool isNearby = false;
          for (final clusterStore in clusterStores) {
            final distance = calculateDistance(
              clusterStore.latitude,
              clusterStore.longitude,
              otherStore.latitude,
              otherStore.longitude,
            );

            if (distance <= maxDistanceKm) {
              isNearby = true;
              break;
            }
          }

          if (isNearby) {
            clusterStores.add(otherStore);
            processedIds.add(otherStore.id);
            addedInThisPass = true;
          }
        }
      }

      final centerPoint = _calculateCenterPoint(clusterStores);

      clusters.add(
        StoreCluster(
          id: 'cluster_${clusters.length}',
          latitude: centerPoint.$1,
          longitude: centerPoint.$2,
          stores: clusterStores,
          count: clusterStores.length,
        ),
      );
    }

    // VALIDATION: Ensure we got all stores
    final totalStoresInClusters = clusters.fold<int>(
      0,
      (sum, cluster) => sum + cluster.count,
    );

    if (totalStoresInClusters != stores.length) {
      debugPrint(
        'WARNING: Store count mismatch! Expected ${stores.length}, got $totalStoresInClusters',
      );
    }

    return clusters;
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
}