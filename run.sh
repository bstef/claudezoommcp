#!/usr/bin/env bash
set -euo pipefail

load_env() {
  if [ -f .env ]; then
    set -a
    source .env
    set +a
  fi
}

load_env

# Check if token is missing/expired (JWT exp)
token_expired() {
  if [ -z "${ZOOM_ACCESS_TOKEN:-}" ]; then
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 not found; treating token as expired." >&2
    return 0
  fi

  python3 - "$ZOOM_ACCESS_TOKEN" <<'PY'
import base64, json, sys, time

token = sys.argv[1]
try:
    parts = token.split(".")
    if len(parts) < 2:
        sys.exit(0)
    payload = parts[1]
    padding = "=" * (-len(payload) % 4)
    data = base64.urlsafe_b64decode(payload + padding)
    exp = json.loads(data).get("exp")
    if not exp:
        sys.exit(0)
    now = int(time.time())
    # refresh if expiring within 60s
    sys.exit(0 if exp <= now + 60 else 1)
except Exception:
    sys.exit(0)
PY
}

# 1) Refresh token + update config + restart Claude only if needed
# Prefer the centralized check script when available
if [ -x ./check_zoom_token.sh ]; then
  # Determine threshold and verbose flags from env
  threshold_arg=""
  verbose_arg=""
  if [ -n "${ZOOM_TOKEN_THRESHOLD:-}" ]; then
    threshold_arg="-t $ZOOM_TOKEN_THRESHOLD"
  fi
  if [ -n "${ZOOM_CHECK_VERBOSE:-}" ]; then
    verbose_arg="-v"
  fi
  if ! ./check_zoom_token.sh $threshold_arg $verbose_arg; then
    ./get_zoom_token.sh
    load_env
    ./update_claude_config.sh
    ./restart_claude_app.sh
  fi
else
  if token_expired; then
    ./get_zoom_token.sh
    load_env
    ./update_claude_config.sh
    ./restart_claude_app.sh
  fi
fi

# 2) Open Zoom in browser
open_zoom() {
  echo "Opening Zoom meetings page..."
  open "https://us04web.zoom.us/meeting#/upcoming"
  echo "Please sign in with your Google email (benjaminstef.com) in the browser."
}

# 3) Open Zoom in browser
open_zoom

# 4) Start MCP server (foreground)
node index.js
