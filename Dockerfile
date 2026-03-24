FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

WORKDIR /app

# Upgrade torch to 2.6 to fix torch.load vulnerability requirement
RUN pip install --no-cache-dir --upgrade torch==2.6.0+cu124 --index-url https://download.pytorch.org/whl/cu124

# Install remaining deps
RUN pip install --no-cache-dir \
    runpod==1.7.0 \
    sentence-transformers==3.0.1 \
    huggingface-hub \
    safetensors

# Download model at build time
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('BAAI/bge-m3', cache_dir='/app/model_cache')"

# Verify model loads
RUN python -c "import os; os.environ['HF_HOME']='/app/model_cache'; os.environ['TRANSFORMERS_CACHE']='/app/model_cache'; from sentence_transformers import SentenceTransformer; m = SentenceTransformer('BAAI/bge-m3', cache_folder='/app/model_cache'); print('Model OK:', m.encode('test').shape)"

ENV HF_HOME=/app/model_cache
ENV TRANSFORMERS_CACHE=/app/model_cache

COPY handler.py .

CMD ["python", "-u", "handler.py"]
