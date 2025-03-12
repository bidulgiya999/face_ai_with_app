# 팀원
황승재 : 
신민재 : 

# SkinDeep Project
피부 분석을 위한 얼굴 촬영 및 YOLO 기반 분석 서비스

## 프로젝트 구조
```
skindeep_project/
├── lib/
│   ├── constants/          # 상수 정의 (사진 타입 등)
│   ├── models/            # 데이터 모델
│   ├── providers/         # 상태 관리 (카메라, 사진)
│   ├── screens/           # 화면 UI
│   │   ├── camera_screen.dart      # 카메라 촬영 화면
│   │   ├── home_screen.dart        # 홈 화면
│   │   └── photo_review_screen.dart # 사진 확인 화면
│   ├── services/          # 외부 서비스 연동
│   │   └── storage_service.dart    # GCP 스토리지 서비스
│   ├── utils/            # 유틸리티 함수
│   │   ├── error_utils.dart       # 에러 처리
│   │   └── image_utils.dart       # 이미지 처리
│   └── widgets/          # 재사용 가능한 위젯
│       ├── common_dialog.dart     # 공통 다이얼로그
│       ├── oval_guide.dart        # 얼굴 가이드 오버레이
│       └── photo_preview.dart     # 사진 미리보기
│
└── cloud_run_service/    # Cloud Run 서비스
    ├── main.py           # FastAPI 서버 (YOLO 분석)
    ├── Dockerfile        # 컨테이너 설정
    └── requirements.txt  # Python 패키지 의존성
```


## 주요 기능

1. **얼굴 촬영**
   - 정면, 좌측, 우측 3장의 사진 촬영
   - 얼굴형 가이드 오버레이 제공
   - 사진 미리보기 및 재촬영 기능
   - 촬영 방향별 가이드 텍스트 제공

2. **이미지 처리**
   - EXIF 메타데이터 기반 이미지 회전 보정
   - GCP Cloud Storage 업로드
   - 이미지 좌우 반전 처리 (전면 카메라)

3. **YOLO 분석**
   - 얼굴 특징 감지 (best.pt 모델 사용)
   - 분석 결과 JSON 저장
   - 바운딩 박스가 표시된 결과 이미지 생성
   - 신뢰도 점수 포함

## 기술 스택

- **Frontend (Flutter)**
  - Provider (상태 관리)
  - camera (카메라 제어)
  - google_cloud_storage (GCP 연동)
  - path_provider (파일 처리)
  - image (이미지 처리)

- **Backend (Cloud Run)**
  - FastAPI
  - ultralytics (YOLO)
  - google-cloud-storage
  - Pillow (이미지 처리)
  - python-multipart

## 설치 및 실행

1. **Flutter 앱**
    의존성 설치
    flutter pub get

    개발 모드 실행
    flutter run

2. **Cloud Run 서비스**
    도커 이미지 빌드
    - docker build --platform linux/amd64 -t gcr.io/[PROJECT_ID]/yolo-inference .

    GCP에 이미지 푸시
    - docker push gcr.io/[PROJECT_ID]/yolo-inference

    Cloud Run 배포
    - gcloud run deploy yolo-inference \ --image gcr.io/[PROJECT_ID]/yolo-inference \


## 환경 설정

1. **GCP 설정**
   - Cloud Storage 버킷 생성
     - `skindeep_project`: 원본 이미지 저장
     - `skindeep_project_result`: 분석 결과 저장
   - 서비스 계정 권한:
     - Storage Object Viewer (읽기)
     - Storage Object Creator (쓰기)

2. **YOLO 모델**
   - `best.pt` 모델 파일을 cloud_run_service/model/ 디렉토리에 위치
   - 모델은 얼굴 특징 감지를 위해 학습된 YOLOv8 모델 사용

## API 엔드포인트

- **POST /analyze**
  ```json
  {
    "front_image": "gs://skindeep_project/front.jpg",
    "left_image": "gs://skindeep_project/left.jpg",
    "right_image": "gs://skindeep_project/right.jpg"
  }
  ```
  - 응답: 분석 결과 JSON 파일 및 결과 이미지 URL

- **GET /**
  - 서비스 상태 확인 엔드포인트

## 주의사항

- 이미지는 JPEG 형식만 지원
- 카메라 권한 필요
- 인터넷 연결 필요
- Cloud Run 서비스는 리전을 us-central1로 설정
- 이미지 업로드 시 임시 파일 자동 정리됨

## 개발자

- Frontend/Flutter: [신민재]
- Backend/YOLO: [신민재 / 김근수, 황승재]
- 프로젝트 관리: [신민재]

## 라이선스

MIT License



