import 'package:dartz/dartz.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/repositories/cart_repository.dart';

class GetCartUseCase implements UseCaseNoParams<CartEntity> {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call() async {
    return await repository.getCart();
  }
}

