FROM python:3.9-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 디렉토리 생성 및 권한 설정
RUN mkdir -p /app/model && chmod 755 /app/model

# 앱 파일 복사
COPY . .

# 디버깅을 위한 파일 체크
RUN ls -la /app/model/

# FastAPI 서버 실행
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT} --log-level debug