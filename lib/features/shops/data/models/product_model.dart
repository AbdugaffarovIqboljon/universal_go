import 'package:universal_go/features/shops/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.price,
    required super.inStock,
    required super.createdAt,
    required super.updatedAt,
    super.image,
    super.description,
    super.stockQuantity,
    super.category,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      storeId: entity.storeId,
      name: entity.name,
      price: entity.price,
      inStock: entity.inStock,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      image: entity.image,
      description: entity.description,
      stockQuantity: entity.stockQuantity,
      category: entity.category,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      inStock: json['inStock'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      image: json['image'] as String?,
      description: json['description'] as String?,
      stockQuantity: json['stockQuantity'] as int?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'price': price,
      'inStock': inStock,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'image': image,
      'description': description,
      'stockQuantity': stockQuantity,
      'category': category,
    };
  }

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? name,
    double? price,
    String? image,
    String? description,
    bool? inStock,
    int? stockQuantity,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      price: price ?? this.price,
      inStock: inStock ?? this.inStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      image: image ?? this.image,
      description: description ?? this.description,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
    );
  }
}
























