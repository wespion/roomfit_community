import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'workout_write_screen.dart';

class GeneralWriteScreen extends StatefulWidget {
  const GeneralWriteScreen({super.key});

  @override
  State<GeneralWriteScreen> createState() => _GeneralWriteScreenState();
}

class _GeneralWriteScreenState extends State<GeneralWriteScreen> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = true;

  static const Color roomfitPrimary = Color(0xFF5252FF);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getCategoryColor(String? categoryName) {
    switch (categoryName) {
      case '제품 리뷰': return const Color(0xFFFF6B6B);
      case '활용 공유': return const Color(0xFF4ECDC4);
      case '질문 게시판': return const Color(0xFF45B7D1);
      case '오운완': return const Color(0xFF96CEB4);
      case '공지사항': return const Color(0xFFFECA57);
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName) {
      case '제품 리뷰': return Icons.star;
      case '활용 공유': return Icons.lightbulb;
      case '질문 게시판': return Icons.help_outline;
      case '오운완': return Icons.fitness_center;
      case '공지사항': return Icons.campaign;
      default: return Icons.article;
    }
  }

  void _onCategorySelected(Category category) {
    if (category.slug == 'workout') {
      // 오운완은 특별 화면으로
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WorkoutWriteScreen(),
        ),
      );
    } else {
      // 다른 카테고리는 일반 글쓰기
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${category.name} 글쓰기 기능 준비중!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '글쓰기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: roomfitPrimary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '어떤 게시판에 글을 작성하시겠어요?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '카테고리를 선택하면 해당 게시판의 글쓰기 화면으로 이동합니다',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return _buildCategoryCard(category);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final color = _getCategoryColor(category.name);
    final icon = _getCategoryIcon(category.name);
    final isWorkout = category.slug == 'workout';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onCategorySelected(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            border: isWorkout
              ? Border.all(color: color, width: 2)
              : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                  if (isWorkout)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isWorkout
                  ? '📸 사진과 함께 운동 인증!'
                  : category.description ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}