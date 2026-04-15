FROM oven/bun:slim

# Install Letta Code
# git: required at runtime for memory sync
# python3: required at runtime for skills (e.g. Discord)
ENV BUN_INSTALL_GLOBAL_DIR=/opt/letta-code
RUN apt-get update && \
    apt-get install -y git python3 make g++ && \
    bun install -g @letta-ai/letta-code && \
    apt-get purge -y make g++ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV ENV_NAME="cloud"

CMD ["sh", "-c", "letta server --env-name \"$ENV_NAME\" --debug"]
