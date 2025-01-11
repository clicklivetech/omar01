import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_shimmer.dart';
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
  Timer? _debounce;
  List<String> _recentSearches = [];

  // حالة البحث
  bool get _isEmpty => _searchQuery.isEmpty && _searchResults.isEmpty;
  bool get _hasResults => _searchResults.isNotEmpty;
  bool get _noResults => _searchQuery.isNotEmpty && _searchResults.isEmpty && !_isLoading;

  @override
  void initState() {
    super.initState();
    _searchController.text = _searchQuery;
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // تحميل عمليات البحث السابقة
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  // حفظ عملية بحث جديدة
  Future<void> _saveSearch(String query) async {
    if (query.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(query); // إزالة إذا كان موجوداً
      _recentSearches.insert(0, query); // إضافة في البداية
      if (_recentSearches.length > 5) { // الاحتفاظ بآخر 5 عمليات بحث فقط
        _recentSearches.removeLast();
      }
    });
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  // مسح عمليات البحث السابقة
  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() {
      _recentSearches.clear();
    });
  }

  // تأخير البحث لتحسين الأداء
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });

    setState(() {
      _searchQuery = query;
    });
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
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
        _saveSearch(query); // حفظ عملية البحث
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء البحث. يرجى المحاولة مرة أخرى.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // بناء واجهة البحث الفارغة
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'عمليات البحث السابقة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E58A8),
                  ),
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: const Text('مسح'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) => ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _onSearchChanged(search);
                },
                backgroundColor: Colors.grey[100],
                labelStyle: const TextStyle(color: Color(0xFF6E58A8)),
                avatar: const Icon(Icons.history, size: 16),
              )).toList(),
            ),
          ],
          if (_recentSearches.isEmpty) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ابدأ البحث عن منتجاتك المفضلة',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // بناء واجهة عدم وجود نتائج
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على نتائج لـ "$_searchQuery"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'حاول البحث باستخدام كلمات مختلفة\nأو تحقق من الإملاء',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // بناء قائمة النتائج
  Widget _buildSearchResults() {
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
        return ProductCard(
          product: _searchResults[index],
        );
      },
    );
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
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'ابحث عن المنتجات...',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            hintTextDirection: TextDirection.rtl,
            suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6, // عدد العناصر الوهمية أثناء التحميل
                itemBuilder: (context, index) => const ProductCardShimmer(),
              )
            : _isEmpty
                ? _buildEmptyState()
                : _noResults
                    ? _buildNoResults()
                    : _buildSearchResults(),
      ),
    );
  }
}
