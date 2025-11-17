import 'package:universal_go/features/shops/data/models/store_model.dart';

class StoreCluster {
  final String id;
  final double latitude;
  final double longitude;
  final List<StoreModel> stores;
  final int count;

  const StoreCluster({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.stores,
    required this.count,
  });

  bool get isSingleStore => count == 1;

  StoreModel get singleStore => stores.first;
}