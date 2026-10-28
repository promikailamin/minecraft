#!/usr/bin/env bash
# Start the playit.gg agent (playitd) with all state kept inside ./playit-data.
# If the agent has not been claimed yet, this prints a claim URL.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA="$ROOT/playit-data"
SECRET="$DATA/playit.toml"
SOCK="$DATA/playitd.sock"
LOG="$DATA/playitd.log"
DAEMON="$ROOT/playit"
CLI="$ROOT/playit-cli"

mkdir -p "$DATA"

if [[ ! -x "$DAEMON" ]]; then
  echo "error: missing daemon binary: $DAEMON" >&2
  exit 1
fi

# Already running?
if [[ -S "$SOCK" ]] && pgrep -f "playitd.sock" >/dev/null 2>&1; then
  echo "playitd already running (socket: $SOCK)"
else
  echo "starting playitd..."
  setsid nohup "$DAEMON" \
    --socket-path "$SOCK" \
    --secret-path "$SECRET" \
    --log-path "$LOG" \
    > "$DATA/playitd.out" 2>&1 < /dev/null &
  sleep 3
fi

if [[ -x "$CLI" && ! -f "$SECRET" ]]; then
  echo
  echo "Agent not claimed yet. Generating claim link..."
  "$CLI" --socket-path "$SOCK" setup
fi

echo
echo "Logs: $LOG"
