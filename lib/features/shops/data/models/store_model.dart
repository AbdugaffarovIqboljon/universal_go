import 'package:universal_go/features/shops/domain/entities/store_entity.dart';
import 'package:universal_go/features/shops/domain/entities/product_entity.dart';
import 'product_model.dart';

class StoreModel extends StoreEntity {
  final double? distance;

  const StoreModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.category,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.rating,
    required super.totalRatings,
    required super.productCount,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.logoUrl,
    super.coverImageUrl,
    super.isActive,
    super.products,
    this.distance,
  });

  factory StoreModel.fromEntity(StoreEntity entity, {double? distance}) {
    return StoreModel(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      category: entity.category,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      rating: entity.rating,
      totalRatings: entity.totalRatings,
      productCount: entity.productCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      description: entity.description,
      logoUrl: entity.logoUrl,
      coverImageUrl: entity.coverImageUrl,
      isActive: entity.isActive,
      products: entity.products,
      distance: distance,
    );
  }

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    // Parse products if included in JSON
    List<ProductEntity>? products;
    if (json['products'] != null) {
      products = (json['products'] as List)
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return StoreModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      productCount: json['productCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      products: products,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'totalRatings': totalRatings,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      if (products != null) 'products': products!.map((p) => (p as ProductModel).toJson()).toList(),
      if (distance != null) 'distance': distance,
    };
  }

  StoreModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalRatings,
    int? productCount,
    String? description,
    String? logoUrl,
    String? coverImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProductEntity>? products,
    double? distance,
  }) {
    return StoreModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      products: products ?? this.products,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [...super.props, distance];
}