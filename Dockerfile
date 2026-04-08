FROM oven/bun:slim

RUN bun install -g @letta-ai/letta-code

ENV LETTA_API_KEY=""
ENV ENV_NAME="cloud"

CMD ["sh", "-c", "letta server --env-name \"$ENV_NAME\""]
