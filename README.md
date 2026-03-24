# RunPod Serverless — BAAI/bge-m3 Embedding Server

Serverless GPU endpoint for generating 1024-dim L2-normalized text embeddings using BAAI/bge-m3.

## Usage

POST to the RunPod endpoint with:

```json
{
  "input": {
    "input": "hydraulic pump for CAT 950H"
  }
}
```

Response (OpenAI-compatible):

```json
{
  "data": [
    {
      "embedding": [0.023, -0.045, ...],
      "index": 0,
      "object": "embedding"
    }
  ],
  "model": "BAAI/bge-m3",
  "object": "list"
}
```

## Deployment

Deployed via RunPod Serverless from this GitHub repo.

- GPU: RTX A4000 (16GB)
- Model: BAAI/bge-m3 (568M params, 1024-dim output)
- Latency: ~40-80ms per embedding on GPU
