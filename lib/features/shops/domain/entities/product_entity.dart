import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String storeId; // Links product to store
  final String name;
  final double price;
  final String? image; // URL or asset path
  final String? description;
  final bool inStock;
  final int? stockQuantity;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    required this.inStock,
    required this.createdAt,
    required this.updatedAt,
    this.image,
    this.description,
    this.stockQuantity,
    this.category,
  });

  @override
  List<Object?> get props => [
        id,
        storeId,
        name,
        price,
        image,
        description,
        inStock,
        stockQuantity,
        category,
        createdAt,
        updatedAt,
      ];
}

