import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 모든 카테고리 가져오기 (정렬 순서대로)
  Future<List<Category>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      return (response as List)
          .map((category) => Category.fromJson(category))
          .toList();
    } catch (e) {
      print('카테고리 가져오기 에러: $e');
      throw Exception('카테고리를 불러올 수 없습니다');
    }
  }

  // 특정 카테고리 가져오기
  Future<Category?> getCategoryBySlug(String slug) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('slug', slug)
          .eq('is_active', true)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      print('카테고리 가져오기 에러: $e');
      return null;
    }
  }
}