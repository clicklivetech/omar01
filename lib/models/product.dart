import 'package:uuid/uuid.dart';

class Product {
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
  final bool dailyDeals;
  final double rating;

  Product({
    String? id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.stockQuantity,
    required this.imageUrl,
    this.isFeatured = false,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.unit,
    this.dailyDeals = false,
    this.rating = 0.0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isOnSale => discountPrice != null && discountPrice! < price;

  // تحويل من JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      categoryId: json['category_id'] as String,
      stockQuantity: json['stock_quantity'] as int,
      imageUrl: json['image_url'] as String,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      unit: json['unit'] as String,
      dailyDeals: json['daily_deals'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // تحويل إلى JSON
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
      'daily_deals': dailyDeals,
      'rating': rating,
    };
  }

  // نسخة معدلة من المنتج
  Product copyWith({
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
    bool? dailyDeals,
    double? rating,
  }) {
    return Product(
      id: id,
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
      dailyDeals: dailyDeals ?? this.dailyDeals,
      rating: rating ?? this.rating,
    );
  }

  // حساب نسبة الخصم
  double? get discountPercentage {
    if (discountPrice == null || discountPrice! >= price) return null;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  // السعر النهائي بعد الخصم
  double get finalPrice => discountPrice ?? price;

  // هل المنتج متوفر في المخزون
  bool get isInStock => stockQuantity > 0;
}
