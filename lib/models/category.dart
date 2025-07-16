class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? color;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  // Supabase에서 데이터를 받아올 때 사용
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Supabase로 데이터를 보낼 때 사용
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'color': color,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}