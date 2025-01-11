import 'package:supabase/supabase.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/banner.dart' as app_banner;
import '../services/logger_service.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';
import '../enums/order_status.dart';

class SupabaseService {
  static final client = SupabaseClient(
    'https://vvjgjuvcbqnrzbjkcloa.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2amdqdXZjYnFucnpiamtjbG9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMjM0MjMsImV4cCI6MjA0ODY5OTQyM30.dAu01n_o4KOZ9L8W42U8Qd6XER4bH2SuXzwWZt09t7Q',
  );

  // الحصول على المنتجات المميزة
  static Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting featured products: $e');
      return [];
    }
  }

  // الحصول على العروض اليومية
  static Future<List<ProductModel>> getDailyDeals() async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('daily_deals', true)
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting daily deals: $e');
      return [];
    }
  }

  // الحصول على منتجات فئة معينة
  static Future<List<ProductModel>> getCategoryProducts(String categoryId) async {
    try {
      LoggerService.info('Fetching products for category: $categoryId');
      
      // تحويل معرف القسم إلى UUID
      final response = await client
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('created_at');

      LoggerService.info('Products response received: ${response.length} items');

      return (response as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error getting category products: $e\n$stackTrace');
      rethrow;
    }
  }

  // البحث عن المنتجات
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      LoggerService.info('Searching for products with query: $query');
      
      final response = await client
          .from('products')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_active', true)
          .order('created_at');

      LoggerService.info('Found ${response.length} products matching query: $query');
      
      return (response as List).map((item) => ProductModel.fromJson(item)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error searching products: $e', e, stackTrace);
      return [];
    }
  }

  // الحصول على البانرات النشطة
  static Future<List<app_banner.Banner>> getActiveBanners() async {
    try {
      final response = await client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((item) => app_banner.Banner.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting banners: $e');
      return [];
    }
  }

  // الحصول على الفئات الرئيسية
  static Future<List<CategoryModel>> getHomeCategories() async {
    try {
      final response = await client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting home categories: $e');
      return [];
    }
  }

  // الحصول على جميع الفئات
  static Future<List<CategoryModel>> getAllCategories() async {
    try {
      LoggerService.info('Fetching categories from Supabase...');
      
      final response = await client
          .from('categories')
          .select('id, name, description, image_url, is_home, created_at, updated_at')
          .order('created_at');

      LoggerService.info('Categories response received: ${response.length} items');

      return (response as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error getting all categories: $e\n$stackTrace');
      rethrow;
    }
  }

  // الحصول على فئة معينة
  static Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final response = await client
          .from('categories')
          .select()
          .eq('id', id)
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      LoggerService.error('Error getting category: $e');
      return null;
    }
  }

  // Authentication methods
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      LoggerService.error('Error signing in: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      LoggerService.error('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      LoggerService.error('Error signing out: $e');
      rethrow;
    }
  }

  // تحديث حالة الطلب
  static Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await client
          .from('orders')
          .update({
            'status': newStatus.name,
            'updated_at': DateTime.now().toIso8601String(),
            'cancelled_at': newStatus == OrderStatus.cancelled ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', orderId);
      
      LoggerService.info('Order status updated successfully: $orderId to ${newStatus.name}');
    } catch (e) {
      LoggerService.error('Error updating order status: $e');
      rethrow;
    }
  }

  // إلغاء الطلب
  static Future<void> cancelOrder(String orderId) async {
    try {
      await client
          .from('orders')
          .update({
            'status': OrderStatus.cancelled.name,
            'updated_at': DateTime.now().toIso8601String(),
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      
      LoggerService.info('Order cancelled successfully: $orderId');
    } catch (e) {
      LoggerService.error('Error cancelling order: $e');
      rethrow;
    }
  }

  // الحصول على تفاصيل الطلب
  static Future<OrderModel?> getOrderDetails(String orderId) async {
    try {
      // الحصول على بيانات الطلب
      final orderResponse = await client
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      // الحصول على عناصر الطلب
      final itemsResponse = await client
          .from('order_items')
          .select('*, products(*)')  // اختيار كل البيانات من order_items وبيانات المنتجات المرتبطة
          .eq('order_id', orderId);

      // تحويل البيانات إلى نموذج OrderModel
      final List<OrderItem> items = (itemsResponse as List).map((item) {
        return OrderItem(
          id: item['id'] as String,
          orderId: item['order_id'] as String,
          productId: item['product_id'] as String,
          quantity: item['quantity'] as int,
          price: (item['price'] as num).toDouble(),
          createdAt: DateTime.parse(item['created_at'] as String),
        );
      }).toList();

      return OrderModel(
        id: orderResponse['id'],
        userId: orderResponse['user_id'],
        status: OrderStatus.values.firstWhere(
          (e) => e.name == orderResponse['status'],
          orElse: () => OrderStatus.pending,
        ),
        totalAmount: orderResponse['total_amount'].toDouble(),
        shippingAddress: orderResponse['shipping_address'],
        phone: orderResponse['phone'],
        createdAt: DateTime.parse(orderResponse['created_at']),
        updatedAt: DateTime.parse(orderResponse['updated_at']),
        deliveryFee: orderResponse['delivery_fee']?.toDouble() ?? 0.0,
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == orderResponse['payment_method'],
          orElse: () => PaymentMethod.cash,
        ),
        items: items,
        cancelledAt: orderResponse['cancelled_at'] != null
            ? DateTime.parse(orderResponse['cancelled_at'])
            : null,
        oldStatus: orderResponse['old_status'],
      );
    } catch (e) {
      LoggerService.error('Error getting order details: $e');
      return null;
    }
  }

  // إنشاء طلب جديد
  static Future<String> createOrder({
    required String userId,
    required String shippingAddress,
    required String phone,
    required double totalAmount,
    required double deliveryFee,
    required List<CartItem> items,
  }) async {
    try {
      // 1. إنشاء الطلب
      final orderResponse = await client
          .from('orders')
          .insert({
            'user_id': userId,
            'status': OrderStatus.pending.name,
            'total_amount': totalAmount,
            'shipping_address': shippingAddress,
            'phone': phone,
            'delivery_fee': deliveryFee,
            'payment_method': PaymentMethod.cash.name,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final orderId = orderResponse['id'] as String;

      // 2. إنشاء عناصر الطلب
      final orderItems = items.map((item) => {
        'order_id': orderId,
        'product_id': item.id,
        'quantity': item.quantity,
        'price': item.price,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await client
          .from('order_items')
          .insert(orderItems);

      LoggerService.info('Order created successfully: $orderId');
      return orderId;
    } catch (e, stackTrace) {
      LoggerService.error('Error creating order', e, stackTrace);
      rethrow;
    }
  }

  // الحصول على طلبات المستخدم
  static Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final response = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((order) => OrderModel.fromJson(order)).toList();
    } catch (e) {
      LoggerService.error('Error getting user orders: $e');
      return [];
    }
  }
}
