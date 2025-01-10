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
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // إنشاء حساب جديد
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  // تسجيل الخروج
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // الحصول على المستخدم الحالي
  static User? get currentUser => supabase.auth.currentUser;
}
