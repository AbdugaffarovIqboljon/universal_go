import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';
import 'package:universal_go/features/cart/domain/repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<CartEntity, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams params) async {
    return await repository.addItem(params.item);
  }
}

class AddToCartParams extends Equatable {
  final CartItemEntity item;

  const AddToCartParams({required this.item});

  @override
  List<Object> get props => [item];
}

