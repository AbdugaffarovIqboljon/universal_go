import 'package:dartz/dartz.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/cart/domain/repositories/cart_repository.dart';

class ClearCartUseCase implements UseCaseNoParams<void> {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.clearCart();
  }
}

