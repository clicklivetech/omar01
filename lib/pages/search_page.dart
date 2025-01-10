import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/product_card.dart';
import '../models/product_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await SupabaseService.searchProducts(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E58A8),
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'ابحث عن منتجات...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            _performSearch(value);
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_searchQuery.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ابحث عن منتجاتك المفضلة',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (_searchResults.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد نتائج',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}
