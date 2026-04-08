FROM oven/bun:slim

# Install letta-code from npm (for native deps like node-pty)
ENV BUN_INSTALL_GLOBAL_DIR=/opt/letta-code
RUN apt-get update && \
    apt-get install -y python3 make g++ && \
    bun install -g @letta-ai/letta-code && \
    apt-get purge -y python3 make g++ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Override the bundle with our dev build (includes OAuth device flow)
COPY letta.js /opt/letta-code/node_modules/@letta-ai/letta-code/letta.js

ENV ENV_NAME="railway"

CMD ["sh", "-c", "letta server --env-name \"$ENV_NAME\" --debug"]
