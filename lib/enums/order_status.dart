enum OrderStatus {
  pending,    // في انتظار التأكيد
  confirmed,  // تم تأكيد الطلب
  processing, // جاري التجهيز
  shipping,   // في الشحن
  delivered,  // تم التوصيل
  cancelled,  // ملغي
}
