FROM pytorch/pytorch:2.3.1-cuda11.8-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
COPY manager_requirements.txt .

# --- FIX IS HERE ---
# 1. Upgrade pip first to ensure better dependency resolution
RUN pip install --upgrade pip

# 2. Install Torch + Torchvision + Xformers TOGETHER.
# This forces them to align versions (e.g. if Torch goes to 2.7.1, Vision must match).
# We use --upgrade to overwrite whatever came with the base image.
RUN pip install --no-cache-dir --upgrade torch torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu118

# 3. Install remaining requirements
# If your requirements.txt contains 'torch' or 'torchvision', pip should
# see they are already satisfied and skip them (or you can remove them from the txt).
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r manager_requirements.txt

COPY . .

EXPOSE 8188

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--preview-method", "auto", "--cuda-malloc"]