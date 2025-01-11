class ArabicUtils {
  static String normalizeArabicText(String input) {
    const arabic = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'ة': 'ه',
      'ى': 'ي',
      'ئ': 'ي',
      'ؤ': 'و',
      'ـ': '',
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String normalized = input.trim().toLowerCase();
    arabic.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    // إزالة التشكيل
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    
    // إزالة المسافات المتعددة
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    return normalized;
  }

  static bool arabicTextContains(String source, String query) {
    final normalizedSource = normalizeArabicText(source);
    final normalizedQuery = normalizeArabicText(query);
    return normalizedSource.contains(normalizedQuery);
  }

  static List<T> filterArabicText<T>(
    List<T> items,
    String query,
    String Function(T) textSelector,
  ) {
    if (query.isEmpty) return items;

    return items.where((item) {
      final text = textSelector(item);
      return arabicTextContains(text, query);
    }).toList();
  }
}
