# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy only necessary files
#COPY app/ ./app/
#COPY models/ ./models/
#COPY main.py .
COPY handler.py .

# Optimize for serverless
ENV PYTHONUNBUFFERED=1
ENV PYTHONFAULTHANDLER=1
ENV PYTHONHASHSEED=random

# Pre-download models during build if possible
# (Add commands here to initialize models during build)

# Health check for RunPod
HEALTHCHECK --interval=5s --timeout=2s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]