import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = List.from(categories);
      } else {
        // تحويل النص المدخل إلى حروف عربية موحدة
        String normalizedQuery = _normalizeArabicText(query);
        
        filteredCategories = categories
            .where((category) {
              // تحويل اسم القسم إلى حروف عربية موحدة
              String normalizedName = _normalizeArabicText(category.name);
              return normalizedName.contains(normalizedQuery);
            })
            .toList();
      }
    });
  }

  // دالة لتوحيد شكل الحروف العربية
  String _normalizeArabicText(String input) {
    // تحويل الهمزات المختلفة إلى شكل موحد
    input = input.replaceAll('أ', 'ا');
    input = input.replaceAll('إ', 'ا');
    input = input.replaceAll('آ', 'ا');
    
    // تحويل التاء المربوطة إلى هاء
    input = input.replaceAll('ة', 'ه');
    
    // تحويل الياء المقصورة إلى ياء عادية
    input = input.replaceAll('ى', 'ي');
    
    // إزالة التشكيل
    input = input.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    
    // إزالة المسافات الزائدة
    input = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    return input.toLowerCase();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select();

      if (mounted) {
        setState(() {
          categories = (response as List<dynamic>)
              .map((data) => CategoryModel.fromJson(data))
              .toList();
          filteredCategories = List.from(categories);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6E58A8);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'الأقسام',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'البحث عن المنتجات',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterCategories,
            ),
          ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6E58A8)),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadCategories,
                color: primaryColor,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCategories.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 16,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: category.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: primaryColor.withOpacity(0.2),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: primaryColor.withOpacity(0.2),
                              child: const Icon(
                                Icons.category_outlined,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: primaryColor,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/category-products',
                            arguments: category,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
