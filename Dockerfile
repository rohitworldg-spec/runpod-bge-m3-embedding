FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

WORKDIR /app

# Install dependencies first (cached layer)
RUN pip install --no-cache-dir \
    runpod==1.7.0 \
    sentence-transformers==3.0.1 \
    huggingface-hub

# Download model files separately (more reliable than SentenceTransformer init)
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('BAAI/bge-m3', cache_dir='/app/model_cache')"

# Set HF cache to use our pre-downloaded model
ENV HF_HOME=/app/model_cache
ENV TRANSFORMERS_CACHE=/app/model_cache

# Copy handler
COPY handler.py .

# RunPod serverless entry point
CMD ["python", "-u", "handler.py"]
