FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime

# --- 시스템 필수 패키지 설치 ---
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    git python3-venv python3-pip wget curl libgl1 libglib2.0-0 \
    libgoogle-perftools-dev && \
    apt clean

# --- 작업 디렉토리 설정 ---
WORKDIR /app

# --- 비루트 유저 생성 및 권한 설정 ---
RUN useradd -ms /bin/bash sduser && chown sduser:sduser /app
USER sduser

# --- Stable Diffusion WebUI 복제 ---
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# --- 필요 저장소 미리 클론 (자동 다운로드 방지) ---
RUN mkdir -p /app/repositories && cd /app/repositories && \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets && \
    git clone https://github.com/Stability-AI/stablediffusion.git stable-diffusion-stability-ai && \
    git clone https://github.com/huggingface/generative-models.git generative-models && \
    git clone https://github.com/crowsonkb/k-diffusion.git k-diffusion && \
    git clone https://github.com/salesforce/BLIP.git BLIP

# --- Python 가상환경 생성 및 기본 패키지 설치 ---
ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3 -m venv $VIRTUAL_ENV && \
    $VIRTUAL_ENV/bin/pip install --upgrade pip && \
    $VIRTUAL_ENV/bin/pip install \
        torch==2.1.2+cu121 torchvision==0.16.2+cu121 \
        --extra-index-url https://download.pytorch.org/whl/cu121 && \
    $VIRTUAL_ENV/bin/pip install xformers==0.0.22.post7

# --- VAE 및 기타 모델 캐시 디렉토리 준비 ---
RUN mkdir -p /app/models/Stable-diffusion /app/models/VAE-approx
COPY ./models/Stable-diffusion /app/models/Stable-diffusion
COPY ./models/VAE-approx /app/models/VAE-approx

# --- 웹 실행 인자 환경 변수 ---
ENV COMMANDLINE_ARGS="--xformers --medvram --skip-torch-cuda-test --listen"

# --- 포트 오픈 및 모델 볼륨 지원 ---
EXPOSE 7860
VOLUME ["/app/models"]

# --- entrypoint.sh 복사 및 실행 설정 ---
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]