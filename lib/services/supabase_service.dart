import 'package:supabase_flutter/supabase_flutter.dart';

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
      return await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('خطأ في تسجيل الدخول: $e');
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

      // 1. إنشاء المستخدم في نظام المصادقة
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw 'فشل في إنشاء الحساب';
      }

      print('تم إنشاء المستخدم بنجاح: ${response.user!.id}');

      try {
        // 2. إنشاء سجل في جدول profiles
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': '',
          'address': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        print('تم إنشاء الملف الشخصي بنجاح');
        return response;
      } catch (profileError) {
        print('خطأ في إنشاء الملف الشخصي: $profileError');
        // لا نحاول حذف المستخدم لأننا لا نملك صلاحيات admin
        throw 'فشل في إنشاء الملف الشخصي: $profileError';
      }
    } catch (e) {
      print('خطأ في التسجيل: $e');
      rethrow;
    }
  }

  // تسجيل الخروج
  static Future<void> signOut() async {
    await supabase.auth.signOut();
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
      return response;
    } catch (e) {
      print('خطأ في جلب معلومات المستخدم: $e');
      return null;
    }
  }
}
