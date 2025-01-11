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
    return cartList.map((item) => CartItemModel(
      id: item['id'],
      productId: item['product_id'],
      quantity: item['quantity'],
      price: item['price'].toDouble(),
      name: item['name'],
      imageUrl: item['image_url'],
    )).toList();
  }

  // حساب السعر الإجمالي للسلة
  double get cartTotal {
    return getCartItems().fold(0, (total, item) {
      return total + (item.price * item.quantity);
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
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        productId: productId,
        quantity: 0,
        price: 0,
        name: '',
        imageUrl: '',
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
    final existingItemIndex = items.indexWhere((item) => item.productId == product.id);

    if (existingItemIndex != -1) {
      // تحديث الكمية إذا كان المنتج موجود بالفعل
      final existingItem = items[existingItemIndex];
      items[existingItemIndex] = CartItemModel(
        id: existingItem.id,
        productId: existingItem.productId,
        quantity: existingItem.quantity + quantity,
        price: product.price,
        name: product.name,
        imageUrl: product.imageUrl,
      );
    } else {
      // إضافة منتج جديد
      items.add(CartItemModel(
        productId: product.id,
        quantity: quantity,
        price: product.price,
        name: product.name,
        imageUrl: product.imageUrl,
      ));
    }

    await saveCartItems(items);
    notifyListeners();
  }

  // إزالة منتج من السلة
  Future<void> removeFromCart(String productId) async {
    final items = getCartItems();
    items.removeWhere((item) => item.productId == productId);
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
    final index = items.indexWhere((item) => item.productId == productId);
    
    if (index != -1) {
      final item = items[index];
      items[index] = CartItemModel(
        id: item.id,
        productId: item.productId,
        quantity: quantity,
        price: item.price,
        name: item.name,
        imageUrl: item.imageUrl,
      );
      await saveCartItems(items);
      notifyListeners();
    }
  }

  // مسح السلة
  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
    notifyListeners();
  }
}
