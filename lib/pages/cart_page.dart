import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../utils/notifications.dart';

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
          if (cartService.getCartItems().isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'السلة فارغة',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartService.getCartItems().length,
                  itemBuilder: (context, index) {
                    final cartItem = cartService.getCartItems()[index];
                    return CartItemCard(
                      cartItem: cartItem,
                      onRemove: () {
                        cartService.removeFromCart(cartItem.product.id);
                        AppNotifications.showSuccess(
                          context,
                          'تم إزالة المنتج من السلة',
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
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
                          '${cartService.getCartTotal().toStringAsFixed(2)} ج.م',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E58A8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // TODO: Implement checkout
                        },
                        child: const Text('اتمام الشراء'),
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
  final CartItem cartItem;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.product.price.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
