import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/banner.dart' as app_banner;
import '../services/logger_service.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://vvjgjuvcbqnrzbjkcloa.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2amdqdXZjYnFucnpiamtjbG9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMjM0MjMsImV4cCI6MjA0ODY5OTQyM30.dAu01n_o4KOZ9L8W42U8Qd6XER4bH2SuXzwWZt09t7Q',
    );
  }

  // تسجيل الدخول
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw 'فشل في تسجيل الدخول';
      }

      return response;
    } catch (e) {
      LoggerService.error('Error signing in: $e');
      rethrow;
    }
  }

  // إنشاء حساب جديد
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (password.length < 6) {
        throw 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'فشل في إنشاء الحساب';
      }

      try {
        // إنشاء الملف الشخصي للمستخدم
        await supabase.from('profiles').upsert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': '',
          'address': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (profileError) {
        LoggerService.error('Error creating profile: $profileError');
        // لا نحاول حذف المستخدم لأننا لا نملك صلاحيات admin
        throw 'فشل في إنشاء الملف الشخصي: $profileError';
      }

      return response;
    } catch (e) {
      LoggerService.error('Error signing up: $e');
      rethrow;
    }
  }

  // تسجيل الخروج
  static Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      LoggerService.error('Error signing out: $e');
      rethrow;
    }
  }

  // الحصول على المستخدم الحالي
  static User? get currentUser => supabase.auth.currentUser;

  // الحصول على معلومات المستخدم
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (response == null) {
        LoggerService.error('User profile not found');
        return null;
      }

      return response;
    } catch (e) {
      LoggerService.error('Error getting user profile: $e');
      return null;
    }
  }

  // الحصول على المنتجات المميزة
  static Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('created_at');

      if (response.status != 200) {
        throw PostgrestException(
          message: response.statusText ?? 'Unknown error',
          code: response.status.toString(),
        );
      }

      if (response.data is! List) {
        LoggerService.error('Invalid response format for featured products');
        return [];
      }

      return (response.data as List)
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
      final response = await supabase
          .from('products')
          .select()
          .eq('daily_deals', true)
          .eq('is_active', true)
          .order('created_at');

      if (response.status != 200) {
        throw PostgrestException(
          message: response.statusText ?? 'Unknown error',
          code: response.status.toString(),
        );
      }

      if (response.data is! List) {
        LoggerService.error('Invalid response format for daily deals');
        return [];
      }

      return (response.data as List)
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
      final response = await supabase
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('created_at');

      if (response.status != 200) {
        throw PostgrestException(
          message: response.statusText ?? 'Unknown error',
          code: response.status.toString(),
        );
      }

      if (response.data is! List) {
        LoggerService.error('Invalid response format for category products');
        return [];
      }

      return (response.data as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting category products: $e');
      return [];
    }
  }

  // البحث عن المنتجات
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name');

      if (response.status != 200) {
        throw PostgrestException(
          message: response.statusText ?? 'Unknown error',
          code: response.status.toString(),
        );
      }

      if (response.data is! List) {
        LoggerService.error('Invalid response format for search products');
        return [];
      }

      return (response.data as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error searching products: $e');
      return [];
    }
  }

  // الحصول على البنرات النشطة
  static Future<List<app_banner.Banner>> getActiveBanners() async {
    try {
      final response = await supabase
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: true);

      if (response.status != 200) {
        throw PostgrestException(
          message: response.statusText ?? 'Unknown error',
          code: response.status.toString(),
        );
      }

      if (response.data is! List) {
        LoggerService.error('Invalid response format for active banners');
        return [];
      }

      return (response.data as List)
          .map((item) => app_banner.Banner.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting active banners: $e');
      return [];
    }
  }

  // الحصول على الأقسام الرئيسية
  static Future<List<CategoryModel>> getHomeCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('is_home', true)
          .order('created_at');

      if (response.status != 200) {
        throw PostgrestException(
          message: response.statusText ?? 'Unknown error',
          code: response.status.toString(),
        );
      }

      if (response.data is! List) {
        LoggerService.error('Invalid response format for home categories');
        return [];
      }

      return (response.data as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting home categories: $e');
      return [];
    }
  }

  // الحصول على جميع الأقسام
  static Future<List<CategoryModel>> getAllCategories() async {
    try {
      LoggerService.info('Fetching all categories...');
      final response = await supabase
          .from('categories')
          .select()
          .order('created_at');

      LoggerService.info('Categories response: $response');
      return (response as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error getting all categories: $e\n$stackTrace');
      return [];
    }
  }

  // الحصول على قسم محدد
  static Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('id', id)
          .single();

      if (response.status != 200) {
        throw PostgrestException(
          message: response.statusText ?? 'Unknown error',
          code: response.status.toString(),
        );
      }

      if (response.data is! Map) {
        LoggerService.error('Invalid response format for category');
        return null;
      }

      return CategoryModel.fromJson(response.data);
    } catch (e) {
      LoggerService.error('Error getting category: $e');
      return null;
    }
  }
}
