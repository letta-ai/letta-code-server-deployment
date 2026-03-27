FROM node:20-slim

RUN npm install -g @letta-ai/letta-code

ENV LETTA_API_KEY=""
ENV ENV_NAME="cloud"

CMD ["sh", "-c", "letta server --env-name \"$ENV_NAME\""]
