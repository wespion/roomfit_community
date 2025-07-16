class Post {
  final int id;
  final String title;
  final String content;
  final int? categoryId;
  final String? userId;
  final bool isNotice;
  final bool isPinned;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final List<String>? images;
  final Map<String, dynamic>? attachments;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 조인된 데이터
  final String? categoryName;
  final String? authorNickname;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.userId,
    required this.isNotice,
    required this.isPinned,
    required this.isFeatured,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    this.images,
    this.attachments,
    this.tags,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.authorNickname,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      categoryId: json['category_id'],
      userId: json['user_id'],
      isNotice: json['is_notice'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      images: json['images'] != null
          ? (json['images'] is List
              ? List<String>.from(json['images'])
              : <String>[])
          : null,
      attachments: json['attachments'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      categoryName: json['category_name'],
      authorNickname: json['author_nickname'] ?? '익명',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'user_id': userId,
      'is_notice': isNotice,
      'is_pinned': isPinned,
      'is_featured': isFeatured,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'images': images,
      'attachments': attachments,
      'tags': tags,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}