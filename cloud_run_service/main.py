from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from ultralytics import YOLO
from google.cloud import storage
import tempfile
import os
import json
from datetime import datetime
import shutil
from PIL import Image, ExifTags

app = FastAPI()
model = YOLO('model/best.pt')

class ImageRequest(BaseModel):
    front_image: str  # gs://skindeep_project/front.jpg
    left_image: str   # gs://skindeep_project/left.jpg
    right_image: str  # gs://skindeep_project/right.jpg

@app.post("/analyze")
async def analyze_faces(request: ImageRequest):
    try:
        # Cloud Storage 클라이언트 초기화
        storage_client = storage.Client()
        source_bucket = storage_client.bucket("skindeep_project")
        result_bucket = storage_client.bucket("skindeep_project_result")
        
        # 임시 디렉토리 생성
        temp_dir = tempfile.mkdtemp()
        
        # 이미지 다운로드
        image_paths = []
        for image_url in [request.front_image, request.left_image, request.right_image]:
            blob_path = image_url.split("skindeep_project/")[-1]
            local_path = os.path.join(temp_dir, os.path.basename(blob_path))
            blob = source_bucket.blob(blob_path)
            blob.download_to_filename(local_path)
            
            # 이미지 방향 보정
            img = Image.open(local_path)
            try:
                for orientation in ExifTags.TAGS.keys():
                    if ExifTags.TAGS[orientation] == 'Orientation':
                        break
                exif = dict(img._getexif().items())
                if exif[orientation] == 3:
                    img = img.rotate(180, expand=True)
                elif exif[orientation] == 6:
                    img = img.rotate(270, expand=True)
                elif exif[orientation] == 8:
                    img = img.rotate(90, expand=True)
            except (AttributeError, KeyError, IndexError):
                pass
            img.save(local_path)
            image_paths.append(local_path)

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

        # 임시 파일 정리
        try:
            # 파일들 삭제
            for path in image_paths:
                os.remove(path)
            
            # 결과 디렉토리와 그 내용물 모두 삭제
            shutil.rmtree(output_dir)
            shutil.rmtree(temp_dir)
        except Exception as e:
            print(f"Error cleaning up temporary files: {e}")

        return {
            "status": "success",
            "result_file": f"gs://skindeep_project_result/results/{timestamp}_analysis.json",
            "result_images": result_image_urls
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "Face analysis service is running"}