import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final bool isAvailable;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        description,
        price,
        imageUrl,
        category,
        isAvailable,
        stock,
        createdAt,
        updatedAt,
      ];
}
