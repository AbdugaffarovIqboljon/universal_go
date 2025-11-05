import 'package:equatable/equatable.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final String? shopId;

  const CartEntity({
    required this.items,
    this.shopId,
  });

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get deliveryCost => 0.0;

  double get commission => subtotal * 0.015;

  double get total => subtotal + deliveryCost + commission;

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;

  CartEntity copyWith({
    List<CartItemEntity>? items,
    String? shopId,
  }) {
    return CartEntity(
      items: items ?? this.items,
      shopId: shopId ?? this.shopId,
    );
  }

  @override
  List<Object?> get props => [items, shopId];
}

