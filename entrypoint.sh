#!/bin/bash
# Ensure local Python packages are available
export PATH="/root/.local/bin:$PATH"

# Link Ollama's models to the network volume storage
echo "[setup] Linking Ollama models to persistent storage..."
rm -rf /root/.ollama
ln -s /mnt/data/models /root/.ollama

# Optional OLLAMA startup controlled by SKIP_OLLAMA env var
if [[ "${SKIP_OLLAMA,,}" != "true" ]]; then
  echo "[ollama] Starting Ollama daemon on port 11434..."
  ollama serve >> /mnt/data/logs/ollama.log 2>&1 &
else
  echo "[ollama] Skipped as per SKIP_OLLAMA=${SKIP_OLLAMA}"
fi

# Optional OpenWebUI startup controlled by SKIP_WEBUI env var
if [[ "${SKIP_WEBUI,,}" != "true" ]]; then
  echo "[openwebui] Starting OpenWebUI on port 3000..."
  DATA_DIR="/mnt/data/webui_data" uvx --python 3.11 open-webui@latest serve >> /mnt/data/logs/openwebui.log 2>&1 &
else
  echo "[openwebui] Skipped as per SKIP_WEBUI=${SKIP_WEBUI}"
fi

# Optional JupyterLab startup controlled by START_JUPYTER env var
if [[ "${START_JUPYTER,,}" == "true" ]]; then
  echo "[jupyter] Starting Jupyter Lab on port 8888..."
  jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser >> /mnt/data/logs/jupyter.log 2>&1 &
else
  echo "[jupyter] Skipped as per START_JUPYTER=${START_JUPYTER}"
fi

# Optional custom one-time command controlled by POD_CMD env var
if [[ -n "$POD_CMD" ]]; then
  echo "[custom] Executing POD_CMD: $POD_CMD"
  eval "$POD_CMD"
fi

# Keep the container alive for manual interaction or ongoing services
echo "[entrypoint] Holding container alive with tail -f /dev/null"
tail -f /dev/null

