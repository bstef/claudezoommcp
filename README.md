# Zoom MCP Server

A Model Context Protocol (MCP) server that enables Claude to interact with Zoom's API for managing meetings, users, and recordings.

## Features

This MCP server provides the following capabilities:

### Meeting Management
- **list_meetings** - List all scheduled meetings (upcoming, live, previous)
- **get_meeting** - Get detailed information about a specific meeting
- **create_meeting** - Create new Zoom meetings with custom settings
- **update_meeting** - Update existing meeting details
- **delete_meeting** - Delete scheduled meetings

### User Management
- **list_users** - List users in your Zoom account
- **get_user** - Get information about a specific user

### Analytics & Recordings
- **get_meeting_participants** - Get participant list for past meetings
- **get_meeting_recordings** - Get cloud recordings for a meeting

## Prerequisites

- Node.js 18 or higher
- A Zoom account with API access
- Zoom OAuth or Server-to-Server OAuth app credentials

## Setup

### 1. Install Dependencies

```bash
cd zoom-mcp-server
npm install
```

### 2. Get Zoom API Credentials

You need to create a Zoom app to get API credentials. There are two main options:

#### Option A: Server-to-Server OAuth (Recommended for automation)

1. Go to [Zoom App Marketplace](https://marketplace.zoom.us/)
2. Click "Develop" → "Build App"
3. Choose "Server-to-Server OAuth"
4. Fill in the app details
5. Add required scopes:
   - `meeting:read:admin` or `meeting:read`
   - `meeting:write:admin` or `meeting:write`
   - `user:read:admin` or `user:read`
   - `recording:read:admin` or `recording:read`
6. Activate the app and copy your credentials:
   - Account ID
   - Client ID
   - Client Secret

Then generate an access token:

```bash
curl -X POST https://zoom.us/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=account_credentials&account_id=YOUR_ACCOUNT_ID" \
  -u "CLIENT_ID:CLIENT_SECRET"
```

#### Option B: OAuth (For user-specific access)

1. Create an OAuth app in the Zoom Marketplace
2. Follow the OAuth flow to get an access token
3. Use the access token with this server

### 3. Configure Environment Variables

Create a `.env` file or set the environment variable:

```bash
export ZOOM_ACCESS_TOKEN="your_access_token_here"
```

### 4. Configure Claude Desktop

Add this server to your Claude Desktop configuration file:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "zoom": {
      "command": "node",
      "args": ["/absolute/path/to/zoom-mcp-server/index.js"],
      "env": {
        "ZOOM_ACCESS_TOKEN": "your_access_token_here"
      }
    }
  }
}
```

### 5. Restart Claude Desktop

After updating the configuration, restart Claude Desktop to load the MCP server.

## Usage Examples

Once configured, you can interact with Zoom through Claude:

### List Meetings
```
"Show me my upcoming Zoom meetings"
```

### Create a Meeting
```
"Create a Zoom meeting titled 'Team Standup' for tomorrow at 10am EST, 
30 minutes duration, with waiting room enabled"
```

### Get Meeting Details
```
"Get the details for Zoom meeting ID 123456789"
```

### List Users
```
"Show me all active users in my Zoom account"
```

### Update a Meeting
```
"Update meeting 123456789 to start at 2pm instead"
```

### Delete a Meeting
```
"Cancel the Zoom meeting with ID 123456789"
```

## Available Tools

### list_meetings
Lists all meetings for the authenticated user.

**Parameters:**
- `type` (optional): Meeting type - "scheduled", "live", "upcoming", "upcoming_meetings", or "previous_meetings" (default: "upcoming")
- `page_size` (optional): Number of records per page, max 300 (default: 30)

### get_meeting
Gets detailed information about a specific meeting.

**Parameters:**
- `meeting_id` (required): The meeting ID or UUID

### create_meeting
Creates a new Zoom meeting.

**Parameters:**
- `topic` (required): Meeting topic/title
- `type` (optional): Meeting type - 1 (instant), 2 (scheduled), 3 (recurring no fixed time), 8 (recurring fixed time) (default: 2)
- `start_time` (optional): Start time in ISO 8601 format (e.g., "2024-03-22T07:32:55Z")
- `duration` (optional): Duration in minutes
- `timezone` (optional): Timezone (e.g., "America/New_York")
- `agenda` (optional): Meeting description
- `password` (optional): Meeting password
- `settings` (optional): Object with additional settings:
  - `host_video`: Start video when host joins
  - `participant_video`: Start video when participants join
  - `join_before_host`: Allow participants to join before host
  - `mute_upon_entry`: Mute participants upon entry
  - `waiting_room`: Enable waiting room
  - `audio`: Audio options ("both", "telephony", "voip")

### update_meeting
Updates an existing meeting.

**Parameters:**
- `meeting_id` (required): The meeting ID to update
- `topic` (optional): Updated topic
- `start_time` (optional): Updated start time
- `duration` (optional): Updated duration
- `agenda` (optional): Updated agenda
- `settings` (optional): Updated settings object

### delete_meeting
Deletes a scheduled meeting.

**Parameters:**
- `meeting_id` (required): The meeting ID to delete
- `occurrence_id` (optional): For recurring meetings, the specific occurrence to delete

### list_users
Lists users in your Zoom account.

**Parameters:**
- `status` (optional): Filter by status - "active", "inactive", or "pending" (default: "active")
- `page_size` (optional): Number of records per page, max 300 (default: 30)

### get_user
Gets information about a specific user.

**Parameters:**
- `user_id` (required): User ID or email address

### get_meeting_participants
Gets the participant list for a past meeting.

**Parameters:**
- `meeting_id` (required): The meeting ID or UUID
- `page_size` (optional): Number of records per page, max 300 (default: 30)

### get_meeting_recordings
Gets cloud recordings for a meeting.

**Parameters:**
- `meeting_id` (required): The meeting ID or UUID

## Token Refresh

Access tokens expire after a certain period. For Server-to-Server OAuth apps, you'll need to regenerate the token periodically using the curl command shown above. You can automate this or manually update the token in your configuration.

## Troubleshooting

### "ZOOM_ACCESS_TOKEN environment variable is required"
Make sure you've set the `ZOOM_ACCESS_TOKEN` in your Claude Desktop configuration or environment variables.

### "Zoom API Error: 401"
Your access token has expired or is invalid. Generate a new token using your Zoom app credentials.

### "Zoom API Error: 404"
The meeting ID or user ID you're trying to access doesn't exist or you don't have permission to access it.

### "Zoom API Error: 429"
You've hit the rate limit. Wait a moment before making more requests.

## Security Notes

- Never commit your access token to version control
- Keep your Client ID and Client Secret secure
- Use environment variables for sensitive credentials
- Regularly rotate your access tokens
- Only grant the minimum required scopes to your Zoom app

## API Documentation

For more details on the Zoom API, visit:
- [Zoom API Documentation](https://developers.zoom.us/docs/api/)
- [Zoom API Reference](https://marketplace.zoom.us/docs/api-reference/zoom-api)

## License

MIT
