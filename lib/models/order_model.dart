import '../enums/order_status.dart';

enum PaymentMethod { cash, creditCard }

class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final String shippingAddress;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double deliveryFee;
  final PaymentMethod paymentMethod;
  final List<OrderItem> items;
  final DateTime? cancelledAt;
  final String? oldStatus;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.items,
    this.cancelledAt,
    this.oldStatus,
  });

  bool get canBeCancelled => status == OrderStatus.pending;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      totalAmount: json['total_amount'].toDouble(),
      shippingAddress: json['shipping_address'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deliveryFee: json['delivery_fee']?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      items: (json['items'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      oldStatus: json['old_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status.name,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_fee': deliveryFee,
      'payment_method': paymentMethod.name,
      'items': items.map((item) => item.toJson()).toList(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'old_status': oldStatus,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    OrderStatus? status,
    double? totalAmount,
    String? shippingAddress,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? deliveryFee,
    PaymentMethod? paymentMethod,
    List<OrderItem>? items,
    DateTime? cancelledAt,
    String? oldStatus,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      oldStatus: oldStatus ?? this.oldStatus,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final DateTime createdAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    int? quantity,
    double? price,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
