import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import '../services/logger_service.dart';
import '../widgets/product_card.dart';

class CategoryProductsPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      LoggerService.info('Loading products for category: ${widget.category.id} (${widget.category.name})');
      
      final categoryProducts = await SupabaseService.getCategoryProducts(widget.category.id);
      
      LoggerService.info('Loaded ${categoryProducts.length} products for category ${widget.category.name}');
      
      setState(() {
        products = categoryProducts;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      LoggerService.error('Error loading products for category ${widget.category.name}', e, stackTrace);
      setState(() => isLoading = false);
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل المنتجات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E58A8),
        title: Text(
          widget.category.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد منتجات في ${widget.category.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    },
                  ),
      ),
    );
  }
}
