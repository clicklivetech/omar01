import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_page.dart';
import 'category_list_page.dart';
import 'cart_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<AppState>().currentPageIndex;

    final pages = [
      const HomePage(),
      CategoryListPage(),
      const CartPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
