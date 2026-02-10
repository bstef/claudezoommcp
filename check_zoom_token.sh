#!/usr/bin/env bash
set -euo pipefail

# check_zoom_token.sh
# Exits 0 when token is valid for >60s, exits 1 when missing or expiring soon/expired.
# Usage: ./check_zoom_token.sh [threshold_seconds]

THRESHOLD=${1:-60}

load_env() {
  if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
  fi
}

load_env

if [ -z "${ZOOM_ACCESS_TOKEN:-}" ]; then
  echo "MISSING: ZOOM_ACCESS_TOKEN is not set in .env" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to parse token payload" >&2
  exit 1
fi

python3 - "$ZOOM_ACCESS_TOKEN" "$THRESHOLD" <<'PY'
import sys,base64,json,time

token = sys.argv[1]
threshold = int(sys.argv[2])
try:
    parts = token.split('.')
    if len(parts) < 2:
        print('INVALID: token does not look like JWT', file=sys.stderr)
        sys.exit(1)
    payload = parts[1]
    padding = '=' * (-len(payload) % 4)
    data = base64.urlsafe_b64decode(payload + padding)
    obj = json.loads(data)
    exp = obj.get('exp')
    if not exp:
        print('INVALID: no exp claim in token', file=sys.stderr)
        sys.exit(1)
    now = int(time.time())
    remaining = exp - now
    exp_time = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(exp))
    if remaining <= 0:
        print(f'EXPIRED: token expired at {exp_time} (now={now})', file=sys.stderr)
        sys.exit(1)
    print(f'OK: token expires at {exp_time} (in {remaining} seconds)')
    if remaining <= threshold:
        print(f'WARNING: token will expire within threshold ({threshold}s)')
        sys.exit(1)
    sys.exit(0)
except Exception as e:
    print('ERROR parsing token:', e, file=sys.stderr)
    sys.exit(1)
PY
