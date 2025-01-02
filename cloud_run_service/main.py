from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch
from ultralytics import YOLO
from google.cloud import storage
import tempfile
import os
import json
from datetime import datetime
from PIL import Image

app = FastAPI()
model = YOLO('model/best.pt')

class ImageRequest(BaseModel):
    image_url: str

@app.post("/detect")
async def detect_objects(request: ImageRequest):
    try:
        # Cloud Storage 클라이언트 초기화
        storage_client = storage.Client()
        
        # 이미지 URL에서 버킷 이름과 블롭 경로 추출
        bucket_name = "skindeep_project"
        blob_path = request.image_url.split(f"{bucket_name}/")[-1]
        
        # 임시 파일 생성
        temp_local_path = tempfile.mktemp()
        result_image_path = tempfile.mktemp(suffix='.jpg')
        
        # 이미지 다운로드
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_path)
        blob.download_to_filename(temp_local_path)
        
        # YOLO 모델로 객체 감지
        results = model(temp_local_path)
        
        # 결과 이미지 저장
        result_img = results[0].plot()  # BGR to RGB
        Image.fromarray(result_img).save(result_image_path)
        
        # 결과 처리
        detections = []
        for result in results:
            for box in result.boxes:
                detection = {
                    "bbox": box.xyxy[0].tolist(),
                    "confidence": float(box.conf[0]),
                    "class_name": result.names[int(box.cls[0])]
                }
                detections.append(detection)
        
        # 결과 데이터 생성
        result_data = {
            "image_url": request.image_url,
            "detections": detections,
            "timestamp": datetime.now().isoformat()
        }
        
        # 타임스탬프와 기본 파일명
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base_filename = os.path.splitext(os.path.basename(blob_path))[0]
        
        # JSON 결과 저장
        result_bucket = storage_client.bucket("skindeep_project_result")
        json_blob_name = f"results/{base_filename}_{timestamp}.json"
        json_blob = result_bucket.blob(json_blob_name)
        json_blob.upload_from_string(
            json.dumps(result_data, indent=2),
            content_type='application/json'
        )
        
        # 결과 이미지 저장
        image_blob_name = f"results/{base_filename}_{timestamp}.jpg"
        image_blob = result_bucket.blob(image_blob_name)
        image_blob.upload_from_filename(result_image_path)
        
        # 임시 파일들 삭제
        os.remove(temp_local_path)
        os.remove(result_image_path)
        
        return {
            "image_url": request.image_url,
            "detections": detections,
            "result_file": f"gs://skindeep_project_result/{json_blob_name}",
            "result_image": f"gs://skindeep_project_result/{image_blob_name}"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))