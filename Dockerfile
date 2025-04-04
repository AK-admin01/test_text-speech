# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy only necessary files
COPY kokoro.py .
COPY utils.py .
COPY main.py .
COPY handler.py .

# Pre-download models to reduce cold start time
RUN python -c "from kokoro import Kokoro; Kokoro().load_models()"

# FastAPI server configuration
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

EXPOSE $PORT

# Use gunicorn as production server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--worker-class", "uvicorn.workers.UvicornWorker", "--timeout", "120", "main:app"]