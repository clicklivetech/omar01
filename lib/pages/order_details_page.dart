import 'package:flutter/material.dart';
import 'package:omar01/models/order_model.dart' as order_model;
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import '../enums/order_status.dart';

class OrderDetailsPage extends StatelessWidget {
  final order_model.OrderModel order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details #${order.id}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfo(),
                  const SizedBox(height: 16),
                  _buildProductsList(context),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحالة: ${_getArabicStatus(OrderStatus.values.firstWhere(
                (e) => e.toString().split('.').last == order.status))}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('طريقة الدفع: نقداً عند الاستلام',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('المبلغ الإجمالي: ${order.totalAmount.toStringAsFixed(2)} ريال',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('التاريخ: ${_formatDate(order.createdAt)}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('عنوان التوصيل: ${order.shippingAddress}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('رقم الهاتف: ${order.phone}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('المنتجات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return ListTile(
                leading: item.product?.imageUrl != null && item.product!.imageUrl.isNotEmpty
                  ? Image.network(
                      item.product!.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    )
                  : const Icon(Icons.image_not_supported),
                title: Text(item.product?.name ?? 'منتج غير معروف'),
                subtitle: Text('السعر: ${item.price.toStringAsFixed(2)} ريال'),
                trailing: Text('الكمية: ${item.quantity}'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final appState = context.read<AppState>();
    final canCancel = appState.canCancelOrder(order);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (canCancel) // فقط إذا كان يمكن إلغاء الطلب
            ElevatedButton.icon(
              onPressed: () async {
                await _cancelOrder(context);
              },
              icon: const Icon(Icons.cancel),
              label: const Text('إلغاء الطلب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('العودة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E58A8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context) async {
    try {
      // إلغاء الطلب في Supabase
      await SupabaseService.cancelOrder(order.id);

      if (!context.mounted) return;
      
      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الطلب'),
          backgroundColor: Colors.red,
        ),
      );

      // العودة إلى الصفحة السابقة
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إلغاء الطلب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getArabicStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'في انتظار التأكيد';
      case OrderStatus.confirmed:
        return 'تم تأكيد الطلب';
      case OrderStatus.processing:
        return 'جاري التجهيز';
      case OrderStatus.shipping:
        return 'في الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
      default:
        return status.toString();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
