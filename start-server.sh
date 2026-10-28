#!/usr/bin/env bash
# Dispatch the "Run Minecraft Server" workflow.
# Usage: ./start-server.sh [duration_minutes] [max_heap]
set -euo pipefail

MINUTES="${1:-350}"
MEMORY="${2:-4G}"

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh (GitHub CLI) is not installed" >&2
  exit 1
fi

gh workflow run "Run Minecraft Server" \
  -f "duration_minutes=${MINUTES}" \
  -f "memory=${MEMORY}"

echo "Dispatched: ${MINUTES} minutes, ${MEMORY} heap"
echo "Address:    malls-citrus.tun.ply.gg:25565"
echo "Watch with: gh run watch"
