import 'package:dartz/dartz.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/customer/domain/entities/shop_entity.dart';

abstract class ShopRepository {
  Future<Either<Failure, List<ShopEntity>>> getNearbyShops({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
  });
  
  Future<Either<Failure, ShopEntity>> getShopById(String shopId);
  
  Future<Either<Failure, List<ShopEntity>>> searchShops(String query);
}
