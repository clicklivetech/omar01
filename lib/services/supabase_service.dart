import 'package:supabase/supabase.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/banner.dart' as app_banner;
import '../services/logger_service.dart';

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
      final response = await client
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
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
      final response = await client
          .from('products')
          .select()
          .textSearch('name', query)
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error searching products: $e');
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
      final response = await client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting all categories: $e');
      return [];
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
}
