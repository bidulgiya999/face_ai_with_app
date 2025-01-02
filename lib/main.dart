import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/service_locator.dart';
import 'providers/camera_provider.dart';
import 'providers/photo_provider.dart';
import 'screens/analysis_result_screen.dart';
import 'models/yolo_result.dart';

/// 앱의 진입점 및 전역 설정 관리
/// - Provider 설정
/// - 의존성 주입 초기화
/// - 앱 테마 설정
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<CameraProvider>()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 앱의 메인 위젯
/// - 앱 테마 설정
/// - 라우팅 설정
/// - 홈 화면 설정
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '얼굴 촬영 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/analysis_result': (context) => AnalysisResultScreen(
          result: ModalRoute.of(context)!.settings.arguments as YOLOResult,
        ),
      },
    );
  }
}