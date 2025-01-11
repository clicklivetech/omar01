import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  final SharedPreferences _prefs;

  CartService(this._prefs);

  // الحصول على جميع عناصر السلة
  List<CartItemModel> getCartItems() {
    final String? cartJson = _prefs.getString(_cartKey);
    if (cartJson == null) return [];

    final List<dynamic> cartList = json.decode(cartJson);
    final List<CartItemModel> items = [];
    
    for (var item in cartList) {
      // Get the product from your product service or database
      // This is a placeholder - you need to implement the actual product retrieval
      final productJson = item['product'] as Map<String, dynamic>;
      final product = ProductModel.fromJson(productJson);
      items.add(CartItemModel.fromJson(item, product));
    }
    
    return items;
  }

  // حساب السعر الإجمالي للسلة
  double get cartTotal {
    return getCartItems().fold(0, (total, item) {
      final price = item.product.discountPrice ?? item.product.price;
      return total + (price * item.quantity);
    });
  }

  // عدد العناصر في السلة
  int get itemCount {
    return getCartItems().fold(0, (total, item) => total + item.quantity);
  }

  // الحصول على كمية منتج معين في السلة
  int getItemQuantity(String productId) {
    final items = getCartItems();
    final item = items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItemModel(
        product: ProductModel(
          id: productId,
          name: '',
          description: '',
          price: 0,
          categoryId: '',
          stockQuantity: 0,
          imageUrl: '',
          isFeatured: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          unit: 'piece',
          dailyDeals: false,
        ), 
        quantity: 0
      ),
    );
    return item.quantity;
  }

  // حفظ عناصر السلة
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final String cartJson = json.encode(items.map((item) => item.toJson()).toList());
    await _prefs.setString(_cartKey, cartJson);
    notifyListeners();
  }

  // إضافة منتج إلى السلة
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final items = getCartItems();
    final existingItemIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      // تحديث الكمية إذا كان المنتج موجود بالفعل
      final existingItem = items[existingItemIndex];
      items[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // إضافة منتج جديد
      items.add(CartItemModel(product: product, quantity: quantity));
    }

    await saveCartItems(items);
    notifyListeners();
  }

  // إزالة منتج من السلة
  Future<void> removeFromCart(String productId) async {
    final items = getCartItems();
    items.removeWhere((item) => item.product.id == productId);
    await saveCartItems(items);
    notifyListeners();
  }

  // تحديث كمية منتج في السلة
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final items = getCartItems();
    final index = items.indexWhere((item) => item.product.id == productId);
    
    if (index != -1) {
      items[index] = items[index].copyWith(quantity: quantity);
      await saveCartItems(items);
      notifyListeners();
    }
  }

  // تفريغ السلة
  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
    notifyListeners();
  }
}
