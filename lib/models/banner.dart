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

  // تحويل من JSON
  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String,
      backgroundColor: json['background_color'] as String?,
      actionUrl: json['action_url'] as String?,
      isActive: json['is_active'] as bool,
      priority: json['priority'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'background_color': backgroundColor,
      'action_url': actionUrl,
      'is_active': isActive,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
