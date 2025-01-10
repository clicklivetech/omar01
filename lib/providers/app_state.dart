import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class AppState extends ChangeNotifier {
  final List<ProductModel> _cartItems = [];
  final List<ProductModel> _favoriteItems = [];
  final List<ProductModel> _products = []; // سيتم تعبئتها من Supabase لاحقاً

  int _currentPageIndex = 0;

  List<ProductModel> get cartItems => _cartItems;
  List<ProductModel> get favoriteItems => _favoriteItems;
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<ProductModel> get onSaleProducts => _products.where((p) => p.hasDiscount).toList();

  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.finalPrice);

  int get currentPageIndex => _currentPageIndex;

  void addToCart(ProductModel product) {
    if (!_cartItems.contains(product)) {
      _cartItems.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(ProductModel product) {
    _cartItems.remove(product);
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
}
