# Zoom MCP Server

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io) server that integrates Zoom API with Claude Desktop. Manage meetings, users, and recordings directly from Claude with automatic token refresh and seamless setup.

## Features

- **9 Zoom API Tools**: Meeting management (list, create, update, delete), user management, participants, and recordings
- **Automatic Token Management**: JWT-based token validation with smart refresh (only when expired)
- **One-Command Setup**: Single script handles token fetch, config update, Claude restart, and server startup
- **Production Ready**: Comprehensive error handling, logging support, and cross-platform compatibility

## Prerequisites

- **Node.js** 18+ (check with `node --version`)
- **Zoom Account** with API access
- **Zoom Server-to-Server OAuth App** ([create one here](https://marketplace.zoom.us/))
  - Required scopes: `meeting:read`, `meeting:write`, `user:read`, `recording:read`
- **Claude Desktop** ([download](https://claude.ai/download))
- **python3** (for token validation, typically pre-installed on macOS/Linux)

## Quick Start

1. **Clone and install**
   ```bash
   git clone <your-repo-url>
   cd zoommcp
   npm install
   ```

2. **Configure Zoom credentials**
   ```bash
   cp .env.example .env
   # Edit .env and add your Zoom OAuth credentials:
   # ZOOM_CLIENT_ID, ZOOM_CLIENT_SECRET, ZOOM_ACCOUNT_ID
   ```

3. **Run the server** (handles everything automatically)
   ```bash
   chmod +x *.sh  # Make scripts executable (first time only)
   ./run.sh
   ```
   
   This script will:
   - Check if access token is expired
   - Fetch a new token if needed
   - Update Claude Desktop config
   - Restart Claude Desktop app
   - Start the MCP server

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
