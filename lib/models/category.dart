class Category {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isHome;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isHome,
    required this.createdAt,
    required this.updatedAt,
  });

  // تحويل من JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      isHome: json['is_home'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_home': isHome,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
