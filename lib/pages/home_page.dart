import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'categories_page.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);
      
      // Load banners
      final bannersResponse = await Supabase.instance.client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: true);

      // Load categories
      final categoriesResponse = await Supabase.instance.client
          .from('categories')
          .select()
          .eq('is_home', true)
          .order('created_at', ascending: true)
          .limit(10);

      setState(() {
        banners = (bannersResponse as List).map((item) => Banner.fromJson(item)).toList();
        categories = (categoriesResponse as List).map((item) => Category.fromJson(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading data: $e');
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
                  // Update the selected index in AppState to show Categories tab
                  context.read<AppState>().updateSelectedIndex(1);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  _buildBannerCarousel(),
                  _buildCategoriesSection(),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('الصفحة الرئيسية'),
                  ),
                ],
              ),
            ),
    );
  }
}