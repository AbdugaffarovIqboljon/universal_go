import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/repositories/cart_repository.dart';

class RemoveFromCartUseCase implements UseCase<CartEntity, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(RemoveFromCartParams params) async {
    return await repository.removeItem(params.productId);
  }
}

class RemoveFromCartParams extends Equatable {
  final String productId;

  const RemoveFromCartParams({required this.productId});

  @override
  List<Object> get props => [productId];
}

