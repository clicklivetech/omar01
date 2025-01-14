import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

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
            label: Text(context.watch<AppState>().cartItemsCount.toString()),
            isLabelVisible: context.watch<AppState>().cartItemsCount > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'السلة',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
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
