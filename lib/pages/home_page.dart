import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'categories_page.dart';
import '../widgets/product_card.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Banner {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? backgroundColor;
  final String? actionUrl;
  final bool isActive;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  Banner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.backgroundColor,
    this.actionUrl,
    required this.isActive,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['image_url'],
      backgroundColor: json['background_color'],
      actionUrl: json['action_url'],
      isActive: json['is_active'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? description;
  final String imageUrl;
  final bool isHome;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrl,
    required this.isHome,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      isHome: json['is_home'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<Banner> banners = [];
  List<Category> categories = [];
  List<ProductModel> featuredProducts = [];
  List<ProductModel> specialOffers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('Started loading data...');
      setState(() => isLoading = true);
      
      // Load banners
      print('Fetching banners...');
      final bannersResponse = await Supabase.instance.client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: true);
      print('Banners Response: $bannersResponse');

      // Load categories
      print('Fetching categories...');
      final categoriesResponse = await Supabase.instance.client
          .from('categories')
          .select()
          .eq('is_home', true)
          .order('created_at', ascending: true)
          .limit(10);
      print('Categories Response: $categoriesResponse');

      // Load featured products
      print('Fetching featured products...');
      final productsResponse = await Supabase.instance.client
          .from('products')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);
      print('Featured Products Response: $productsResponse');
      print('Featured Products Count: ${productsResponse.length}');

      // Load special offers
      print('Fetching special offers...');
      final specialOffersResponse = await Supabase.instance.client
          .from('products')
          .select()
          .not('discount_price', 'is', null)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);
      print('Special Offers Response: $specialOffersResponse');
      print('Special Offers Count: ${specialOffersResponse.length}');

      setState(() {
        try {
          print('Processing banners...');
          banners = (bannersResponse as List).map((item) => Banner.fromJson(item)).toList();
          print('Processed Banners Count: ${banners.length}');
          
          print('Processing categories...');
          categories = (categoriesResponse as List).map((item) => Category.fromJson(item)).toList();
          print('Processed Categories Count: ${categories.length}');
          
          print('Processing featured products...');
          featuredProducts = (productsResponse as List).map((item) {
            print('Processing featured product: $item');
            return ProductModel.fromJson(item);
          }).toList();
          print('Processed Featured Products Count: ${featuredProducts.length}');
          
          print('Processing special offers...');
          specialOffers = (specialOffersResponse as List).map((item) {
            print('Processing special offer: $item');
            return ProductModel.fromJson(item);
          }).toList();
          print('Processed Special Offers Count: ${specialOffers.length}');
          
          isLoading = false;
          print('Data loading completed successfully');
        } catch (e) {
          print('Error during data processing: $e');
          rethrow;
        }
      });
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      setState(() => isLoading = false);
    }
  }

  Widget _buildBannerCarousel() {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: FlutterCarousel(
        items: banners.map((banner) {
          return GestureDetector(
            onTap: () {
              if (banner.actionUrl != null) {
                // Handle banner tap action here
                debugPrint('Banner tapped: ${banner.actionUrl}');
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: banner.backgroundColor != null 
                    ? Color(int.parse(banner.backgroundColor!.replaceAll('#', '0xFF')))
                    : Colors.grey[200],
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                    if (banner.title.isNotEmpty || banner.subtitle != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (banner.subtitle != null)
                                Text(
                                  banner.subtitle!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true,
          viewportFraction: 0.85,
          aspectRatio: 16/9,
          initialPage: 0,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الأقسام',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesPage(),
                    ),
                  );
                },
                child: const Text('المزيد'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          category.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductsSection() {
    if (featuredProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'منتجات مميزة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to featured products page
                },
                child: const Text('المزيد'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredProducts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ProductCard(
                  product: featuredProducts[index],
                  width: 200,
                  height: 300,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن منتجات...',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            // Implement search functionality
            debugPrint('Searching for: $value');
            // TODO: Navigate to search results page
          }
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOffersSection() {
    if (specialOffers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'عروض خاصة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to special offers page
                },
                child: const Text('المزيد'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: specialOffers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ProductCard(
                  product: specialOffers[index],
                  width: 200,
                  height: 300,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? _buildShimmerLoading()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    _buildBannerCarousel(),
                    _buildCategoriesSection(),
                    _buildSpecialOffersSection(),
                    _buildFeaturedProductsSection(),
                  ],
                ),
              ),
      ),
    );
  }
}