import 'package:supabase/supabase.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart' as app_banner;
import '../services/logger_service.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../enums/order_status.dart';
import '../enums/payment_method.dart';

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
    } catch (e) {
      LoggerService.error('Error searching products: $e');
      return [];
    }
  }

  // الحصول على البانرات النشطة
  static Future<List<app_banner.BannerModel>> getActiveBanners() async {
    try {
      final response = await client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((item) => app_banner.BannerModel.fromJson(item))
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
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      return response;
    } catch (e) {
      LoggerService.error('Error in signInWithEmail: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info('Attempting to sign up user with email: $email');
      
      // إنشاء المستخدم
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      
      LoggerService.info('Auth response received: ${response.user?.id}');
      
      if (response.user == null) {
        LoggerService.error('User is null after signup');
        throw Exception('فشل إنشاء الحساب');
      }

      try {
        // إنشاء الملف الشخصي للمستخدم
        LoggerService.info('Creating profile for user: ${response.user!.id}');
        
        final profileData = {
          'id': response.user!.id,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        LoggerService.info('Profile data: $profileData');
        
        await client.from('profiles').insert(profileData);
        LoggerService.info('Profile created successfully');
      } catch (profileError) {
        LoggerService.error('Error creating profile: $profileError');
        // لا نريد إيقاف عملية التسجيل إذا فشل إنشاء الملف الشخصي
        // سيتم إنشاؤه لاحقاً عبر التريجر
      }

      LoggerService.info('User signed up successfully: ${response.user?.id}');
      return response;
    } catch (e) {
      LoggerService.error('Error in signUpWithEmail: $e');
      if (e.toString().contains('User already registered')) {
        throw Exception('هذا البريد الإلكتروني مسجل بالفعل');
      }
      throw Exception('حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة مرة أخرى');
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      LoggerService.error('Error in signOut: $e');
      rethrow;
    }
  }

  // تحديث حالة الطلب
  static Future<void> updateOrder({
    required String orderId,
    required String status,
  }) async {
    try {
      await client
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      
      LoggerService.info('Order status updated successfully: $orderId');
    } catch (e) {
      LoggerService.error('Error updating order status: $e');
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
        ).name,
        totalAmount: orderResponse['total_amount'].toDouble(),
        shippingAddress: orderResponse['shipping_address'],
        phone: orderResponse['phone'],
        createdAt: DateTime.parse(orderResponse['created_at']),
        updatedAt: DateTime.parse(orderResponse['updated_at']),
        deliveryFee: orderResponse['delivery_fee']?.toDouble() ?? 0.0,
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == orderResponse['payment_method'],
          orElse: () => PaymentMethod.cash,
        ).name,
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
    String? userId,
    required String shippingAddress,
    required String phone,
    required double totalAmount,
    required double deliveryFee,
    required List<CartItemModel> items,
  }) async {
    try {
      // 1. إنشاء الطلب الرئيسي
      final orderData = {
        'user_id': userId,
        'total_amount': totalAmount,
        'shipping_address': shippingAddress,
        'phone': phone,
        'delivery_fee': deliveryFee,
        'payment_method': PaymentMethod.cash.toString().split('.').last,
        'delivery_address': {
          'address': shippingAddress,
          'phone': phone,
        },
        'status': OrderStatus.pending.toString().split('.').last,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final orderResponse = await client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as String;

      // 2. إنشاء تفاصيل الطلب
      final orderItems = items.map((item) => {
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await client
          .from('order_items')
          .insert(orderItems);

      return orderId;
    } catch (e, stackTrace) {
      LoggerService.error('Error creating order: $e\n$stackTrace');
      rethrow;
    }
  }

  // الحصول على طلبات المستخدم
  static Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      LoggerService.info('Starting to fetch orders from Supabase for user: $userId');
      
      final response = await client
          .from('orders')
          .select('*, order_items(*, product:products(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      LoggerService.info('Received response from Supabase: ${response.toString()}');
      
      if (response == null) {
        LoggerService.info('No orders found for user: $userId');
        return [];
      }

      if (response is! List) {
        LoggerService.error('Unexpected response type: ${response.runtimeType}');
        return [];
      }

      final orders = response.map((order) {
        try {
          return OrderModel.fromJson(order);
        } catch (e) {
          LoggerService.error('Error parsing order: $e\nOrder data: $order');
          return null;
        }
      }).whereType<OrderModel>().toList();

      LoggerService.info('Successfully parsed ${orders.length} orders');
      return orders;
    } catch (e, stackTrace) {
      LoggerService.error('Error getting user orders: $e\nStackTrace: $stackTrace');
      return [];
    }
  }
}
