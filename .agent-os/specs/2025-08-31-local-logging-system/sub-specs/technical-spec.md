# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-08-31-local-logging-system/spec.md

## Technical Requirements

### Python Flask Log Server (`roblox_log_server.py`)

- **Flask Web Framework** - HTTP server running on localhost:5000 with CORS enabled for local connections
- **File I/O Management** - Concurrent file writing to four separate files:
  - `roblox-server-logs.txt` - Human-readable server logs
  - `roblox-server-logs.json` - Structured server log data  
  - `roblox-client-logs.txt` - Human-readable client logs with client IDs
  - `roblox-client-logs.json` - Structured client log data with client IDs
- **Log Rotation Logic** - Automatic management of all JSON log file sizes, maintaining last 1000 entries per file with FIFO rotation
- **Context-Based Routing** - Automatic routing of logs to appropriate server or client files based on context field
- **Error Handling** - Graceful handling of malformed requests, file system errors, and server exceptions with appropriate HTTP status codes
- **Rate Limiting Protection** - Basic request throttling to prevent log spam from overwhelming the server
- **Console Feedback** - Real-time server status messages showing received logs and system events

### Roblox LogService Module (`src/shared/LogService.lua`)

- **ModuleScript Architecture** - Singleton pattern following Roblox best practices for shared services
- **Context Detection** - Automatic detection of Server vs Client environment using RunService:IsServer() and RunService:IsClient()
- **Client Identification** - Automatic capture of client identity using Player.UserId for multiplayer debugging support
- **Log Level Methods** - Four severity levels: debug(), info(), warn(), error() with consistent API interface
- **Dual Output System** - Simultaneous output to Roblox Studio console and remote HTTP server
- **Non-blocking HTTP** - Asynchronous HTTP requests using spawn() to prevent game thread blocking
- **Graceful Fallback** - Silent failure handling when HttpService is disabled or server unreachable
- **Studio Environment Detection** - Remote logging only attempted in Studio using RunService:IsStudio()
- **JSON Serialization** - Proper encoding of structured data for HTTP transmission

### Data Structure Specifications

**Server Log Entry JSON Schema:**
```json
{
  "timestamp": "ISO 8601 timestamp string",
  "level": "DEBUG|INFO|WARN|ERROR",
  "message": "Log message text content",
  "context": "Server",
  "data": {
    "optional": "structured data object"
  }
}
```

**Client Log Entry JSON Schema:**
```json
{
  "timestamp": "ISO 8601 timestamp string",
  "level": "DEBUG|INFO|WARN|ERROR",
  "message": "Log message text content",
  "context": "Client",
  "client_id": "Player123 | LocalPlayer",
  "data": {
    "optional": "structured data object"
  }
}
```

**Human-Readable Log Formats:**
- **Server Logs**: `[YYYY-MM-DD HH:MM:SS] [LEVEL] [Server] Message content`
- **Client Logs**: `[YYYY-MM-DD HH:MM:SS] [LEVEL] [Client:Player123] Message content`

### Performance Requirements

- **Response Time** - Log entries appear in files within 1 second of Roblox transmission
- **Memory Usage** - Each JSON log file limited to 1000 entries (~100KB typical size per file)
- **Network Efficiency** - Compressed JSON payloads using minimal HTTP overhead
- **Game Impact** - Zero frame rate impact through background thread execution
- **Error Recovery** - Automatic retry logic with exponential backoff for temporary failures

### Security Specifications

- **Localhost Only** - Server binds exclusively to 127.0.0.1 interface
- **Studio Restriction** - Remote logging disabled in published games via environment detection
- **HTTP Security** - Basic request validation and sanitization of log data
- **Data Privacy** - No logging of sensitive player information or security tokens
- **File Permissions** - Log files created with appropriate local user permissions

### Integration Requirements

- **Rojo Compatibility** - LogService.lua syncs properly through Rojo development workflow
- **Module Import** - Easy require() integration: `local LogService = require(ReplicatedStorage.Shared.LogService)`
- **External Tool Access** - Separate server and client log files accessible by external processes for isolated real-time reading
- **Development Workflow** - Seamless integration with existing `rojo serve` development process
- **Error Diagnostics** - Clear error messages for common setup issues (HttpService disabled, server not running)

## External Dependencies

- **Flask** - Python web framework for HTTP server implementation
- **Requests/JSON Libraries** - Standard Python libraries for HTTP client and JSON processing
- **Roblox HttpService** - Built-in Roblox service for HTTP client functionality (must be enabled in Studio settings)
- **Python 3.7+** - Modern Python version for async/await support and improved JSON handling