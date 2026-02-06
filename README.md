# Zoom MCP Server

Power Claude with Zoom. This MCP server wires Claude to the Zoom API for meetings, users, and recordings with a clean token-refresh flow and a one-command run sequence.

## What You Get

- MCP server with Zoom meeting, user, and recording tools
- Token fetch + persistence in `.env`
- Claude Desktop config updater
- One-command run script that refreshes token only when expired and restarts Claude
- Optional Claude app restart helper

## Quick Start

1. Install dependencies.
```bash
npm install
```

2. Add Zoom credentials to `.env`.
```bash
ZOOM_CLIENT_ID="..."
ZOOM_CLIENT_SECRET="..."
ZOOM_ACCOUNT_ID="..."
```

3. Run the server (auto refreshes token if expired, updates Claude config, restarts Claude).
```bash
./run.sh
```

## Scripts

- `get_zoom_token.sh` fetches a new Zoom access token and writes `ZOOM_ACCESS_TOKEN` to `.env`.
- `update_claude_config.sh` injects `ZOOM_ACCESS_TOKEN` into Claude Desktop config for the MCP server.
- `restart_claude_app.sh` restarts the macOS Claude Desktop app.
- `run.sh` orchestrates the flow. It refreshes the token only if missing/expired, updates Claude config, restarts Claude, then starts the MCP server.

## Claude Desktop Config

Default location on macOS:
`~/Library/Application Support/Claude/claude_desktop_config.json`

Example config:
```json
{
  "mcpServers": {
    "zoom": {
      "command": "node",
      "args": ["/absolute/path/to/claudezoommcp/index.js"],
      "env": {
        "ZOOM_ACCESS_TOKEN": "your_access_token_here"
      }
    }
  }
}
```

The updater script targets:
- config file: `CLAUDE_CONFIG_FILE` (default: macOS path above)
- server name: `CLAUDE_MCP_SERVER_NAME` (default: `zoom`)
- env key: `CLAUDE_ZOOM_ENV_KEY` (default: `ZOOM_ACCESS_TOKEN`)

## Features

Meeting tools: `list_meetings`, `get_meeting`, `create_meeting`, `update_meeting`, `delete_meeting`
User tools: `list_users`, `get_user`
Recording tools: `get_meeting_participants`, `get_meeting_recordings`

## Tool Reference (Selected)

`list_meetings`  
Parameters: `type` (scheduled|live|upcoming|upcoming_meetings|previous_meetings), `page_size` (max 300)

`create_meeting`  
Parameters: `topic` (required), `type`, `start_time`, `duration`, `timezone`, `agenda`, `password`, `settings`

`update_meeting`  
Parameters: `meeting_id` (required), `topic`, `start_time`, `duration`, `agenda`, `settings`

`delete_meeting`  
Parameters: `meeting_id` (required), `occurrence_id`

`list_users`  
Parameters: `status` (active|inactive|pending), `page_size` (max 300)

## Usage Examples

```
"Show me my upcoming Zoom meetings"
"Create a Zoom meeting titled 'Team Standup' for tomorrow at 10am EST, 30 minutes duration"
"Get the details for Zoom meeting ID 123456789"
"Update meeting 123456789 to start at 2pm instead"
"Cancel the Zoom meeting with ID 123456789"
```

## Requirements

- Node.js 18+
- Zoom account with API access
- Zoom Server-to-Server OAuth credentials (recommended)

## Notes

- The access token refresh check is based on the JWT `exp` claim.
- If `python3` is missing, the token is treated as expired to keep things safe.
