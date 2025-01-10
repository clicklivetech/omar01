import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: const Color(0xFF6E58A8),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final favorites = appState.favoriteItems;

          return favorites.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد منتجات في المفضلة',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: favorites[index],
                      width: double.infinity,
                      height: double.infinity,
                    );
                  },
                );
        },
      ),
    );
  }
}
