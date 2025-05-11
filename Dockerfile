FROM ubuntu:22.04

# Install base utilities and SSH server
RUN apt-get update && apt-get install -y \
    openssh-server sudo curl wget gnupg2 \
    jq netcat lsof dos2unix \
    python3 python3-pip

# Prepare SSH runtime
RUN mkdir /var/run/sshd
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
RUN echo 'root:changeme' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 2222

# Install Python packages, Jupyter, and uvx
RUN pip install --no-cache-dir jupyterlab uv uvx

# Install Ollama (latest at build time)
RUN curl -fsSL https://ollama.com/install.sh | sh


# Set default model storage
ENV OLLAMA_MODELS=/mnt/data/models

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
