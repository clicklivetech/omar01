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
import '../models/cart_item_model.dart';
import '../enums/payment_method.dart';
import '../services/cart_service.dart';

class AppState with ChangeNotifier {
  final List<CartItemModel> _cartItems = [];
  final List<ProductModel> _favoriteItems = [];
  final List<ProductModel> _products = []; // سيتم تعبئتها من Supabase لاحقاً
  final List<AddressModel> _addresses = [];
  List<OrderModel> _orders = []; // تم تغييرها من final إلى متغير عادي
  String? _currentUserId;
  String? _userEmail;

  int _currentPageIndex = 0;

  AppState() {
    _loadAddresses();
    _loadCart();
  }

  List<CartItemModel> get cartItems => _cartItems;
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
  String? get userEmail => _userEmail;

  bool get isLoggedIn => _currentUserId != null;

  Future<void> _loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getStringList('addresses') ?? [];
      _addresses.clear();
      _addresses.addAll(
        addressesJson.map((json) => AddressModel.fromJson(jsonDecode(json))),
      );
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error loading addresses: $e');
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = _addresses
          .map((address) => jsonEncode(address.toJson()))
          .toList();
      await prefs.setStringList('addresses', addressesJson);
    } catch (e) {
      LoggerService.error('Error saving addresses: $e');
    }
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');
    if (cartJson != null) {
      final List<dynamic> decodedCart = jsonDecode(cartJson);
      _cartItems.clear();
      _cartItems.addAll(
        decodedCart.map((item) => CartItemModel.fromJson(item)).toList()
      );
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartJson);
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      address: address,
      notes: notes,
      isDefault: setAsDefault,
    );

    _addresses.add(newAddress);
    _saveAddresses();
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
      _addresses[index] = _addresses[index].copyWith(
        name: name,
        phone: phone,
        address: address,
        notes: notes,
        isDefault: setAsDefault,
      );
      _saveAddresses();
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((addr) => addr.id == id);
    _saveAddresses();
    notifyListeners();
  }

  void addToCart(ProductModel product) {
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    if (existingIndex == -1) {
      // إضافة منتج جديد
      _cartItems.add(CartItemModel.fromProduct(product));
    } else {
      // تحديث الكمية للمنتج الموجود
      final currentItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    _saveCart();
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
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        productId: '',
        quantity: 0,
        price: 0,
        name: '',
        imageUrl: '',
      ),
    );
    return item.quantity;
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _saveCart();
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
    // Add multiple dummy products
    final List<ProductModel> dummyProducts = [
      ProductModel(
        id: "1",
        name: "سماعات بلوتوث",
        description: "سماعات لاسلكية عالية الجودة",
        price: 199.99,
        discountPrice: 149.99,
        categoryId: "1",
        stockQuantity: 50,
        imageUrl: "https://picsum.photos/200",
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        unit: "قطعة",
        dailyDeals: true
      ),
      ProductModel(
        id: "2",
        name: "ساعة ذكية",
        description: "ساعة ذكية متعددة المزايا",
        price: 299.99,
        discountPrice: 249.99,
        categoryId: "2",
        stockQuantity: 30,
        imageUrl: "https://picsum.photos/201",
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        unit: "قطعة",
        dailyDeals: false
      ),
      ProductModel(
        id: "3",
        name: "حقيبة ظهر",
        description: "حقيبة ظهر عصرية ومريحة",
        price: 129.99,
        discountPrice: 99.99,
        categoryId: "3",
        stockQuantity: 100,
        imageUrl: "https://picsum.photos/202",
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        unit: "قطعة",
        dailyDeals: true
      ),
    ];
    
    _products.addAll(dummyProducts);
    notifyListeners();
  }

  // إنشاء طلب جديد
  Future<String> createOrder({
    required String shippingAddress,
    required String phone,
    required double deliveryFee,
    required CartService cartService,
  }) async {
    final cartItems = cartService.getCartItems();
    if (cartItems.isEmpty) throw Exception('السلة فارغة');

    final totalAmount = cartService.cartTotal + deliveryFee;
    
    try {
      final orderId = await SupabaseService.createOrder(
        userId: _currentUserId!,
        shippingAddress: shippingAddress,
        phone: phone,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        items: cartItems,
      );

      // تحديث قائمة الطلبات
      if (_currentUserId != null) {
        await fetchUserOrders();
      }
      
      // مسح السلة بعد نجاح الطلب
      await cartService.clearCart();
      
      return orderId;
    } catch (e, stackTrace) {
      LoggerService.error('Error creating order: $e\n$stackTrace');
      rethrow;
    }
  }

  // جلب طلبات المستخدم
  Future<void> fetchUserOrders() async {
    if (_currentUserId == null) {
      LoggerService.error('Cannot fetch orders: User is not logged in');
      return;
    }

    try {
      LoggerService.info('Fetching orders for user: $_currentUserId');
      final orders = await SupabaseService.getUserOrders(_currentUserId!);
      LoggerService.info('Fetched ${orders.length} orders');
      _orders = orders;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error fetching user orders: $e');
    }
  }

  OrderModel getOrder(String orderId) {
    return _orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => OrderModel(
        id: orderId,
        userId: 'not_found',
        status: OrderStatus.pending.toString().split('.').last,
        totalAmount: 0,
        shippingAddress: '',
        phone: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deliveryFee: 0,
        paymentMethod: PaymentMethod.cash.toString().split('.').last,
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
        status: OrderStatus.cancelled.toString().split('.').last,
        totalAmount: order.totalAmount,
        shippingAddress: order.shippingAddress,
        phone: order.phone,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
        deliveryFee: order.deliveryFee,
        paymentMethod: order.paymentMethod,
        items: order.items,
        cancelledAt: DateTime.now(),
        oldStatus: order.status,
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
    return _orders.where((order) => order.status == status.toString().split('.').last).toList();
  }

  // استرجاع آخر الطلبات
  List<OrderModel> get recentOrders {
    final sortedOrders = List<OrderModel>.from(_orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(5).toList();
  }

  void updateOrder(String orderId, OrderStatus newStatus) async {
    try {
      await SupabaseService.updateOrder(
        orderId: orderId,
        status: newStatus.toString().split('.').last,
      );
      
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final oldStatus = _orders[orderIndex].status;
        _orders[orderIndex] = OrderModel(
          id: _orders[orderIndex].id,
          userId: _orders[orderIndex].userId,
          status: newStatus.toString().split('.').last,
          totalAmount: _orders[orderIndex].totalAmount,
          shippingAddress: _orders[orderIndex].shippingAddress,
          phone: _orders[orderIndex].phone,
          createdAt: _orders[orderIndex].createdAt,
          updatedAt: DateTime.now(),
          deliveryFee: _orders[orderIndex].deliveryFee,
          paymentMethod: _orders[orderIndex].paymentMethod,
          items: _orders[orderIndex].items,
          oldStatus: oldStatus,
        );
        notifyListeners();
      }
    } catch (e) {
      LoggerService.error('Error updating order: $e');
    }
  }

  bool canCancelOrder(OrderModel order) {
    return order.status != OrderStatus.cancelled.toString().split('.').last &&
           order.status != OrderStatus.delivered.toString().split('.').last;
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      _currentUserId = response.user?.id;
      _userEmail = email;
      await fetchUserOrders(); // تحديث الطلبات بعد تسجيل الدخول
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error logging in: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
      _currentUserId = null;
      _userEmail = null;
      _orders.clear();
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error logging out: $e');
      rethrow;
    }
  }
}
