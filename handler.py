"""
RunPod Serverless Handler for BAAI/bge-m3 Embeddings
Receives text input, returns 1024-dim L2-normalized embedding vector.
OpenAI-compatible response format.
"""

import runpod
import torch
import numpy as np
from sentence_transformers import SentenceTransformer

# Load model at container startup (cached in GPU memory)
print("Loading BAAI/bge-m3 model...")
device = "cuda" if torch.cuda.is_available() else "cpu"
model = SentenceTransformer("BAAI/bge-m3", device=device, cache_folder="/app/model_cache", trust_remote_code=True)
print(f"Model loaded on {device}")


def handler(job):
    """RunPod serverless handler — receives embedding requests."""
    job_input = job["input"]

    # Support both single string and array of strings
    text_input = job_input.get("input", "")
    if isinstance(text_input, str):
        texts = [text_input]
    elif isinstance(text_input, list):
        texts = text_input
    else:
        return {"error": "input must be a string or array of strings"}

    # Generate embeddings
    embeddings = model.encode(texts, normalize_embeddings=True)

    # Format as OpenAI-compatible response
    data = []
    for i, emb in enumerate(embeddings):
        data.append({
            "embedding": emb.tolist(),
            "index": i,
            "object": "embedding"
        })

    return {
        "data": data,
        "model": "BAAI/bge-m3",
        "object": "list",
        "usage": {
            "prompt_tokens": sum(len(t.split()) for t in texts),
            "total_tokens": sum(len(t.split()) for t in texts)
        }
    }


runpod.serverless.start({"handler": handler})
