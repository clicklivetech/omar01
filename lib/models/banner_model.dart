class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String backgroundColor;
  final String actionUrl;
  final bool isActive;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.actionUrl,
    required this.isActive,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String,
      backgroundColor: json['background_color'] as String,
      actionUrl: json['action_url'] as String,
      isActive: json['is_active'] as bool,
      priority: json['priority'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

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

  BannerModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? backgroundColor,
    String? actionUrl,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      actionUrl: actionUrl ?? this.actionUrl,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, subtitle: $subtitle, backgroundColor: $backgroundColor, isActive: $isActive, priority: $priority)';
  }
}
