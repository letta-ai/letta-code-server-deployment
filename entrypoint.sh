#!/bin/sh
set -eu

LETTA_USER="${LETTA_USER:-letta}"
LETTA_GROUP="${LETTA_GROUP:-letta}"
LETTA_UID="${LETTA_UID:-10001}"
LETTA_GID="${LETTA_GID:-10001}"
LETTA_HOME="${LETTA_HOME:-/home/letta}"

export HOME="$LETTA_HOME"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$LETTA_HOME/.config}"

if [ "${1:-}" = "letta-server" ]; then
  set -- letta server --env-name "${ENV_NAME:-cloud}" --debug
fi

if [ "$(id -u)" = "0" ]; then
  mkdir -p "$LETTA_HOME/.letta" "$LETTA_HOME/.config" "$LETTA_HOME/Code"
  cp -an /etc/skel/. "$LETTA_HOME/" 2>/dev/null || true

  current_owner="$(stat -c '%u:%g' "$LETTA_HOME")"
  expected_owner="${LETTA_UID}:${LETTA_GID}"
  if [ "$current_owner" != "$expected_owner" ]; then
    chown "$LETTA_USER:$LETTA_GROUP" "$LETTA_HOME"
  fi

  chown "$LETTA_USER:$LETTA_GROUP" "$LETTA_HOME/Code"
  chown -R "$LETTA_USER:$LETTA_GROUP" "$LETTA_HOME/.letta" "$LETTA_HOME/.config"
  find "$LETTA_HOME" -mindepth 1 -maxdepth 1 \
    ! -name Code ! -name .letta ! -name .config \
    -exec chown "$LETTA_USER:$LETTA_GROUP" {} +

  exec setpriv --reuid "$LETTA_UID" --regid "$LETTA_GID" --init-groups "$@"
fi

exec "$@"
