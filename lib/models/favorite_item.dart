import 'package:uuid/uuid.dart';
import 'product_model.dart';

class FavoriteItem {
  final String id;
  final ProductModel product;
  final DateTime addedAt;

  FavoriteItem({
    String? id,
    required this.product,
    DateTime? addedAt,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  // تحويل من JSON
  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'added_at': addedAt.toIso8601String(),
    };
  }
}
