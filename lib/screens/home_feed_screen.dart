// home_feed_screen.dart에 추가할 카테고리 섹션

Widget _buildCategoryButtons() {
  final categories = [
    {'name': '전체', 'icon': Icons.apps, 'id': 'all'},
    {'name': '운동', 'icon': Icons.fitness_center, 'id': 'workout'},
    {'name': '식단', 'icon': Icons.lightbulb, 'id': 'diet'},
    {'name': 'Q&A', 'icon': Icons.help_outline, 'id': 'qa'},
    {'name': '자유', 'icon': Icons.star, 'id': 'free'},
    {'name': '공지', 'icon': Icons.campaign, 'id': 'notice'},
  ];

  return Container(
    height: 50,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = index == 0; // 기본적으로 '전체' 선택

        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: 카테고리별 필터링 로직
                print('카테고리 선택: ${category['name']}');
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? roomfitPrimary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? roomfitPrimary : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
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

// _buildFeedList() 메서드 수정 - 카테고리 버튼 추가
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

        // 오운완 갤러리 섹션 (기존 코드)
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

        // 나머지는 기존 코드와 동일...
      ],
    ),
  );
}