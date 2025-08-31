# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-08-31-local-logging-system/spec.md

## Endpoints

### POST /log

**Purpose:** Receive log entries from Roblox Studio and write to local files  
**Parameters:** JSON body with log entry data  
**Response:** JSON confirmation with timestamp  
**Errors:** 400 Bad Request for malformed data, 500 Internal Server Error for file system issues

**Server Log Request Body:**
```json
{
  "timestamp": "2025-08-31T10:30:45.123Z",
  "level": "INFO",
  "message": "Enemy spawned with health 100",
  "context": "Server",
  "data": {
    "enemy_id": "enemy_001",
    "spawn_position": [10, 0, 5],
    "enemy_type": "basic"
  }
}
```

**Client Log Request Body:**
```json
{
  "timestamp": "2025-08-31T10:30:45.123Z",
  "level": "INFO",
  "message": "Tower placed at position [15, 0, 10]",
  "context": "Client",
  "client_id": "Player123",
  "data": {
    "tower_type": "basic",
    "position": [15, 0, 10],
    "cost": 50
  }
}
```

**Success Response (200):**
```json
{
  "status": "logged",
  "received_at": "2025-08-31T10:30:45.124Z",
  "file_type": "server | client",
  "entry_count": {
    "server_entries": 425,
    "client_entries": 422
  }
}
```

**Error Response (400):**
```json
{
  "error": "Invalid log entry",
  "details": "Missing required field: client_id for client context logs"
}
```

### POST /clear

**Purpose:** Clear all log files and reset entry counters  
**Parameters:** None  
**Response:** JSON confirmation of cleared files  
**Errors:** 500 Internal Server Error for file system issues

**Success Response (200):**
```json
{
  "status": "cleared",
  "files_cleared": [
    "roblox-server-logs.txt", 
    "roblox-server-logs.json",
    "roblox-client-logs.txt",
    "roblox-client-logs.json"
  ],
  "cleared_at": "2025-08-31T10:31:00.000Z"
}
```

### GET /status

**Purpose:** Get current logging status and recent log entries  
**Parameters:** Optional query parameter `?limit=N` for number of recent entries  
**Response:** JSON with server status and recent logs  
**Errors:** 500 Internal Server Error for file system access issues

**Success Response (200):**
```json
{
  "status": "running",
  "server_started": "2025-08-31T09:00:00.000Z",
  "total_entries": {
    "server_entries": 425,
    "client_entries": 422
  },
  "files": {
    "server_logs": {
      "txt_size_bytes": 22150,
      "json_entries": 425
    },
    "client_logs": {
      "txt_size_bytes": 23081,
      "json_entries": 422
    }
  },
  "recent_entries": {
    "server": [
      {
        "timestamp": "2025-08-31T10:30:45.123Z",
        "level": "INFO", 
        "message": "Enemy spawned with health 100",
        "context": "Server"
      }
    ],
    "client": [
      {
        "timestamp": "2025-08-31T10:30:45.124Z",
        "level": "INFO",
        "message": "Tower placed at position [15, 0, 10]",
        "context": "Client",
        "client_id": "Player123"
      }
    ]
  }
}
```

## HTTP Headers

**Request Headers:**
- `Content-Type: application/json` (required for POST endpoints)
- `User-Agent: Roblox-HttpService` (automatically added by Roblox)

**Response Headers:**
- `Content-Type: application/json`
- `Access-Control-Allow-Origin: *` (for local development)
- `Access-Control-Allow-Methods: GET, POST`
- `Access-Control-Allow-Headers: Content-Type`

## Error Handling

**Rate Limiting (429):**
```json
{
  "error": "Too many requests",
  "retry_after": 1,
  "details": "Maximum 100 requests per second"
}
```

**Server Error (500):**
```json
{
  "error": "Internal server error",
  "details": "Unable to write to log file"
}
```

**Invalid Method (405):**
```json
{
  "error": "Method not allowed",
  "allowed_methods": ["GET", "POST"]
}
```

## Authentication

No authentication required - server accepts all requests from localhost for development simplicity.

## CORS Configuration

Configured to allow requests from any origin for local development flexibility, enabling direct browser testing and Roblox Studio integration.