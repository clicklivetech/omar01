class CartItem {
  final String productId;
  final int quantity;
  final double price;
  final String name;
  final String imageUrl;

  const CartItem({
    required this.productId,
    this.quantity = 1,
    required this.price,
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'] ?? 1,
      price: json['price'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  CartItem copyWith({
    String? productId,
    int? quantity,
    double? price,
    String? name,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  double get total => price * quantity;
}
