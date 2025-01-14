String formatPrice(dynamic price) {
  if (price == null) return '0 ₪';
  
  // تحويل السعر إلى رقم عشري إذا لم يكن كذلك
  double numericPrice = price is double ? price : double.parse(price.toString());
  
  // تنسيق السعر مع رقمين عشريين وإضافة رمز الشيكل
  return '${numericPrice.toStringAsFixed(2)} ₪';
}
