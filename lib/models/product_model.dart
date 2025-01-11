class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final int stockQuantity;
  final String imageUrl;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String unit;
  final String? searchVector;
  final bool dailyDeals;
  final double rating;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.stockQuantity,
    required this.imageUrl,
    required this.isFeatured,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.unit,
    this.searchVector,
    required this.dailyDeals,
    this.rating = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),  // تحويل UUID إلى String
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse((json['price'] ?? 0).toString()),
      discountPrice: json['discount_price'] != null 
          ? double.parse(json['discount_price'].toString())
          : null,
      categoryId: json['category_id'].toString(),  // تحويل UUID إلى String
      stockQuantity: (json['stock_quantity'] ?? 0) as int,
      imageUrl: json['image_url'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      unit: json['unit'] ?? '',
      searchVector: json['search_vector'],
      dailyDeals: json['daily_deals'] ?? false,
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'category_id': categoryId,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unit': unit,
      'search_vector': searchVector,
      'daily_deals': dailyDeals,
      'rating': rating,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    int? stockQuantity,
    String? imageUrl,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? unit,
    String? searchVector,
    bool? dailyDeals,
    double? rating,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      categoryId: categoryId ?? this.categoryId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unit: unit ?? this.unit,
      searchVector: searchVector ?? this.searchVector,
      dailyDeals: dailyDeals ?? this.dailyDeals,
      rating: rating ?? this.rating,
    );
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  double get finalPrice => discountPrice ?? price;

  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((price - discountPrice!) / price * 100);
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, discountPrice: $discountPrice, categoryId: $categoryId, stockQuantity: $stockQuantity, isFeatured: $isFeatured, isActive: $isActive, unit: $unit, dailyDeals: $dailyDeals, rating: $rating)';
  }
}
