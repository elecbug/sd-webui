#!/bin/bash
source /app/venv/bin/activate
exec python3 launch.py --xformers --medvram --skip-torch-cuda-test --listen

# #!/bin/bash
# set -e

# echo "[entrypoint.sh] Starting Stable Diffusion WebUI with arguments: $COMMANDLINE_ARGS"

# cd /app

# # 모델 디렉토리 존재 확인
# if [ ! -d "models/Stable-diffusion" ]; then
#     echo "⚠️ models/Stable-diffusion 경로가 없습니다. 모델 파일이 없을 수 있습니다."
#     mkdir -p models/Stable-diffusion
# fi

# # TCMalloc (선택적 성능 최적화)
# export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so" || true

# # 실행
# bash webui.sh $COMMANDLINE_ARGS
