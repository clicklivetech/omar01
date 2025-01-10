import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';
import '../utils/notifications.dart';
import 'package:provider/provider.dart';
import '../pages/product_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double width;
  final double height;

  const ProductCard({
    super.key,
    required this.product,
    this.width = 200,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartService>();
    final favoritesService = context.watch<FavoritesService>();
    final isInCart = cartService.getCartItems().any((item) => item.product.id == product.id);
    final isInFavorites = favoritesService.getFavorites().any((item) => item.product.id == product.id);

    return SizedBox(
      width: width,
      height: height,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج مع زر المفضلة
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
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
                  ),
                  // زر المفضلة
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isInFavorites ? Icons.favorite : Icons.favorite_border,
                          color: isInFavorites ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          if (isInFavorites) {
                            favoritesService.removeFromFavorites(product.id);
                            AppNotifications.showSuccess(
                              context,
                              'تم إزالة المنتج من المفضلة',
                            );
                          } else {
                            favoritesService.addToFavorites(product);
                            AppNotifications.showSuccess(
                              context,
                              'تم إضافة المنتج إلى المفضلة',
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // معلومات المنتج
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم المنتج
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // السعر
                      Row(
                        children: [
                          if (product.discountPrice != null) ...[
                            Text(
                              '${product.discountPrice} جنيه',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${product.price} جنيه',
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 14,
                              ),
                            ),
                          ] else
                            Text(
                              '${product.price} جنيه',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      // زر إضافة/إزالة من السلة
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isInCart
                              ? () {
                                  cartService.removeFromCart(product.id);
                                  AppNotifications.showSuccess(
                                    context,
                                    'تم إزالة المنتج من السلة',
                                  );
                                }
                              : () {
                                  cartService.addToCart(product);
                                  AppNotifications.showSuccess(
                                    context,
                                    'تم إضافة المنتج إلى السلة',
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInCart
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            isInCart ? 'إزالة من السلة' : 'إضافة للسلة',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
