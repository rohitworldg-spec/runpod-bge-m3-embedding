FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

WORKDIR /app

# Install deps with pinned transformers version (avoids torch.load vulnerability enforcement)
RUN pip install --no-cache-dir \
    runpod==1.7.0 \
    sentence-transformers==2.7.0 \
    transformers==4.40.2 \
    huggingface-hub \
    safetensors

# Download model at build time
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('BAAI/bge-m3', cache_dir='/app/model_cache')"

# Verify model loads (PyTorch 2.4 + transformers 4.40 = compatible)
RUN TRANSFORMERS_CACHE=/app/model_cache HF_HOME=/app/model_cache python -c \
    "from sentence_transformers import SentenceTransformer; m = SentenceTransformer('BAAI/bge-m3', cache_folder='/app/model_cache'); print('Model OK:', m.encode('test').shape)"

ENV HF_HOME=/app/model_cache
ENV TRANSFORMERS_CACHE=/app/model_cache

COPY handler.py .

CMD ["python", "-u", "handler.py"]
