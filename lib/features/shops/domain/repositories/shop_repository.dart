import 'package:dartz/dartz.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/shops/domain/entities/store_entity.dart';

abstract class ShopRepository {
  Future<Either<Failure, List<StoreEntity>>> getNearbyShops({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
  });
  
  Future<Either<Failure, StoreEntity>> getShopById(String shopId);
  
  Future<Either<Failure, List<StoreEntity>>> searchShops(String query);
}
























