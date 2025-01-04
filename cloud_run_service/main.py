from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from ultralytics import YOLO
from google.cloud import storage
import tempfile
import os
import json
from datetime import datetime, timedelta
import shutil
from PIL import Image, ExifTags
from google.oauth2 import service_account
from google.auth import compute_engine

app = FastAPI()
model = YOLO('model/best.pt')

# 서비스 계정 키 사용 (Dockerfile에서 복사한 경로와 일치)
credentials = service_account.Credentials.from_service_account_file(
    'service-account-key.json',  # Dockerfile에서 복사된 파일명
    scopes=['https://www.googleapis.com/auth/cloud-platform']
)
storage_client = storage.Client(credentials=credentials)

class ImageRequest(BaseModel):
    front_image: str  # gs://skindeep_project/front.jpg
    left_image: str   # gs://skindeep_project/left.jpg
    right_image: str  # gs://skindeep_project/right.jpg

@app.post("/analyze")
async def analyze_faces(request: ImageRequest):
    try:
        print(f"Received request: {request}")  # 요청 데이터 출력
        
        # Cloud Storage 클라이언트 초기화
        try:
            storage_client = storage.Client()
            source_bucket = storage_client.bucket("skindeep_project")
            result_bucket = storage_client.bucket("skindeep_project_result")
        except Exception as e:
            print(f"Storage client initialization error: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Storage initialization failed: {str(e)}")

        # 임시 디렉토리 생성
        temp_dir = tempfile.mkdtemp()
        print(f"Created temp directory: {temp_dir}")

        try:
            # 이미지 다운로드 시도
            image_paths = []
            for image_url in [request.front_image, request.left_image, request.right_image]:
                print(f"Downloading image from: {image_url}")  # 각 이미지 URL 출력
                blob_path = image_url.split("skindeep_project/")[-1]
                local_path = os.path.join(temp_dir, os.path.basename(blob_path))
                blob = source_bucket.blob(blob_path)
                blob.download_to_filename(local_path)
                image_paths.append(local_path)
                print(f"Successfully downloaded: {local_path}")
        except Exception as e:
            print(f"Image download error: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Image download failed: {str(e)}")

        # 결과 저장을 위한 임시 디렉토리
        output_dir = os.path.join(temp_dir, 'results')
        os.makedirs(output_dir, exist_ok=True)

        # YOLO 분석 실행
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        results = model.predict(
            source=image_paths,
            project=output_dir,
            name=timestamp,
            save_conf = True,
            save_txt = True,
            conf=0.25,
            save=True
        )

        # 결과 저장
        analysis_results = []
        result_image_urls = []

        for i, result in enumerate(results):
            # 결과 이미지 저장
            result_image = f"results/{timestamp}_{i}.jpg"
            result_blob = result_bucket.blob(result_image)
            result_blob.upload_from_filename(os.path.join(output_dir, timestamp, os.path.basename(image_paths[i])))
            result_image_urls.append(f"gs://skindeep_project_result/{result_image}")

            # 분석 결과 저장
            detections = []
            for box in result.boxes:
                detection = {
                    "bbox": box.xyxy[0].tolist(),
                    "confidence": float(box.conf[0]),
                    "class_name": result.names[int(box.cls[0])]
                }
                detections.append(detection)
            analysis_results.append(detections)

        # JSON 결과 저장
        result_data = {
            "timestamp": timestamp,
            "images": {
                "front": {"original": request.front_image, "result": result_image_urls[0], "detections": analysis_results[0]},
                "left": {"original": request.left_image, "result": result_image_urls[1], "detections": analysis_results[1]},
                "right": {"original": request.right_image, "result": result_image_urls[2], "detections": analysis_results[2]}
            }
        }

        json_blob = result_bucket.blob(f"results/{timestamp}_analysis.json")
        json_blob.upload_from_string(
            json.dumps(result_data, indent=2),
            content_type='application/json'
        )

        # 결과 이미지에 대한 서명된 URL 생성
        signed_urls = []
        for result_image in result_image_urls:
            blob = result_bucket.blob(result_image.replace('gs://skindeep_project_result/', ''))
            url = blob.generate_signed_url(
                version="v4",
                expiration=datetime.utcnow() + timedelta(hours=1),
                method="GET",
                service_account_email='your-service-account@your-project.iam.gserviceaccount.com',
                credentials=credentials
            )
            signed_urls.append(url)

        return {
            "status": "success",
            "result_file": f"gs://skindeep_project_result/results/{timestamp}_analysis.json",
            "result_images": signed_urls
        }

    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Error: {str(e)}")
        print(f"Traceback: {error_trace}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}\n{error_trace}")

@app.get("/")
async def root():
    return {"message": "Face analysis service is running"}