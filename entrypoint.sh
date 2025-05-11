#!/bin/bash
export PATH="/root/.local/bin:$PATH"
export OLLAMA_MODELS=${OLLAMA_MODELS:-/mnt/data/models}

echo "[setup] Linking Ollama models to $OLLAMA_MODELS..."
rm -rf /root/.ollama
ln -s "$OLLAMA_MODELS" /root/.ollama

# Start Ollama if not skipped
if [[ "${SKIP_OLLAMA,,}" != "true" ]]; then
  echo "[ollama] Starting Ollama on port 11434..."
  ollama serve >> /mnt/data/logs/ollama.log 2>&1 &
else
  echo "[ollama] Skipped."
fi

## Start OpenWebUI if not skipped
if [[ "${SKIP_WEBUI,,}" != "true" ]]; then
  echo "[openwebui] Starting OpenWebUI @v1.2.3 on port 3000..."
  DATA_DIR="/mnt/data/webui_data" uvx --python 3.11 open-webui@v1.2.3 serve >> /mnt/data/logs/openwebui.log 2>&1 &
else
  echo "[openwebui] Skipped."
fi


# Start JupyterLab if enabled
if [[ "${START_JUPYTER,,}" == "true" ]]; then
  echo "[jupyter] Starting JupyterLab on port 8888..."
  jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser >> /mnt/data/logs/jupyter.log 2>&1 &
else
  echo "[jupyter] Skipped."
fi

# Start SSH daemon on port 2222
echo "[ssh] Starting SSH daemon on port 2222..."
/usr/sbin/sshd -D -p 2222 &

# Optional custom command
if [[ -n "$POD_CMD" ]]; then
  echo "[custom] Executing POD_CMD: $POD_CMD"
  eval "$POD_CMD"
fi

# Keep container alive
echo "[entrypoint] Holding container alive with tail -f /dev/null"
tail -f /dev/null

