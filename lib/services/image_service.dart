import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // 이미지 선택하기
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('이미지 선택 에러: $e');
      return null;
    }
  }

  // 이미지 업로드하기
  Future<String?> uploadImage(XFile imageFile, String folderPath) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final filePath = '$folderPath/$fileName';

      final response = await _supabase.storage
          .from('community-images')
          .uploadBinary(filePath, bytes);

      if (response.isNotEmpty) {
        // 공개 URL 가져오기
        final publicUrl = _supabase.storage
            .from('community-images')
            .getPublicUrl(filePath);

        return publicUrl;
      }
      return null;
    } catch (e) {
      print('이미지 업로드 에러: $e');
      return null;
    }
  }

  // 여러 이미지 선택하기
  Future<List<XFile>?> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      return images;
    } catch (e) {
      print('다중 이미지 선택 에러: $e');
      return null;
    }
  }

  // 여러 이미지 업로드하기
  Future<List<String>> uploadMultipleImages(List<XFile> imageFiles, String folderPath) async {
    List<String> uploadedUrls = [];

    for (XFile imageFile in imageFiles) {
      final url = await uploadImage(imageFile, folderPath);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // 이미지 삭제하기
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // URL에서 파일 경로 추출
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('community-images');

      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

        final response = await _supabase.storage
            .from('community-images')
            .remove([filePath]);

        return response.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('이미지 삭제 에러: $e');
      return false;
    }
  }
}