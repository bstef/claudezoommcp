#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${CLAUDE_APP_NAME:-Claude}"

# Refresh the Zoom access token before restarting Claude.
# Use the lightweight check script to avoid unnecessary network calls.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "$script_dir/check_zoom_token.sh" ]; then
  threshold_arg=""
  verbose_arg=""
  if [ -n "${ZOOM_TOKEN_THRESHOLD:-}" ]; then
    threshold_arg="-t $ZOOM_TOKEN_THRESHOLD"
  fi
  if [ -n "${ZOOM_CHECK_VERBOSE:-}" ]; then
    verbose_arg="-v"
  fi
  if ! "$script_dir/check_zoom_token.sh" $threshold_arg $verbose_arg >/dev/null 2>&1; then
    "$script_dir/get_zoom_token.sh" >/dev/null 2>&1 || true
    if [ -f "$script_dir/update_claude_config.sh" ]; then
      "$script_dir/update_claude_config.sh" >/dev/null 2>&1 || true
    fi
  fi
else
  # If no checker is present, refresh unconditionally to be safe
  if [ -f "$script_dir/get_zoom_token.sh" ]; then
    "$script_dir/get_zoom_token.sh" >/dev/null 2>&1 || true
  fi
  if [ -f "$script_dir/update_claude_config.sh" ]; then
    "$script_dir/update_claude_config.sh" >/dev/null 2>&1 || true
  fi
fi

# Try graceful quit first
osascript -e "tell application \"${APP_NAME}\" to quit" >/dev/null 2>&1 || true

# Give it a moment to exit
sleep 1

# If still running, force quit
if pgrep -x "${APP_NAME}" >/dev/null 2>&1; then
  pkill -x "${APP_NAME}" || true
  sleep 1
fi

# Relaunch
open -a "${APP_NAME}"

echo "✓ Restarted ${APP_NAME}"
