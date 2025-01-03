/// 카메라 화면 위젯
/// - 카메라 프리뷰 표시
/// - 전/후면 카메라 전환 기능
/// - 사진 촬영 기능
/// - 얼굴 인식 가이드 오버레이 표시

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/camera_provider.dart';
import '../widgets/oval_guide.dart';
import 'photo_review_screen.dart';
import '../providers/photo_provider.dart';
import '../constants/photo_types.dart';
import '../widgets/photo_preview.dart';
import '../utils/image_utils.dart';
import 'dart:io';
import 'package:get_it/get_it.dart';
import '../services/storage_service.dart';
import '../widgets/common_dialog.dart';
import '../utils/error_utils.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  late List<FacePhotoType> _photoTypes;

  @override
  void initState() {
    super.initState();
    _photoTypes = [FacePhotoType.front, FacePhotoType.left, FacePhotoType.right];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);
    final photoProvider = Provider.of<PhotoProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cameraProvider.controller == null) {
        cameraProvider.loadCameras();
      }
      
      // 현재 촬영 타입에 맞는 페이지로 이동
      final currentIndex = _photoTypes.indexOf(photoProvider.currentPhotoType);
      if (_pageController.hasClients && _pageController.page?.toInt() != currentIndex) {
        _pageController.jumpToPage(currentIndex);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${photoProvider.currentPhotoType.label} 촬영'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmGoBack(context),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              // 페이지 변경 시 촬영 타입 업데이트
              photoProvider.setCurrentType(_photoTypes[index]);
            },
            itemCount: _photoTypes.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _getGuideText(_photoTypes[index]),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: cameraProvider.controller?.value.isInitialized ?? false
                        ? ClipRect(
                            child: CameraPreview(
                              cameraProvider.controller!,
                              child: const OvalGuide(),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  if (photoProvider.isCompleted) ...[  // 모든 사진이 촬영된 경우
                    const SizedBox(height: 30),  // 30픽셀 간격
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PhotoReviewScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        '업로드 단계로 넘어가기',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              );
            },
          ),
          PhotoPreviewList(photos: photoProvider.photos),
        ],
      ),
      floatingActionButton: _buildActionButtons(context, cameraProvider),
    );
  }

  /// 카메라 화면의 액션 버튼들을 구성하는 메서드
  /// - 카메라 전환 버튼
  /// - 촬영 버튼
  Widget _buildActionButtons(BuildContext context, CameraProvider cameraProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'toggleCamera',
          onPressed: cameraProvider.toggleCamera,
          child: const Icon(Icons.flip_camera_ios),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'takePicture',
          onPressed: () => _takePicture(context, cameraProvider),
          child: const Icon(Icons.camera_alt),
        ),
      ],
    );
  }

  /// 사진 촬영 및 결과 화면 이동 처리
  /// - 사진 촬영
  /// - 촬영 결과 화면으로 이동
  Future<void> _takePicture(BuildContext context, CameraProvider cameraProvider) async {
    try {
      final image = await cameraProvider.controller?.takePicture();
      if (image == null || !context.mounted) return;

      // 전면 카메라로 촬영한 경우 이미지 반전
      String imagePath = image.path;
      if (cameraProvider.currentCamera?.lensDirection == CameraLensDirection.front) {
        final flippedImage = await ImageUtils.flipImage(File(imagePath));
        imagePath = flippedImage.path;
      }

      final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
      
      // 이미 해당 타입의 사진이 있는 경우
      if (photoProvider.hasPhotoForType(photoProvider.currentPhotoType)) {
        final shouldUpdate = await showConfirmDialog(
          context: context,
          title: '사진 수정',
          content: '이미 촬영된 사진이 있습니다. 새로운 사진으로 수정하시겠습니까?',
        );

        if (shouldUpdate == true) {
          photoProvider.updatePhoto(imagePath);
        }
      } else {
        // 새로운 사진 추가
        photoProvider.addPhoto(imagePath);
      }

      // 모든 사진이 촬영된 경우 확인 다이얼로그 표시
      if (photoProvider.isCompleted && mounted) {
        final shouldReview = await showConfirmDialog(
          context: context,
          title: '사진 확인',
          content: '촬영한 사진을 확인하시겠습니까?',
        );

        if (shouldReview == true && mounted) {
          // 사진 확인 화면으로 이동
          final shouldUpload = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const PhotoReviewScreen(),
            ),
          );

          // 사진 확인 화면에서 업로드 버튼을 눌렀을 때
          if (shouldUpload == true && mounted) {
            try {
              final storageService = GetIt.I<StorageService>();
              await storageService.uploadImage(File(imagePath));
              
              // 홈 화면으로 이동
              if (mounted) {
                showSuccessSnackBar(context, '사진이 성공적으로 업로드되었습니다');
                Navigator.of(context).pop();
              }
            } catch (e) {
              showErrorSnackBar(context, '업로드 실패: $e');
            }
          }
        }
      }
    } catch (e) {
      showErrorSnackBar(context, '사진 촬영 실패: $e');
    }
  }

  String _getGuideText(FacePhotoType type) {
    switch (type) {
      case FacePhotoType.front:
        return '얼굴을 정면으로 바라보고 촬영해주세요';
      case FacePhotoType.left:
        return '얼굴을 왼쪽으로 돌려 촬영해주세요';
      case FacePhotoType.right:
        return '얼굴을 오른쪽으로 돌려 촬영해주세요';
      default:
        throw UnimplementedError('Unsupported photo type: $type');
    }
  }

  Future<void> _confirmGoBack(BuildContext context) async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    
    if (photoProvider.hasAnyPhotos) {
      final shouldDelete = await showConfirmDialog(
        context: context,
        title: '사진 삭제',
        content: '저장된 사진을 삭제할까요?',
      );

      if (shouldDelete == true) {
        photoProvider.reset();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }
} 