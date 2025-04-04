# Use a slim Python base image
FROM python:3.9-slim as builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python-dev && \
    rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Final stage with minimal footprint
FROM python:3.9-slim

# Copy only necessary files from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set up the application
WORKDIR /app
COPY . .

# Serverless optimization configurations
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

# Pre-download models to reduce cold start time
RUN python -c "from kokoro import preload_models; preload_models()"

# Use Gunicorn with optimized settings for serverless
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "1", "--threads", "1", "--timeout", "0", "app.main:app"]