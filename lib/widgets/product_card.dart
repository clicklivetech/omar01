import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';
import '../utils/notifications.dart';
import 'package:provider/provider.dart';
import '../pages/product_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double? width;
  final double? height;

  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartService>();
    final favoritesService = context.watch<FavoritesService>();
    final isInFavorites = favoritesService.getFavorites().any((item) => item.product.id == product.id);
    final cartItem = cartService.getCartItems().firstWhere(
          (item) => item.product.id == product.id,
          orElse: () => CartItemModel(product: product, quantity: 0),
        );
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = width ?? (screenWidth > 600 ? 200 : screenWidth * 0.45);
    final cardHeight = height ?? (cardWidth * 1.5);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(product: product),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة المنتج مع زر المفضلة
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product_image_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.error_outline),
                          ),
                        ),
                      ),
                    ),
                    // زر المفضلة
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isInFavorites ? Icons.favorite : Icons.favorite_border,
                            color: isInFavorites ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () async {
                            try {
                              if (isInFavorites) {
                                await favoritesService.removeFromFavorites(product.id);
                                if (context.mounted) {
                                  AppNotifications.showSuccess(
                                    context,
                                    'تم إزالة المنتج من المفضلة',
                                  );
                                }
                              } else {
                                await favoritesService.addToFavorites(product);
                                if (context.mounted) {
                                  AppNotifications.showSuccess(
                                    context,
                                    'تم إضافة المنتج إلى المفضلة',
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppNotifications.showError(
                                  context,
                                  'حدث خطأ أثناء تحديث المفضلة',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // معلومات المنتج
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // اسم المنتج
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // السعر
                      Row(
                        children: [
                          if (product.discountPrice != null) ...[
                            Text(
                              '${product.discountPrice} جنيه',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.price} جنيه',
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12,
                              ),
                            ),
                          ] else
                            Text(
                              '${product.price} جنيه',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      // عداد الكمية وزر الطلب
                      Row(
                        children: [
                          // عداد الكمية
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: cartItem.quantity > 0
                                        ? () async {
                                            try {
                                              if (cartItem.quantity == 1) {
                                                await cartService.removeFromCart(product.id);
                                              } else {
                                                await cartService.updateQuantity(
                                                  product.id,
                                                  cartItem.quantity - 1,
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
                                          }
                                        : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Text(
                                    '${cartItem.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () async {
                                      try {
                                        if (cartItem.quantity == 0) {
                                          await cartService.addToCart(product);
                                        } else {
                                          await cartService.updateQuantity(
                                            product.id,
                                            cartItem.quantity + 1,
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
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // زر الطلب
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                try {
                                  if (cartItem.quantity == 0) {
                                    await cartService.addToCart(product);
                                    if (context.mounted) {
                                      AppNotifications.showSuccess(
                                        context,
                                        'تم إضافة المنتج إلى السلة',
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppNotifications.showError(
                                      context,
                                      'حدث خطأ أثناء إضافة المنتج',
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
