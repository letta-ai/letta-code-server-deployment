FROM oven/bun:slim

ENV BUN_INSTALL_GLOBAL_DIR=/opt/letta-code
RUN apt-get update && \
    apt-get install -y python3 make g++ && \
    bun install -g @letta-ai/letta-code && \
    apt-get purge -y python3 make g++ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Patch --env-name parseArgs bug (fixed on main, not yet released)
RUN LETTA_JS=/opt/letta-code/node_modules/@letta-ai/letta-code/letta.js && \
    sed -i 's/envName: { type: "string" }/"env-name": { type: "string" }/' "$LETTA_JS" && \
    sed -i 's/values\.envName/values["env-name"]/g' "$LETTA_JS"

ENV LETTA_API_KEY=""
ENV ENV_NAME="cloud"

CMD ["sh", "-c", "letta server --env-name \"$ENV_NAME\" --debug"]
