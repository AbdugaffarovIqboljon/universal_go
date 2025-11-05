import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';
import 'package:universal_go/features/shops/domain/entities/product_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.product,
    required super.quantity,
    super.notes,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      product: ProductModel.fromEntity(entity.product),
      quantity: entity.quantity,
      notes: entity.notes,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
      'notes': notes,
    };
  }

  @override
  CartItemModel copyWith({
    ProductEntity? product,
    int? quantity,
    String? notes,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

