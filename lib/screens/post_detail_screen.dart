import '../utils/text_formatter.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  Color _getCategoryColor() {
    switch (post.categoryName) {
      case '제품 리뷰': return const Color(0xFFFF6B6B);
      case '활용 공유': return const Color(0xFF4ECDC4);
      case '질문 게시판': return const Color(0xFF45B7D1);
      case '오운완': return const Color(0xFF96CEB4);
      case '공지사항': return const Color(0xFFFECA57);
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (post.categoryName) {
      case '제품 리뷰': return Icons.star;
      case '활용 공유': return Icons.lightbulb;
      case '질문 게시판': return Icons.help_outline;
      case '오운완': return Icons.fitness_center;
      case '공지사항': return Icons.campaign;
      default: return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(post.categoryName ?? '게시물'),
        backgroundColor: categoryColor.withOpacity(0.1),
        foregroundColor: categoryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('공유 기능 준비중!')),
                );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 칩
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: categoryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(),
                    size: 16,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    post.categoryName ?? '일반',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 제목
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: post.isNotice ? Colors.red : null,
              ),
            ),

            const SizedBox(height: 16),

            // 작성자 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: categoryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorNickname ?? '익명',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          timeago.format(post.createdAt, locale: 'ko'),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 통계
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(post.viewCount.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(post.likeCount.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 본문
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                post.content.replaceAll('\\n', '\n'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 액션 버튼
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('좋아요 기능 준비중!')),
                        );
                    },
                    icon: const Icon(Icons.thumb_up_outlined),
                    label: Text('좋아요 ${post.likeCount}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor.withOpacity(0.1),
                      foregroundColor: categoryColor,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('댓글 기능 준비중!')),
                        );
                    },
                    icon: const Icon(Icons.comment_outlined),
                    label: Text('댓글 ${post.commentCount}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}