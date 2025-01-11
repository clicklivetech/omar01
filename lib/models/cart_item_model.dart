import 'package:uuid/uuid.dart';
import 'product_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final int quantity;
  final double price;
  final String name;
  final String imageUrl;

  double get discountPrice => price * 0.9; // Adding 10% discount

  CartItemModel({
    String? id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.name,
    required this.imageUrl,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItemModel(
      productId: product.id,
      quantity: quantity,
      price: product.finalPrice,
      name: product.name,
      imageUrl: product.imageUrl,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String?,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    int? quantity,
    double? price,
    String? name,
    String? imageUrl,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  double get total => price * quantity;
}
