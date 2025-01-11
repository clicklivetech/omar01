import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartService>();
    final favoritesService = context.watch<FavoritesService>();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'الأقسام',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(cartService.getItemCount().toString()),
            isLabelVisible: cartService.getItemCount() > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'السلة',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(favoritesService.getFavoritesCount().toString()),
            isLabelVisible: favoritesService.getFavoritesCount() > 0,
            child: const Icon(Icons.favorite),
          ),
          label: 'المفضلة',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }
}
