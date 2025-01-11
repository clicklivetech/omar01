import 'package:uuid/uuid.dart';
import 'cart_item_model.dart';
import '../enums/order_status.dart';

class OrderModel {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final String shippingAddress;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double deliveryFee;
  final String paymentMethod;
  final List<OrderItem> items;
  final DateTime? cancelledAt;
  final String? oldStatus;

  OrderModel({
    String? id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.items,
    this.cancelledAt,
    this.oldStatus,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  bool get canBeCancelled {
    final currentStatus = OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => OrderStatus.pending,
    );
    return currentStatus != OrderStatus.cancelled && 
           currentStatus != OrderStatus.delivered;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_fee': deliveryFee,
      'payment_method': paymentMethod,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'old_status': oldStatus,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      totalAmount: json['total_amount'].toDouble(),
      shippingAddress: json['shipping_address'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deliveryFee: json['delivery_fee'].toDouble(),
      paymentMethod: json['payment_method'],
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      oldStatus: json['old_status'],
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

  OrderItem({
    String? id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    DateTime? createdAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

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

  factory OrderItem.fromCartItem(CartItemModel cartItem, String orderId) {
    return OrderItem(
      orderId: orderId,
      productId: cartItem.productId,
      quantity: cartItem.quantity,
      price: cartItem.price,
    );
  }
}
