import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../models/category.dart';
import '../services/post_service.dart';
import '../services/category_service.dart';
import 'post_detail_screen.dart';
import 'post_list_screen.dart';
import 'general_write_screen.dart';

class GalleryHomeFeedScreen extends StatefulWidget {
  const GalleryHomeFeedScreen({super.key});

  @override
  State<GalleryHomeFeedScreen> createState() => _GalleryHomeFeedScreenState();
}

class _GalleryHomeFeedScreenState extends State<GalleryHomeFeedScreen> {
  final PostService _postService = PostService();
  final CategoryService _categoryService = CategoryService();
  List<Post> _posts = [];
  List<Post> _workoutPosts = []; // 오운완 게시물들
  List<Category> _categories = []; // 실제 DB 카테고리들
  bool _isLoading = true;
  String? _error;

  // 룸핏 브랜드 컬러
  static const Color roomfitPrimary = Color(0xFF5252FF);
  static const Color roomfitSecondary = Color(0xFFBAFC27);

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadCategories();
    timeago.setLocaleMessages('ko', timeago.KoMessages());
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final posts = await _postService.getAllPosts();
      final workoutPosts = await _postService.getPostsByCategory('workout');

      setState(() {
        _posts = posts;
        _workoutPosts = workoutPosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('카테고리 로드 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: roomfitPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'RoomFit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          // 임시 + 버튼 (앱바에)
          IconButton(
            icon: const Icon(Icons.add, color: roomfitPrimary, size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GeneralWriteScreen(),
                ),
              );
              if (result == true) {
                _loadPosts();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: roomfitPrimary))
          : _error != null
              ? _buildErrorWidget()
              : _buildFeedList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GeneralWriteScreen(),
            ),
          );
          if (result == true) {
            _loadPosts();
          }
        },
        backgroundColor: roomfitPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    if (_categories.isEmpty) {
      return const SizedBox.shrink(); // 카테고리가 없으면 숨김
    }

    // '전체' 버튼을 맨 앞에 추가하고, sortOrder 순으로 정렬된 카테고리들 추가
    final allCategories = [
      // 가상의 '전체' 카테고리
      Category(
        id: 0,
        name: '전체',
        slug: 'all',
        description: '모든 게시물',
        icon: 'apps',
        color: '#5252FF',
        sortOrder: -1,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ..._categories, // 실제 DB에서 가져온 카테고리들 (이미 sortOrder로 정렬됨)
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = index == 0; // 기본적으로 '전체' 선택

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (category.slug == 'all') {
                    // '전체'를 누르면 아무것도 하지 않음 (이미 홈 화면)
                    print('전체 카테고리 선택');
                  } else {
                    // 특정 카테고리를 누르면 해당 게시판으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostListScreen(category: category),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? roomfitPrimary
                        : (category.color != null
                            ? _parseHexColor(category.color!).withOpacity(0.1)
                            : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? roomfitPrimary
                          : (category.color != null
                              ? _parseHexColor(category.color!)
                              : Colors.grey[300]!),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconFromName(category.icon),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : (category.color != null
                                ? _parseHexColor(category.color!)
                                : Colors.grey[700]),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (category.color != null
                                  ? _parseHexColor(category.color!)
                                  : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 헥스 컬러를 Color 객체로 변환
  Color _parseHexColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return roomfitPrimary; // 기본 색상
    }
  }

  // 아이콘 이름을 IconData로 변환
  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'apps': return Icons.apps;
      case 'star': return Icons.star;
      case 'lightbulb': return Icons.lightbulb;
      case 'help_outline': return Icons.help_outline;
      case 'fitness_center': return Icons.fitness_center;
      case 'campaign': return Icons.campaign;
      case 'rate_review': return Icons.rate_review; // 제품리뷰용
      case 'question_answer': return Icons.question_answer; // 질문용
      case 'sports': return Icons.sports; // 오운완용
      case 'restaurant': return Icons.restaurant; // 식단용
      default: return Icons.category;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '알 수 없는 오류',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: roomfitPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedList() {
    if (_posts.isEmpty) {
      return _buildEmptyState();
    }

    final pinnedPosts = _posts.where((post) => post.isPinned).toList();
    final regularPosts = _posts.where((post) => !post.isPinned).toList();

    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: roomfitPrimary,
      child: CustomScrollView(
        slivers: [
          // 카테고리 버튼들 추가!
          SliverToBoxAdapter(
            child: _buildCategoryButtons(),
          ),

          // 구분선
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.grey[200], height: 1),
            ),
          ),

          // 오운완 갤러리 섹션
          if (_workoutPosts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.fitness_center,
                          color: roomfitPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '운동 인증',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // TODO: 오운완 전체 보기
                          },
                          child: const Text(
                            '더보기',
                            style: TextStyle(
                              color: roomfitPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _workoutPosts.length,
                        itemBuilder: (context, index) {
                          final post = _workoutPosts[index];
                          return _buildWorkoutCard(post);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Colors.grey[200]),
              ),
            ),
          ],

          // 커뮤니티 헤더
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.forum,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Community',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_posts.length}',
                    style: const TextStyle(
                      color: roomfitPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 상단 고정 게시물들
          if (pinnedPosts.isNotEmpty) ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPostCard(pinnedPosts[index], isPinned: true),
                childCount: pinnedPosts.length,
              ),
            ),
            if (regularPosts.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '일반 게시물',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                ),
              ),
          ],

          // 일반 게시물들
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPostCard(regularPosts[index]),
              childCount: regularPosts.length,
            ),
          ),

          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            const Text(
              '아직 게시물이 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 게시물을 작성해보세요!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Post post) {
    final hasImages = post.images != null && post.images!.isNotEmpty;
    final imageUrl = hasImages ? post.images!.first : null;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 영역
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: hasImages && imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: roomfitPrimary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('이미지 로드 에러: $error');
                            return const Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              // 정보 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorNickname ?? '익명',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeago.format(post.createdAt, locale: 'ko'),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
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
  }

  Widget _buildPostCard(Post post, {bool isPinned = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPinned ? roomfitSecondary : Colors.grey[200]!,
          width: isPinned ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.categoryName ?? '일반',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const Spacer(),

                    if (post.isNotice) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: roomfitPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '공지',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (isPinned) ...[
                      if (post.isNotice) const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: roomfitSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin, size: 10, color: Colors.black),
                            SizedBox(width: 2),
                            Text(
                              '고정',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: post.isNotice ? roomfitPrimary : Colors.black,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Text(
                  post.content.replaceAll('\\n', '\n'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      post.authorNickname ?? '익명',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(post.createdAt, locale: 'ko'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    _buildStatItem(Icons.visibility, post.viewCount),
                    const SizedBox(width: 12),
                    _buildStatItem(Icons.thumb_up_outlined, post.likeCount),
                    const SizedBox(width: 12),
                    _buildStatItem(Icons.chat_bubble_outline, post.commentCount),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}