import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  final SharedPreferences _prefs;

  CartService(this._prefs);

  // الحصول على جميع عناصر السلة
  List<CartItem> getCartItems() {
    final String? cartJson = _prefs.getString(_cartKey);
    if (cartJson == null) return [];

    final List<dynamic> cartList = json.decode(cartJson);
    return cartList.map((item) => CartItem.fromJson(item)).toList();
  }

  // حفظ عناصر السلة
  Future<void> saveCartItems(List<CartItem> items) async {
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
      items.add(CartItem(product: product, quantity: quantity));
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

  // حساب إجمالي السلة
  double getCartTotal() {
    return getCartItems().fold(0, (total, item) => total + item.totalPrice);
  }

  // الحصول على عدد العناصر في السلة
  int getItemCount() {
    return getCartItems().fold(0, (total, item) => total + item.quantity);
  }

  // تفريغ السلة
  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
    notifyListeners();
  }
}
