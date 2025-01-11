import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../enums/order_status.dart';

// إضافة نموذج الطلبات
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

  bool get canBeCancelled => status == OrderStatus.pending;

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

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

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

class AppState extends ChangeNotifier {
  final List<ProductModel> _cartItems = [];
  final List<ProductModel> _favoriteItems = [];
  final List<ProductModel> _products = []; // سيتم تعبئتها من Supabase لاحقاً
  final List<AddressModel> _addresses = [];
  final List<OrderModel> _orders = [];
  String? _currentUserId;

  int _currentPageIndex = 0;

  AppState() {
    _loadAddresses();
  }

  List<ProductModel> get cartItems => _cartItems;
  List<ProductModel> get favoriteItems => _favoriteItems;
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<ProductModel> get onSaleProducts => _products.where((p) => p.hasDiscount).toList();

  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.finalPrice);
  int get cartItemsCount => _cartItems.length;  // Number of unique products in cart

  int get currentPageIndex => _currentPageIndex;

  List<AddressModel> get addresses => _addresses;
  
  AddressModel? get defaultAddress => 
    _addresses.isNotEmpty ? _addresses.firstWhere((addr) => addr.isDefault, orElse: () => _addresses.first) : null;

  List<OrderModel> get orders => _orders;

  String? get currentUserId => _currentUserId;

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getStringList('addresses') ?? [];
    _addresses.clear();
    _addresses.addAll(
      addressesJson.map((json) => AddressModel.fromJson(jsonDecode(json))).toList(),
    );
    notifyListeners();
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = _addresses.map((addr) => jsonEncode(addr.toJson())).toList();
    await prefs.setStringList('addresses', addressesJson);
  }

  Future<void> addAddress({
    required String name,
    required String phone,
    required String address,
    String? notes,
    bool setAsDefault = false,
  }) async {
    final newAddress = AddressModel(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      address: address,
      notes: notes,
      isDefault: setAsDefault || _addresses.isEmpty,
    );

    if (setAsDefault) {
      // إذا كان سيتم تعيين العنوان الجديد كافتراضي، نقوم بإلغاء تعيين العنوان الافتراضي السابق
      _addresses.where((addr) => addr.isDefault).forEach((addr) {
        final index = _addresses.indexOf(addr);
        _addresses[index] = addr.copyWith(isDefault: false);
      });
    }

    _addresses.add(newAddress);
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> updateAddress({
    required String id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    bool? setAsDefault,
  }) async {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      if (setAsDefault == true) {
        // إلغاء تعيين العنوان الافتراضي السابق
        _addresses.where((addr) => addr.isDefault).forEach((addr) {
          final i = _addresses.indexOf(addr);
          _addresses[i] = addr.copyWith(isDefault: false);
        });
      }

      _addresses[index] = _addresses[index].copyWith(
        name: name,
        phone: phone,
        address: address,
        notes: notes,
        isDefault: setAsDefault ?? _addresses[index].isDefault,
      );

      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> removeAddress(String id) async {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      final wasDefault = _addresses[index].isDefault;
      _addresses.removeAt(index);

      if (wasDefault && _addresses.isNotEmpty) {
        // إذا تم حذف العنوان الافتراضي، نقوم بتعيين أول عنوان كافتراضي
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }

      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String id) async {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      // إلغاء تعيين العنوان الافتراضي السابق
      _addresses.where((addr) => addr.isDefault).forEach((addr) {
        final i = _addresses.indexOf(addr);
        _addresses[i] = addr.copyWith(isDefault: false);
      });

      // تعيين العنوان الجديد كافتراضي
      _addresses[index] = _addresses[index].copyWith(isDefault: true);

      await _saveAddresses();
      notifyListeners();
    }
  }

  void addToCart(ProductModel product) {
    if (!_cartItems.contains(product)) {
      _cartItems.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void toggleFavorite(ProductModel product) {
    if (_favoriteItems.contains(product)) {
      _favoriteItems.remove(product);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(ProductModel product) {
    return _favoriteItems.contains(product);
  }

  int getCartItemQuantity(String productId) {
    final product = _cartItems.firstWhere(
      (item) => item.id == productId,
      orElse: () => ProductModel(
        id: '',
        name: '',
        description: '',
        price: 0,
        imageUrl: '',
        categoryId: '',
        stockQuantity: 0,
        isFeatured: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        unit: 'piece',
        dailyDeals: false,
        quantity: 0,
      ),
    );
    return product.quantity;
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.id == productId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void setCurrentPageIndex(int index) {
    if (index >= 0 && index < 5) {  // التحقق من صحة الindex
      _currentPageIndex = index;
      notifyListeners();
    }
  }
  
  // إضافة منتجات للتجربة
  void addDummyProducts() {
    final dummyProduct = ProductModel(
      id: "1",
      name: "منتج تجريبي",
      description: "وصف المنتج التجريبي",
      price: 99.99,
      discountPrice: 79.99,
      categoryId: "1",
      stockQuantity: 10,
      imageUrl: "https://via.placeholder.com/150",
      isFeatured: true,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      unit: "قطعة",
      dailyDeals: true
    );
    
    _products.add(dummyProduct);
    notifyListeners();
  }

  // إدارة الطلبات
  Future<OrderModel> createOrder({
    required String shippingAddress,
    required String phone,
    required PaymentMethod paymentMethod,
    required double deliveryFee,
  }) async {
    final totalAmount = _cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final orderItems = _cartItems
        .map((item) => OrderItem(
              id: const Uuid().v4(),
              orderId: '', // Will be set after order creation
              productId: item.id,
              quantity: item.quantity,
              price: item.price,
              createdAt: DateTime.now(),
            ))
        .toList();

    final newOrder = OrderModel(
      id: const Uuid().v4(),
      userId: _currentUserId ?? 'current_user_id', // TODO: يجب تحديثه مع نظام المستخدمين
      status: OrderStatus.pending,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      phone: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deliveryFee: deliveryFee,
      paymentMethod: paymentMethod,
      items: orderItems,
    );

    // Update order items with the new order ID
    newOrder.items.forEach((item) => item.copyWith(orderId: newOrder.id));

    // TODO: إرسال الطلب إلى Supabase
    _orders.add(newOrder);
    _cartItems.clear();
    notifyListeners();
    
    return newOrder;
  }

  OrderModel getOrder(String orderId) {
    return _orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => OrderModel(
        id: orderId,
        userId: 'not_found',
        status: OrderStatus.pending,
        totalAmount: 0,
        shippingAddress: '',
        phone: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deliveryFee: 0,
        paymentMethod: PaymentMethod.cash,
        items: [],
      ),
    );
  }

  // استرجاع طلب معين
  Future<void> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1 && _orders[index].canBeCancelled) {
      final order = _orders[index];
      final updatedOrder = OrderModel(
        id: order.id,
        userId: order.userId,
        status: OrderStatus.cancelled,
        totalAmount: order.totalAmount,
        shippingAddress: order.shippingAddress,
        phone: order.phone,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
        deliveryFee: order.deliveryFee,
        paymentMethod: order.paymentMethod,
        items: order.items,
        cancelledAt: DateTime.now(),
        oldStatus: order.status.toString().split('.').last,
      );

      // TODO: تحديث الطلب في Supabase
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  // استرجاع الطلبات حسب الحالة
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // استرجاع آخر الطلبات
  List<OrderModel> get recentOrders {
    final sortedOrders = List<OrderModel>.from(_orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(5).toList();
  }
}
