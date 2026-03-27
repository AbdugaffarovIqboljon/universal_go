import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class StoreEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int totalRatings;
  final int productCount;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional - only populated when fetching store details
  final List<ProductEntity>? products;

  const StoreEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.totalRatings,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.isActive = true,
    this.products, 
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        category,
        address,
        latitude,
        longitude,
        rating,
        totalRatings,
        productCount,
        description,
        logoUrl,
        coverImageUrl,
        isActive,
        createdAt,
        updatedAt,
        products,
      ];
}

