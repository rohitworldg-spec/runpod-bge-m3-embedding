FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

WORKDIR /app

# Install Python 3.11
RUN apt-get update && apt-get install -y python3.11 python3.11-venv python3-pip && \
    ln -sf /usr/bin/python3.11 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Install PyTorch 2.6+ with CUDA 12.4, then other deps
RUN pip install --no-cache-dir \
    torch==2.6.0 --index-url https://download.pytorch.org/whl/cu124 && \
    pip install --no-cache-dir \
    runpod==1.7.0 \
    sentence-transformers==3.0.1 \
    huggingface-hub

# Download model files at build time (baked into image)
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('BAAI/bge-m3', cache_dir='/app/model_cache')"

# Set HF cache to use our pre-downloaded model
ENV HF_HOME=/app/model_cache
ENV TRANSFORMERS_CACHE=/app/model_cache

# Copy handler
COPY handler.py .

# RunPod serverless entry point
CMD ["python", "-u", "handler.py"]
