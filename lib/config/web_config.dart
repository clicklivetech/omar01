import 'package:flutter/foundation.dart';

class WebConfig {
  static bool get isWeb => kIsWeb;
  
  static String get supabaseUrl => 'https://vvjgjuvcbqnrzbjkcloa.supabase.co';
  
  static String get supabaseAnonKey => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2amdqdXZjYnFucnpiamtjbG9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMjM0MjMsImV4cCI6MjA0ODY5OTQyM30.dAu01n_o4KOZ9L8W42U8Qd6XER4bH2SuXzwWZt09t7Q';

  // CORS configuration
  static Map<String, String> get headers => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
      };
}
