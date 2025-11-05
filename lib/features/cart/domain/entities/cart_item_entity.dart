import 'package:equatable/equatable.dart';
import 'package:universal_go/features/shops/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final String? notes;

  const CartItemEntity({
    required this.product,
    required this.quantity,
    this.notes,
  });

  double get subtotal => product.price * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    String? notes,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [product, quantity, notes];
}

