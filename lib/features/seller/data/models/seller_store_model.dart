class SellerStoreModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SellerStoreModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : 'S';

  SellerStoreModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerStoreModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

