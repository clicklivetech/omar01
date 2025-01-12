import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item_model.dart';
import '../utils/notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        backgroundColor: const Color(0xFF6E58A8),
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          // تهيئة السلة عند تحميل الصفحة
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cartService.initializeCart();
          });
          
          final cartItems = cartService.getCartItems();
          
          return Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'سلة التسوق فارغة',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('تسوق الآن'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartItems[index];
                          return CartItemCard(
                            cartItem: cartItem,
                            onUpdateQuantity: (newQuantity) async {
                              try {
                                if (newQuantity <= 0) {
                                  await cartService.removeFromCart(cartItem.productId);
                                  if (context.mounted) {
                                    AppNotifications.showSuccess(
                                      context,
                                      'تم إزالة المنتج من السلة',
                                    );
                                  }
                                } else {
                                  await cartService.updateQuantity(
                                    cartItem.productId,
                                    newQuantity,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AppNotifications.showError(
                                    context,
                                    'حدث خطأ أثناء تحديث الكمية',
                                  );
                                }
                              }
                            },
                            onRemove: () async {
                              try {
                                await cartService.removeFromCart(cartItem.productId);
                                if (context.mounted) {
                                  AppNotifications.showSuccess(
                                    context,
                                    'تم إزالة المنتج من السلة',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AppNotifications.showError(
                                    context,
                                    'حدث خطأ أثناء إزالة المنتج',
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
              ),
              if (cartItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المجموع:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartService.cartTotal.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E58A8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cartItems.isEmpty
                            ? null
                            : () {
                                // TODO: تنفيذ عملية الطلب مباشرة
                                final cartService = Provider.of<CartService>(context, listen: false);
                                final appState = Provider.of<AppState>(context, listen: false);
                                
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.amber),
                                        SizedBox(width: 8),
                                        Text('تأكيد الطلب'),
                                      ],
                                    ),
                                    content: const Text('هل أنت متأكد من إتمام الطلب؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            final subtotal = cartService.cartTotal;
                                            final deliveryFee = subtotal > 500 ? 0.0 : 30.0;

                                            await appState.createOrder(
                                              shippingAddress: 'التوصيل عند الباب',
                                              phone: '01234567890',
                                              deliveryFee: deliveryFee,
                                            );

                                            await cartService.clearCart();

                                            if (!context.mounted) return;
                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('تم إنشاء الطلب بنجاح'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            Navigator.pop(context);
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('حدث خطأ: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('تأكيد'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E58A8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_checkout, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'إتمام الطلب',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItemModel cartItem;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // صورة المنتج
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: cartItem.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 12),
            // تفاصيل المنتج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.price.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // التحكم في الكمية
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          onUpdateQuantity(cartItem.quantity - 1);
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.grey[600],
                      ),
                      Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          onUpdateQuantity(cartItem.quantity + 1);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF6E58A8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // زر الحذف
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }
}
