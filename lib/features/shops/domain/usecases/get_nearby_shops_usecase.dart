import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/core/base/usecase.dart';
import '../entities/store_entity.dart';
import '../repositories/shop_repository.dart';

class GetNearbyShopsUseCase implements UseCase<List<StoreEntity>, GetNearbyShopsParams> {
  final ShopRepository repository;

  GetNearbyShopsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StoreEntity>>> call(GetNearbyShopsParams params) async {
    return await repository.getNearbyShops(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusInKm: params.radiusInKm,
    );
  }
}

class GetNearbyShopsParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const GetNearbyShopsParams({
    required this.latitude,
    required this.longitude,
    this.radiusInKm = 10.0,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusInKm];
}
