import 'package:dartz/dartz.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, CartEntity>> addItem(CartItemEntity item);

  Future<Either<Failure, CartEntity>> removeItem(String productId);

  Future<Either<Failure, CartEntity>> updateQuantity({
    required String productId,
    required int quantity,
  });

  Future<Either<Failure, void>> clearCart();
}

