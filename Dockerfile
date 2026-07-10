# The Trust Layer web UI — container image.
# Works on any container host (Render, Hugging Face Spaces, Fly.io, Cloud Run).
#
#   docker build -t trust-layer .
#   docker run -p 8000:8000 trust-layer   # http://localhost:8000
FROM python:3.12-slim

WORKDIR /app

# Install deps first for better layer caching.
COPY webapp/requirements.txt webapp/requirements.txt
RUN pip install --no-cache-dir -r webapp/requirements.txt

# App code + engine + sample data.
COPY . .

# Unpack the bundled sample datasets at build time (they ship zipped).
RUN python -c "import zipfile, glob; [zipfile.ZipFile(z).extractall('code') for z in glob.glob('sample_data/*.zip')]"

# Most hosts inject $PORT; default to 8000 for local runs.
ENV PORT=8000
EXPOSE 8000

CMD ["sh", "-c", "uvicorn webapp.app:app --host 0.0.0.0 --port ${PORT:-8000}"]
