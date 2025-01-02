import 'package:get_it/get_it.dart';
import 'storage_service.dart';
import '../providers/camera_provider.dart';

final getIt = GetIt.instance;

/// 의존성 주입 설정
/// - 서비스 인스턴스 관리
/// - Provider 인스턴스 관리
void setupDependencies() {
  // 서비스 등록
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  
  // Provider 등록
  getIt.registerFactory<CameraProvider>(() => CameraProvider());
} 