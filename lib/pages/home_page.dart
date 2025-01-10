import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../models/banner.dart' as app_banner;
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/app_state.dart';
import '../services/logger_service.dart';
import '../services/supabase_service.dart';
import 'search_page.dart';
import 'category_products_page.dart';
import 'categories_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<ProductModel> featuredProducts = [];
  List<ProductModel> dailyDeals = [];
  List<app_banner.Banner> banners = [];
  List<CategoryModel> homeCategories = [];
  bool isLoading = true;
  late final AnimationController _marqueeController;
  final List<String> promotions = [
    'خصم 30% على جميع الملابس!',
    'عروض حصرية لفترة محدودة',
    'توصيل مجاني للطلبات فوق 200 جنيه',
    'خصم إضافي 10% عند الدفع اونلاين',
    'اشتري 2 واحصل على 1 مجاناً',
  ];
  int _currentPromotionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentPromotionIndex = (_currentPromotionIndex + 1) % promotions.length;
        });
      }
    });
  }

  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // استخدام البيانات من AppState
      final appState = context.read<AppState>();
      featuredProducts = appState.featuredProducts;
      dailyDeals = appState.onSaleProducts;

      // تحميل البانرات
      final activeBanners = await SupabaseService.getActiveBanners();
      
      if (mounted) {
        setState(() {
          banners = activeBanners.cast<app_banner.Banner>();
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error loading home data', e, stackTrace);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    super.dispose();
  }

  Widget _buildBannerCarousel() {
    if (banners.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 24),
      child: FlutterCarousel(
        items: banners.map((banner) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          aspectRatio: 2.0,
          initialPage: 0,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الأقسام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoriesPage()),
                  );
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        if (homeCategories.isEmpty)
          const Center(
            child: Text(
              'لا توجد أقسام متاحة',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Container(
            height: 130,
            margin: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: homeCategories.length,
              itemBuilder: (context, index) {
                final category = homeCategories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsPage(
                          category: category,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: category.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductsList(String title, List<ProductModel> products) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsPage(
                        category: CategoryModel(
                          id: title,
                          name: title,
                          description: '',
                          imageUrl: '',
                          isHome: false,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ProductCard(
                  product: products[index],
                  width: 220,
                  height: 320,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyDeals() {
    if (dailyDeals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'عروض اليوم',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: dailyDeals.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: dailyDeals[index],
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // شريط التطبيق المرن
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SearchPage()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ابحث عن منتجات...',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(40),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: const Offset(1, 0),
                          ).animate(CurvedAnimation(
                            parent: _marqueeController,
                            curve: Curves.easeInOut,
                          )),
                          child: Center(
                            child: Text(
                              promotions[_currentPromotionIndex],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // محتوى الصفحة
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // البانر
                        _buildBannerCarousel(),

                        // الأقسام
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: _buildCategoriesSection(),
                        ),

                        // المنتجات المميزة
                        if (featuredProducts.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: _buildProductsList('منتجات مميزة', featuredProducts),
                          ),

                        // العروض اليومية
                        if (dailyDeals.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: _buildDailyDeals(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
