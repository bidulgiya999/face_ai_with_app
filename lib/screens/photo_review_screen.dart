import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import '../providers/photo_provider.dart';
import '../constants/photo_types.dart';
import '../services/storage_service.dart';

class PhotoReviewScreen extends StatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  State<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      await _storageService.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = '스토리지 초기화 실패: $e';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final photos = photoProvider.photos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('촬영된 사진 확인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmGoBack(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildPhotoPage(photos[FacePhotoType.front]!, '정면 사진'),
                _buildPhotoPage(photos[FacePhotoType.left]!, '왼쪽 사진'),
                _buildPhotoPage(photos[FacePhotoType.right]!, '오른쪽 사진'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_isUploading)
                  const CircularProgressIndicator()
                else if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red))
                else
                  ElevatedButton(
                    onPressed: _uploadPhotos,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('사진 업로드하기'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPage(String imagePath, String label) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 4 / 3,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Future<void> _uploadPhotos() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      for (var entry in photoProvider.photos.entries) {
        if (entry.value != null) {
          File imageFile = File(entry.value!);
          final fileName = '${entry.key.name}_${DateTime.now().millisecondsSinceEpoch}${path.extension(entry.value!)}';
          await _storageService.uploadImage(imageFile, fileName: fileName);
        }
      }
      
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        // 업로드 완료 다이얼로그 표시
        await showDialog(
          context: context,
          barrierDismissible: false, // 배경 터치로 닫기 방지
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('업로드 완료'),
              ],
            ),
            content: const Text('모든 사진이 업로드되었습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  // 사진 초기화
                  photoProvider.reset();
                  // 홈 화면으로 이동
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '업로드 실패: $e';
        _isUploading = false;
      });
    }
  }

  Future<void> _confirmGoBack(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사진 삭제'),
        content: const Text('저장된 사진을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () {
              // 삭제하지 않고 카메라 화면으로 돌아가기
              Navigator.of(context).pop(false);
            },
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () {
              // 삭제하고 카메라 화면으로 돌아가기
              Navigator.of(context).pop(true);
            },
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
      photoProvider.reset();
    }
    
    if (mounted) {
      // pushReplacement 대신 pop을 사용하여 카메라 화면으로 돌아가기
      Navigator.of(context).pop();
    }
  }
} 