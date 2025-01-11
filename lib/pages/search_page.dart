import 'package:flutter/material.dart';
import 'dart:async';
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
  Timer? _debounce;
  
  // قائمة الاقتراحات الشائعة
  final List<String> _popularSearches = [
    'ملابس',
    'أحذية',
    'إكسسوارات',
    'عطور',
    'ساعات',
    'حقائب',
  ];

  // حالة البحث
  bool get _isEmpty => _searchQuery.isEmpty && _searchResults.isEmpty;
  bool get _hasResults => _searchResults.isNotEmpty;
  bool get _noResults => _searchQuery.isNotEmpty && _searchResults.isEmpty && !_isLoading;

  @override
  void initState() {
    super.initState();
    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'عمليات البحث الشائعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6E58A8),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) => ActionChip(
              label: Text(search),
              onPressed: () {
                _searchController.text = search;
                _onSearchChanged(search);
              },
              backgroundColor: Colors.grey[200],
              labelStyle: const TextStyle(color: Color(0xFF6E58A8)),
            )).toList(),
          ),
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
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6E58A8)),
                ),
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
