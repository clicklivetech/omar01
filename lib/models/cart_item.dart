class CartItem {
  final String id;
  final int quantity;
  final double price;
  final String name;
  final String imageUrl;

  const CartItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      quantity: json['quantity'],
      price: json['price'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  CartItem copyWith({
    String? id,
    int? quantity,
    double? price,
    String? name,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
