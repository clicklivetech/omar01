import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/banner_model.dart';

class BannerCarouselSample extends StatefulWidget {
  const BannerCarouselSample({super.key});

  @override
  State<BannerCarouselSample> createState() => _BannerCarouselSampleState();
}

class _BannerCarouselSampleState extends State<BannerCarouselSample> {
  final _supabase = Supabase.instance.client;
  List<BannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final response = await _supabase
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: true);

      setState(() {
        _banners = (response as List)
            .map((banner) => BannerModel.fromJson(banner))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading banners: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: FlutterCarousel(
        items: _banners.map((banner) {
          return GestureDetector(
            onTap: () {
              if (banner.actionUrl.isNotEmpty) {
                debugPrint('Navigate to: ${banner.actionUrl}');
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(
                  int.parse(
                    banner.backgroundColor.replaceAll('#', '0xFF'),
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
                    // طبقة اللون الشفافة
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(
                              int.parse(
                                banner.backgroundColor.replaceAll('#', '0xFF'),
                              ),
                            ).withOpacity(0.1),
                            Color(
                              int.parse(
                                banner.backgroundColor.replaceAll('#', '0xFF'),
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
                              banner.title,
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
                            if (banner.subtitle.isNotEmpty)
                              Text(
                                banner.subtitle,
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
