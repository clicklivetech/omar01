class LoggerService {
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('❌ ERROR: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }

  static void info(String message) {
    print('ℹ️ INFO: $message');
  }

  static void success(String message) {
    print('✅ SUCCESS: $message');
  }

  static void warning(String message) {
    print('⚠️ WARNING: $message');
  }
}
