sudo docker run --rm --gpus all -v $(pwd)/../models/:/app/models/ -p 7860:7860 sd-webui
