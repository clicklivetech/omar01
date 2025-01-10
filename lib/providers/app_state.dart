import 'package:flutter/foundation.dart';
import '../models/product.dart';

class AppState extends ChangeNotifier {
  List<Product> _cartItems = [];
  List<Product> _favoriteItems = [];
  List<Product> _products = []; // سيتم تعبئتها من Supabase لاحقاً

  List<Product> get cartItems => _cartItems;
  List<Product> get favoriteItems => _favoriteItems;
  List<Product> get products => _products;
  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<Product> get onSaleProducts => _products.where((p) => p.isOnSale).toList();

  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.price);

  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (_favoriteItems.contains(product)) {
      _favoriteItems.remove(product);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _favoriteItems.contains(product);
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
