import '../enums/order_status.dart';

enum PaymentMethod {
  cashOnDelivery,  // الدفع عند الاستلام
  creditCard,      // بطاقة ائتمان
}

class OrderItem {
  final String id;           // uuid
  final String orderId;      // uuid (orders.id)
  final String productId;    // uuid (products.id)
  final int quantity;        // int4
  final double price;        // numeric
  final DateTime createdAt;  // timestamptz

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'quantity': quantity,
    'price': price,
    'created_at': createdAt.toIso8601String(),
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    orderId: json['order_id'],
    productId: json['product_id'],
    quantity: json['quantity'],
    price: json['price'].toDouble(),
    createdAt: DateTime.parse(json['created_at']),
  );
}

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

  OrderModel({
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'status': status.toString().split('.').last,
    'total_amount': totalAmount,
    'shipping_address': shippingAddress,
    'phone': phone,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'delivery_fee': deliveryFee,
    'payment_method': paymentMethod.toString().split('.').last,
    'items': items.map((item) => item.toJson()).toList(),
    'cancelled_at': cancelledAt?.toIso8601String(),
    'old_status': oldStatus,
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    userId: json['user_id'],
    status: OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
      orElse: () => OrderStatus.pending,
    ),
    totalAmount: json['total_amount'].toDouble(),
    shippingAddress: json['shipping_address'],
    phone: json['phone'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    deliveryFee: json['delivery_fee'].toDouble(),
    paymentMethod: PaymentMethod.values.firstWhere(
      (e) => e.toString().split('.').last == json['payment_method'],
      orElse: () => PaymentMethod.cashOnDelivery,
    ),
    items: (json['items'] as List)
        .map((item) => OrderItem.fromJson(item))
        .toList(),
    cancelledAt: json['cancelled_at'] != null
        ? DateTime.parse(json['cancelled_at'])
        : null,
    oldStatus: json['old_status'],
  );

  // حساب المجموع الفرعي (بدون رسوم التوصيل)
  double get subtotal => totalAmount - deliveryFee;

  // حالة إمكانية إلغاء الطلب
  bool get canBeCancelled => status == OrderStatus.pending;

  // نص حالة الطلب بالعربية
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'في انتظار التأكيد';
      case OrderStatus.confirmed:
        return 'تم تأكيد الطلب';
      case OrderStatus.processing:
        return 'جاري التجهيز';
      case OrderStatus.shipping:
        return 'في الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  // نص طريقة الدفع بالعربية
  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.cashOnDelivery:
        return 'الدفع عند الاستلام';
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمان';
    }
  }
}
