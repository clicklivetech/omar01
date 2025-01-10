import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/category_model.dart';
import 'category_page.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأقسام'),
        backgroundColor: const Color(0xFF6E58A8),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: SupabaseService.getAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Categories error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('حدث خطأ: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Force a rebuild to retry
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد أقسام متاحة'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.name),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(category: category.name),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
