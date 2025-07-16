import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import '../services/post_service.dart';

class WorkoutWriteScreen extends StatefulWidget {
  const WorkoutWriteScreen({super.key});

  @override
  State<WorkoutWriteScreen> createState() => _WorkoutWriteScreenState();
}

class _WorkoutWriteScreenState extends State<WorkoutWriteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImageService _imageService = ImageService();
  final PostService _postService = PostService();

  List<XFile> _selectedImages = [];
  bool _isUploading = false;

  static const Color roomfitPrimary = Color(0xFF5252FF);
  static const Color roomfitSecondary = Color(0xFFBAFC27);

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      // 웹에서는 단일 이미지만 선택 가능
      final image = await _imageService.pickImage();
      if (image != null) {
        setState(() {
          _selectedImages = [image]; // 일단 단일 이미지만
        });
      }
    } catch (e) {
      print('이미지 선택 에러: $e');
      _showErrorSnackBar('이미지 선택 중 오류가 발생했습니다');
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('제목을 입력해주세요');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('내용을 입력해주세요');
      return;
    }

    if (_selectedImages.isEmpty) {
      _showErrorSnackBar('운동 인증샷을 최소 1장 이상 업로드해주세요');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      print('게시물 작성 시작...');

      // 실제 이미지 업로드
      print('실제 이미지 업로드 시작...');
      final imageUrls = await _imageService.uploadMultipleImages(
        _selectedImages,
        'workout'
      );

      print('업로드된 이미지 URLs: $imageUrls');

      if (imageUrls.isEmpty) {
        throw Exception('이미지 업로드에 실패했습니다. Supabase Storage 설정을 확인해주세요.');
      }

      // 실제 게시물 생성
      print('게시물 생성 시작...');
      final post = await _postService.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        categorySlug: 'workout',
        images: imageUrls,
      );

      if (post == null) {
        throw Exception('게시물 생성에 실패했습니다');
      }

      print('게시물 생성 완료: ${post.title}');
      _showSuccessSnackBar('운동 인증이 완료되었습니다! 💪');

      // 화면 닫기
      Navigator.pop(context, true);

    } catch (e) {
      print('게시물 작성 에러: $e');
      _showErrorSnackBar('오류: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '운동 인증하기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _submitPost,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: roomfitPrimary,
                    ),
                  )
                : const Text(
                    '완료',
                    style: TextStyle(
                      color: roomfitPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '오운완',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 제목 입력
            const Text(
              '제목',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '오늘의 운동을 한 줄로 표현해보세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: roomfitPrimary),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLength: 100,
            ),

            const SizedBox(height: 20),

            // 운동 인증샷
            const Text(
              '운동 인증샷',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // 이미지 선택 버튼
            InkWell(
              onTap: _isUploading ? null : _pickImages,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImages.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '사진 선택하기',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '최대 5장까지 업로드 가능',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // 선택된 이미지들 미리보기
                            Expanded(
                              child: SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == _selectedImages.length) {
                                      // 추가 버튼
                                      return Container(
                                        width: 100,
                                        margin: const EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: InkWell(
                                          onTap: _pickImages,
                                          borderRadius: BorderRadius.circular(8),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.grey,
                                            size: 30,
                                          ),
                                        ),
                                      );
                                    }

                                    // 선택된 이미지
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      margin: EdgeInsets.only(
                                        right: index < _selectedImages.length - 1 ? 8 : 0
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Stack(
                                        children: [
                                          // 이미지 플레이스홀더
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: roomfitPrimary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.image,
                                              color: roomfitPrimary,
                                              size: 30,
                                            ),
                                          ),
                                          // 삭제 버튼
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: InkWell(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // 내용 입력
            const Text(
              '내용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '오늘 어떤 운동을 하셨나요?\n운동 루틴, 느낀 점, 꿀팁 등을 자유롭게 공유해주세요!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: roomfitPrimary),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLength: 1000,
            ),

            const SizedBox(height: 20),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '운동 인증샷과 함께 여러분의 운동 스토리를 공유해주세요! 다른 회원들에게 동기부여가 됩니다 💪',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}