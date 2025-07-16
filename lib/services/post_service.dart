import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 새 게시물 작성
  Future<Post?> createPost({
    required String title,
    required String content,
    required String categorySlug,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      print('게시물 생성 시작...');

      // 1. 카테고리 ID 찾기
      final categoryResponse = await _supabase
          .from('categories')
          .select('id')
          .eq('slug', categorySlug)
          .single();

      final categoryId = categoryResponse['id'];
      print('카테고리 ID: $categoryId');

      // 2. 게시물 데이터 준비
      final postData = {
        'title': title,
        'content': content,
        'category_id': categoryId,
        'user_id': null, // 일단 익명 (나중에 인증 시스템 추가)
        'images': images,
        'tags': tags,
      };

      print('게시물 데이터: $postData');

      // 3. 게시물 삽입
      final response = await _supabase
          .from('posts')
          .insert(postData)
          .select('''
            *,
            categories(name, slug)
          ''')
          .single();

      print('게시물 생성 성공: $response');

      // 4. Post 객체로 변환
      final categoryData = response['categories'];
      return Post.fromJson({
        ...response,
        'category_name': categoryData?['name'],
        'author_nickname': '익명',
      });

    } catch (e) {
      print('게시물 생성 에러: $e');
      return null;
    }
  }

  // 카테고리별 게시물 가져오기
  Future<List<Post>> getPostsByCategory(String categorySlug) async {
    try {
      print('카테고리 검색: $categorySlug'); // 디버그

      final response = await _supabase
          .from('posts')
          .select('''
            *,
            categories!inner(name, slug)
          ''')
          .eq('categories.slug', categorySlug)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      print('응답 데이터: $response'); // 디버그

      return (response as List).map((post) {
        // 조인된 데이터 처리
        final categoryData = post['categories'];

        return Post.fromJson({
          ...post,
          'category_name': categoryData?['name'],
          'author_nickname': '익명', // 임시로 모든 작성자를 익명 처리
        });
      }).toList();
    } catch (e) {
      print('게시물 가져오기 에러: $e');
      throw Exception('게시물을 불러올 수 없습니다');
    }
  }

  // 전체 게시물 가져오기 (홈 피드용)
  Future<List<Post>> getAllPosts({int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            categories(name, slug, color)
          ''')
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((post) {
        final categoryData = post['categories'];

        return Post.fromJson({
          ...post,
          'category_name': categoryData?['name'],
          'author_nickname': '익명',
        });
      }).toList();
    } catch (e) {
      print('게시물 가져오기 에러: $e');
      throw Exception('게시물을 불러올 수 없습니다');
    }
  }

  // 게시물 상세 조회
  Future<Post?> getPostById(int postId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            categories(name, slug, color)
          ''')
          .eq('id', postId)
          .single();

      final categoryData = response['categories'];

      return Post.fromJson({
        ...response,
        'category_name': categoryData?['name'],
        'author_nickname': '익명',
      });
    } catch (e) {
      print('게시물 가져오기 에러: $e');
      return null;
    }
  }
}