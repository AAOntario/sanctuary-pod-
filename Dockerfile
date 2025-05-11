FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl jq netcat lsof dos2unix python3 python3-pip && \
    pip install jupyterlab && \
    rm -rf /var/lib/apt/lists/*

# Install uvx
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Create mount points
RUN mkdir -p /mnt/data/models /mnt/data/logs /mnt/data/webui_data

ENV OLLAMA_MODELS=/mnt/data/models

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 11434 3000 8888

HEALTHCHECK CMD nc -z localhost 11434 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
