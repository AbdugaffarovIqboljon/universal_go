import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartQuantityUseCase implements UseCase<CartEntity, UpdateQuantityParams> {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(UpdateQuantityParams params) async {
    return await repository.updateQuantity(
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}

class UpdateQuantityParams extends Equatable {
  final String productId;
  final int quantity;

  const UpdateQuantityParams({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}

