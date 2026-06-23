FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Prevent Python from writing .pyc files & buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Environment variables for Flask (optional but useful)
ENV FLASK_ENV=production \
    PYTHONPATH=/app

# Install minimal build tools (for any dependencies needing compilation)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc curl \
 && rm -rf /var/lib/apt/lists/*

# Copy dependency list first for caching
COPY requirements.txt .

# Install dependencies (ensure gunicorn is included)
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir gunicorn

# Copy only necessary application code (other files excluded via .dockerignore)
COPY . .

# Create non-root user for security
RUN useradd -m appuser
USER appuser

# Expose Flask port
EXPOSE 8000
# Verify the app is responding
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Use Gunicorn for production serving
# Replace `app:app` with your Flask instance path if different
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]