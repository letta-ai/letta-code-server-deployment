#!/bin/sh
# Bootstraps Letta Code channel configuration from environment variables
# and execs `letta server` with the appropriate --channels flag.
#
# Accepts:
#   TELEGRAM_BOT_TOKEN        Telegram bot token from @BotFather
#   TELEGRAM_DM_POLICY        pairing (default) | allowlist | open
#   SLACK_BOT_TOKEN           Slack bot user OAuth token (xoxb-...)
#   SLACK_APP_TOKEN           Slack app-level token (xapp-...)
#   SLACK_DM_POLICY           open (default) | allowlist
#
# Write-once semantics: accounts.json is only created on first boot. On
# subsequent restarts the file is preserved so pairings and bindings survive.
# To rotate credentials: delete ~/.letta/channels/<channel>/accounts.json and
# restart the service.

set -eu

CHANNELS_DIR="${HOME:-/root}/.letta/channels"
ENABLED_CHANNELS=""

# UUID generator. /proc/sys/kernel/random/uuid is always available on Linux
# (and is what the oven/bun:slim image will use in practice). Fallbacks keep
# local testing portable.
gen_uuid() {
  if [ -r /proc/sys/kernel/random/uuid ]; then
    cat /proc/sys/kernel/random/uuid
  elif command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  else
    # Last-resort pure-shell UUID v4 from /dev/urandom
    od -An -N16 -tx1 /dev/urandom | tr -d ' \n' | \
      awk '{printf "%s-%s-4%s-%s%s-%s\n", substr($0,1,8), substr($0,9,4), substr($0,14,3), substr($0,17,1), substr($0,18,3), substr($0,21,12)}'
  fi
}

# ISO 8601 timestamp with millisecond precision (matches letta-code format).
iso_now() {
  date -u +%Y-%m-%dT%H:%M:%S.000Z
}

append_channel() {
  if [ -z "$ENABLED_CHANNELS" ]; then
    ENABLED_CHANNELS="$1"
  else
    ENABLED_CHANNELS="$ENABLED_CHANNELS,$1"
  fi
}

# ── Telegram ─────────────────────────────────────────────────────────
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
  TELEGRAM_DIR="$CHANNELS_DIR/telegram"
  TELEGRAM_FILE="$TELEGRAM_DIR/accounts.json"
  mkdir -p "$TELEGRAM_DIR"

  if [ ! -f "$TELEGRAM_FILE" ]; then
    TG_ACCOUNT_ID=$(gen_uuid)
    TG_NOW=$(iso_now)
    TG_POLICY="${TELEGRAM_DM_POLICY:-pairing}"
    cat > "$TELEGRAM_FILE" <<JSON
{
  "accounts": [
    {
      "channel": "telegram",
      "accountId": "$TG_ACCOUNT_ID",
      "enabled": true,
      "token": "$TELEGRAM_BOT_TOKEN",
      "dmPolicy": "$TG_POLICY",
      "allowedUsers": [],
      "binding": { "agentId": null, "conversationId": null },
      "createdAt": "$TG_NOW",
      "updatedAt": "$TG_NOW"
    }
  ]
}
JSON
    chmod 600 "$TELEGRAM_FILE"
    echo "[channel-bootstrap] wrote $TELEGRAM_FILE"
  else
    echo "[channel-bootstrap] telegram accounts.json already exists, skipping"
  fi
  append_channel "telegram"
fi

# ── Slack ────────────────────────────────────────────────────────────
if [ -n "${SLACK_BOT_TOKEN:-}" ] && [ -n "${SLACK_APP_TOKEN:-}" ]; then
  SLACK_DIR="$CHANNELS_DIR/slack"
  SLACK_FILE="$SLACK_DIR/accounts.json"
  mkdir -p "$SLACK_DIR"

  if [ ! -f "$SLACK_FILE" ]; then
    SK_ACCOUNT_ID=$(gen_uuid)
    SK_NOW=$(iso_now)
    SK_POLICY="${SLACK_DM_POLICY:-open}"
    cat > "$SLACK_FILE" <<JSON
{
  "accounts": [
    {
      "channel": "slack",
      "accountId": "$SK_ACCOUNT_ID",
      "enabled": true,
      "mode": "socket",
      "botToken": "$SLACK_BOT_TOKEN",
      "appToken": "$SLACK_APP_TOKEN",
      "dmPolicy": "$SK_POLICY",
      "allowedUsers": [],
      "agentId": null,
      "defaultPermissionMode": "default",
      "createdAt": "$SK_NOW",
      "updatedAt": "$SK_NOW"
    }
  ]
}
JSON
    chmod 600 "$SLACK_FILE"
    echo "[channel-bootstrap] wrote $SLACK_FILE"
  else
    echo "[channel-bootstrap] slack accounts.json already exists, skipping"
  fi
  append_channel "slack"
elif [ -n "${SLACK_BOT_TOKEN:-}" ] || [ -n "${SLACK_APP_TOKEN:-}" ]; then
  echo "[channel-bootstrap] Slack requires both SLACK_BOT_TOKEN and SLACK_APP_TOKEN — skipping" >&2
fi

# ── Build final command ─────────────────────────────────────────────
if [ -n "$ENABLED_CHANNELS" ]; then
  echo "[channel-bootstrap] starting with --channels $ENABLED_CHANNELS"
  exec letta server --env-name "${ENV_NAME:-cloud}" --debug \
    --channels "$ENABLED_CHANNELS" --install-channel-runtimes
else
  exec letta server --env-name "${ENV_NAME:-cloud}" --debug
fi
