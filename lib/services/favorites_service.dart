import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';
import '../models/product_model.dart';

class FavoritesService extends ChangeNotifier {
  static const String _favoritesKey = 'favorite_items';
  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  // الحصول على جميع المنتجات المفضلة
  List<FavoriteItem> getFavorites() {
    final String? favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.map((item) => FavoriteItem.fromJson(item)).toList();
  }

  // حفظ المنتجات المفضلة
  Future<void> saveFavorites(List<FavoriteItem> items) async {
    final String favoritesJson = json.encode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_favoritesKey, favoritesJson);
    notifyListeners();
  }

  // إضافة منتج إلى المفضلة
  Future<void> addToFavorites(ProductModel product) async {
    final items = getFavorites();
    if (!isProductFavorite(product.id)) {
      items.add(FavoriteItem(product: product));
      await saveFavorites(items);
      notifyListeners();
    }
  }

  // إزالة منتج من المفضلة
  Future<void> removeFromFavorites(String productId) async {
    final items = getFavorites();
    items.removeWhere((item) => item.product.id == productId);
    await saveFavorites(items);
    notifyListeners();
  }

  // التحقق مما إذا كان المنتج في المفضلة
  bool isProductFavorite(String productId) {
    return getFavorites().any((item) => item.product.id == productId);
  }

  // الحصول على عدد المنتجات المفضلة
  int getFavoritesCount() {
    return getFavorites().length;
  }

  // تفريغ المفضلة
  Future<void> clearFavorites() async {
    await _prefs.remove(_favoritesKey);
    notifyListeners();
  }

  // تبديل حالة المفضلة للمنتج
  Future<bool> toggleFavorite(ProductModel product) async {
    if (isProductFavorite(product.id)) {
      await removeFromFavorites(product.id);
      return false;
    } else {
      await addToFavorites(product);
      return true;
    }
  }
}
