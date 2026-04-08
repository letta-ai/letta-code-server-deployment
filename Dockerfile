FROM oven/bun:slim

ENV BUN_INSTALL_GLOBAL_DIR=/opt/letta-code
RUN apt-get update && \
    apt-get install -y python3 make g++ git && \
    bun install -g github:letta-ai/letta-code && \
    apt-get purge -y python3 make g++ git && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV LETTA_API_KEY=""
ENV ENV_NAME="cloud"

CMD ["sh", "-c", "letta server --env-name \"$ENV_NAME\" --debug"]
