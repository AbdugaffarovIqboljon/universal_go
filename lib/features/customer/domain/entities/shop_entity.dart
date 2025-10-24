import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final double latitude;
  final double longitude;
  final String address;
  final String? imageUrl;
  final bool isOpen;
  final double rating;
  final int totalOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShopEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrl,
    required this.isOpen,
    required this.rating,
    required this.totalOrders,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        latitude,
        longitude,
        address,
        imageUrl,
        isOpen,
        rating,
        totalOrders,
        createdAt,
        updatedAt,
      ];
}
