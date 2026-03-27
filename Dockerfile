FROM node:20-slim

RUN apt-get update && \
    apt-get install -y python3 make g++ && \
    npm install -g @letta-ai/letta-code && \
    apt-get purge -y python3 make g++ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV LETTA_API_KEY=""

CMD ["letta", "server"]
