FROM oven/bun:slim

ENV BUN_INSTALL_GLOBAL_DIR=/opt/letta-code
RUN apt-get update && \
    apt-get install -y python3 make g++ && \
    bun install -g @letta-ai/letta-code && \
    apt-get purge -y python3 make g++ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV LETTA_API_KEY=""

CMD ["letta", "server", "--debug"]
