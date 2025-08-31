# Roblox Code Style Guide

## Context

Code style rules for Roblox game development projects.

## General Formatting

### Indentation
- Use tabs for indentation (Roblox Studio default)
- Maintain consistent indentation throughout files
- Align nested structures for readability

### Naming Conventions
- **ModuleScripts**: Use PascalCase (e.g., `PlayerManager`, `WeaponSystem`)
- **Functions and Variables**: Use camelCase (e.g., `playerData`, `calculateDamage`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`, `SPAWN_TIME`)
- **Events**: Use descriptive names with action context (e.g., `onPlayerJoined`, `weaponFired`)

### String Formatting
- Use double quotes for strings: `"Hello World"`
- Use single quotes only for strings within strings
- Use string interpolation for dynamic content: `"Player {playerName} joined"`

## Roblox-Specific Style

### Services
- Always use `game:GetService("ServiceName")`
- Store service references at the top of scripts
- Use descriptive variable names for services

```lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
```

### Script Organization
- Group service references at top
- Then local variables and constants
- Then functions
- Then main logic/connections

### Instance References
- Use descriptive variable names for instances
- Cache frequently accessed instances
- Use WaitForChild() for instances that might not exist yet

```lua
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")
```

### Event Connections
- Store connections in variables for cleanup
- Use descriptive names for connection variables
- Always clean up connections when done

```lua
local heartbeatConnection
local playerAddedConnection

-- Later cleanup
if heartbeatConnection then
	heartbeatConnection:Disconnect()
end
```

### Comments
- Add comments above non-obvious game logic
- Document RemoteEvents and RemoteFunctions
- Explain complex algorithms or game mechanics
- Use `--` for single line comments
- Use `--[[  ]]` for multi-line comments

### Error Handling
- Use `pcall()` for operations that might fail
- Provide meaningful error messages
- Handle edge cases gracefully

```lua
local success, result = pcall(function()
	return workspace:FindFirstChild("NonExistentPart").Name
end)

if not success then
	warn("Could not find part: " .. tostring(result))
end
```