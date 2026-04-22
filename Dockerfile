FROM oven/bun:slim

# Install Letta Code
# git: required at runtime for memory sync
# python3: required at runtime for skills (e.g. Discord)
ENV BUN_INSTALL_GLOBAL_DIR=/opt/letta-code

# Cache bust on new letta-code releases. The npm registry's /latest
# endpoint returns a different JSON body whenever a new version ships,
# which invalidates this layer and forces the bun install below to
# fetch fresh. Without this, Docker's layer cache can pin the image
# to whatever letta-code version was current at first build.
ADD https://registry.npmjs.org/@letta-ai/letta-code/latest /tmp/letta-code-latest.json

RUN apt-get update && \
    apt-get install -y git python3 make g++ && \
    bun install -g @letta-ai/letta-code && \
    apt-get purge -y make g++ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV ENV_NAME="cloud"

# Entrypoint bootstraps Letta Code channel config (Telegram, Slack) from env
# vars before execing `letta server`. When no channel env vars are set, it
# starts the server exactly as before.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["docker-entrypoint.sh"]
