import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    await dotenv.load();
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase client not initialized');
    }
    return _client!;
  }

  // مثال على دالة للحصول على البيانات
  static Future<List<Map<String, dynamic>>> getData(String tableName) async {
    try {
      final response = await client
          .from(tableName)
          .select();
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // مثال على دالة لإضافة بيانات
  static Future<void> insertData(String tableName, Map<String, dynamic> data) async {
    try {
      await client
          .from(tableName)
          .insert(data);
    } catch (e) {
      throw Exception('Failed to insert data: $e');
    }
  }
}
