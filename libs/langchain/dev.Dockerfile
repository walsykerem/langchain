# Pinned by digest so a rebuild cannot pull a changed base image.
FROM python:3.15-slim-bookworm@sha256:96599df822d0e1c6bb700014a05c7f3c8cabc6e0f7ff3c4f9f69cee033b4b5d9

# Set environment variables for Python and uv
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    UV_CACHE_DIR=/tmp/uv-cache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    vim \
    less \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN pip install --no-cache-dir uv

WORKDIR /workspaces/langchain

COPY . .

# Create uv cache directory and set permissions
RUN mkdir -p $UV_CACHE_DIR && chmod 755 $UV_CACHE_DIR

# Install dependencies using uv (let uv handle the venv creation)
WORKDIR /workspaces/langchain/libs/langchain_v1
RUN uv sync --dev
WORKDIR /workspaces/langchain

# Create a non-root user and set up proper permissions
RUN useradd -m -s /bin/bash -u 1000 vscode && \
    chown -R vscode:vscode /workspaces $UV_CACHE_DIR

USER vscode

# Set shell for interactive use
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]
