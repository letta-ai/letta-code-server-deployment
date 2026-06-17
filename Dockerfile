FROM oven/bun:slim

# Install Letta Code
# git: required at runtime for memory sync
# python3: required at runtime for skills (e.g. Discord)
# curl/wget: common in tool and skill examples for fetching remote assets/APIs
# jq: common in API/debug examples for inspecting JSON responses
# nodejs: required by the installed letta CLI entrypoint
ENV BUN_INSTALL_GLOBAL_DIR=/opt/letta-code

# The GitHub workflow keeps this file at the latest published npm version.
# Railway services connected to this repo can then auto-deploy from Git commits
# instead of staying pinned to the version baked into the first build.
ARG LETTA_CODE_VERSION=""
COPY letta-code-version.txt /tmp/letta-code-version.txt

RUN set -eux; \
    apt-get update; \
    apt-get install -y git python3 curl wget jq nodejs make g++; \
    version="${LETTA_CODE_VERSION:-$(cat /tmp/letta-code-version.txt)}"; \
    bun install -g "@letta-ai/letta-code@${version}"; \
    apt-get purge -y make g++; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

ENV ENV_NAME="cloud"
ENV LETTA_RESTORE_ENABLED_CHANNELS="1"

CMD ["sh", "-c", "letta server --env-name \"$ENV_NAME\" --debug"]
