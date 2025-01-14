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
    try {
      final orderItems = (json['order_items'] as List?)?.map((item) {
        return OrderItem(
          id: item['id']?.toString() ?? '',
          orderId: item['order_id']?.toString() ?? '',
          productId: item['product_id']?.toString() ?? '',
          quantity: item['quantity'] ?? 0,
          price: (item['price'] ?? 0).toDouble(),
          createdAt: item['created_at'] != null 
            ? DateTime.parse(item['created_at']) 
            : DateTime.now(),
          product: item['product'] != null 
            ? ProductDetails.fromJson(item['product']) 
            : null,
        );
      }).toList() ?? [];

      return OrderModel(
        id: json['id']?.toString(),
        userId: json['user_id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        totalAmount: (json['total_amount'] ?? 0).toDouble(),
        shippingAddress: json['shipping_address']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
        updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
        deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
        paymentMethod: json['payment_method']?.toString() ?? 'cash',
        items: orderItems,
        cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at']) 
          : null,
        oldStatus: json['old_status']?.toString(),
      );
    } catch (e, stackTrace) {
      print('Error parsing order JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final ProductDetails? product;

  OrderItem({
    String? id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    DateTime? createdAt,
    this.product,
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
      'product': product?.toJson(),
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
      product: json['product'] != null 
        ? ProductDetails.fromJson(json['product']) 
        : null,
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

class ProductDetails {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isActive;

  ProductDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'منتج غير معروف',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url']?.toString() ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}
