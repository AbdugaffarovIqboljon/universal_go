import 'package:equatable/equatable.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItemEntity item;

  const AddToCart({required this.item});

  @override
  List<Object> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String productId;

  const RemoveFromCart({required this.productId});

  @override
  List<Object> get props => [productId];
}

class UpdateCartQuantity extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartQuantity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}

class ClearCart extends CartEvent {}

