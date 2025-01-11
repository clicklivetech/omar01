import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerCarouselSample extends StatelessWidget {
  const BannerCarouselSample({super.key});

  @override
  Widget build(BuildContext context) {
    // نموذج بيانات البانر
    final List<Map<String, String>> banners = [
      {
        'id': '1',
        'title': 'عروض رمضان',
        'subtitle': 'خصومات تصل إلى 50%',
        'image_url': 'https://example.com/banner1.jpg',
        'background_color': '#6E58A8',
        'action_url': '/ramadan-offers',
      },
      {
        'id': '2',
        'title': 'منتجات جديدة',
        'subtitle': 'تسوق أحدث المنتجات',
        'image_url': 'https://example.com/banner2.jpg',
        'background_color': '#4CAF50',
        'action_url': '/new-products',
      },
    ];

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: FlutterCarousel(
        items: banners.map((banner) {
          return GestureDetector(
            onTap: () {
              if (banner['action_url']?.isNotEmpty ?? false) {
                debugPrint('Navigate to: ${banner['action_url']}');
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(
                  int.parse(
                    (banner['background_color'] ?? '#000000').replaceAll('#', '0xFF'),
                  ),
                ).withOpacity(0.8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // صورة البانر
                    CachedNetworkImage(
                      imageUrl: banner['image_url'] ?? '',
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
                    // طبقة اللون الشفافة
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(
                              int.parse(
                                (banner['background_color'] ?? '#000000').replaceAll('#', '0xFF'),
                              ),
                            ).withOpacity(0.1),
                            Color(
                              int.parse(
                                (banner['background_color'] ?? '#000000').replaceAll('#', '0xFF'),
                              ),
                            ).withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    // محتوى النص
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              banner['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                            if (banner['subtitle']?.isNotEmpty ?? false)
                              Text(
                                banner['subtitle'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black45,
                                    ),
                                  ],
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
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }
}
