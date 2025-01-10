import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final double? oldPrice;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final double rating;

  @HiveField(8)
  final bool isFeatured;

  @HiveField(9)
  final bool isOnSale;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.isFeatured = false,
    this.isOnSale = false,
  });

  double get discountPercentage {
    if (oldPrice == null || oldPrice! <= price) return 0.0;
    return ((oldPrice! - price) / oldPrice! * 100).roundToDouble();
  }
}
