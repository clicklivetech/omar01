import 'package:uuid/uuid.dart';
import 'product_model.dart';

class CartItem {
  final String id;
  final ProductModel product;
  final int quantity;

  CartItem({
    String? id,
    required this.product,
    required this.quantity,
  }) : this.id = id ?? const Uuid().v4();

  // حساب السعر الإجمالي للعنصر
  double get totalPrice => product.finalPrice * quantity;

  // تحويل من JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
