import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/address_model.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../enums/order_status.dart';
import '../services/supabase_service.dart';
import '../services/logger_service.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';

class AppState with ChangeNotifier {
  final List<ProductModel> _cartItems = [];
  final List<ProductModel> _favoriteItems = [];
  final List<ProductModel> _products = []; // سيتم تعبئتها من Supabase لاحقاً
  final List<AddressModel> _addresses = [];
  List<OrderModel> _orders = []; // تم تغييرها من final إلى متغير عادي
  String? _currentUserId;

  int _currentPageIndex = 0;

  AppState() {
    _loadAddresses();
    _loadCart();
  }

  List<ProductModel> get cartItems => _cartItems;
  List<ProductModel> get favoriteItems => _favoriteItems;
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<ProductModel> get onSaleProducts => _products.where((p) => p.hasDiscount).toList();

  double get cartTotal => _cartItems.fold(
    0.0, 
    (sum, item) => sum + (item.price * item.quantity)
  );

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

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_items');
      if (cartJson != null) {
        final cartList = jsonDecode(cartJson) as List;
        _cartItems.clear();
        _cartItems.addAll(
          cartList.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList()
        );
        notifyListeners();
      }
    } catch (e) {
      LoggerService.error('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items', cartJson);
    } catch (e) {
      LoggerService.error('Error saving cart: $e');
    }
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
    final existingIndex = _cartItems.indexWhere((item) => item.id == product.id);
    if (existingIndex == -1) {
      _cartItems.add(product.copyWith(quantity: 1));
    } else {
      final currentQuantity = _cartItems[existingIndex].quantity;
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: currentQuantity + 1
      );
    }
    _saveCart();  // Save cart after modification
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    _saveCart();  // Save cart after modification
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
      _saveCart();  // Save cart after modification
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _saveCart();  // Save cart after modification
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

  // إنشاء طلب جديد
  Future<String> createOrder({
    required String shippingAddress,
    required String phone,
    required double deliveryFee,
  }) async {
    final cartItems = _cartItems;
    if (cartItems.isEmpty) throw Exception('السلة فارغة');

    final totalAmount = cartTotal + deliveryFee;
    
    try {
      final orderId = await SupabaseService.createOrder(
        userId: _currentUserId,  // يمكن أن يكون null
        shippingAddress: shippingAddress,
        phone: phone,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        items: cartItems.map((item) => CartItem(
          id: item.id,
          quantity: item.quantity,
          price: item.price,
          name: item.name,
          imageUrl: item.imageUrl,
        )).toList(),
      );

      // تحديث قائمة الطلبات فقط إذا كان المستخدم مسجل دخول
      if (_currentUserId != null) {
        await fetchUserOrders();
      }
      
      // مسح السلة بعد نجاح الطلب
      clearCart();
      
      return orderId;
    } catch (e, stackTrace) {
      LoggerService.error('Error creating order: $e\n$stackTrace');
      rethrow;
    }
  }

  // جلب طلبات المستخدم
  Future<void> fetchUserOrders() async {
    if (_currentUserId == null) return;

    try {
      final orders = await SupabaseService.getUserOrders(_currentUserId!);
      _orders = orders;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error fetching user orders', e);
    }
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

      try {
        // تحديث الطلب في Supabase
        await SupabaseService.updateOrderStatus(order.id, OrderStatus.cancelled);
        _orders[index] = updatedOrder;
        notifyListeners();
      } catch (e) {
        LoggerService.error('Error updating order status', e);
        rethrow;
      }
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
