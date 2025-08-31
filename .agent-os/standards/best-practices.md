# Roblox Development Best Practices

## Context

Development guidelines for Roblox game projects focused on learning and building games effectively.

## Core Principles

### Keep It Simple
- Start with basic scripts and gradually add complexity
- Use built-in Roblox services before considering external tools
- Focus on making it work first, optimize later
- Avoid over-engineering solutions

### Learn By Building
- Experiment freely with different approaches
- Use `print()` statements for debugging and understanding
- Test frequently in Roblox Studio
- Break complex problems into smaller parts

### Focus on Game Mechanics
- Prioritize fun gameplay over perfect code
- Build features players will interact with
- Iterate quickly on ideas
- Get feedback early and often

## Security and Safety

### Client-Server Architecture
- **Never trust the client** - validate all player actions on the server
- Use RemoteEvents for client-to-server communication
- Use RemoteFunctions sparingly and only for immediate responses
- Keep sensitive game logic on the server

### Data Validation
- Validate all data received from clients
- Check if players have permission for actions
- Sanitize user input (chat, GUI text, etc.)
- Use reasonable limits (speed, damage, etc.)

### Example Security Pattern
```lua
-- Server script
local function onPlayerDamaged(player, damage)
	-- Validate the damage amount
	if damage < 0 or damage > MAX_DAMAGE then
		return -- Invalid damage, ignore
	end
	
	-- Apply damage
	applyDamage(player, damage)
end
```

## Performance Guidelines

### Memory Management
- Disconnect event connections when done
- Destroy instances that are no longer needed
- Clean up threads and loops properly
- Use object pooling for frequently created/destroyed objects

### Avoid Common Performance Pitfalls
- Don't use `while true do` without `wait()` or `task.wait()`
- Avoid calling expensive functions in RenderStepped
- Cache frequently accessed instances and services
- Use CollectionService instead of searching through all parts

### Good Performance Practices
```lua
-- Cache services and instances
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Clean up connections
local connection = workspace.ChildAdded:Connect(function(child)
	-- Handle new parts
end)

-- Later...
connection:Disconnect()
```

## Code Organization

### File Structure
- Keep related functionality together
- Use ModuleScripts for reusable code
- Separate client and server logic clearly
- Group similar scripts in folders

### Modular Design
- Write small, focused functions
- Make modules that do one thing well
- Use clear, descriptive names
- Document complex functions with comments

### Example Module Structure
```lua
-- PlayerManager module
local PlayerManager = {}

function PlayerManager.onPlayerJoined(player)
	-- Handle player joining
end

function PlayerManager.onPlayerLeft(player)
	-- Handle player leaving
end

return PlayerManager
```

## Debugging and Development

### Effective Debugging
- Use `print()` to understand code flow
- Use `warn()` for important messages
- Check the Output window frequently
- Test edge cases and error conditions

### Development Workflow
- Make small changes and test often
- Use version control (Git) for important milestones
- Keep backup copies of working features
- Document major decisions and changes

## Roblox-Specific Guidelines

### Working with Instances
- Use `WaitForChild()` when instances might not exist yet
- Check if instances exist before using them
- Use `FindFirstChild()` when you're not sure if something exists
- Be careful with `Instance:Destroy()` - it can't be undone

### Event Handling
- Connect to events at the right time (usually when the game starts)
- Store connections so you can disconnect them later
- Use anonymous functions sparingly - named functions are easier to debug
- Be careful with event loops and infinite recursion

### UI Development
- Test UI on different screen sizes
- Use scale instead of offset when possible
- Keep UI responsive and intuitive
- Provide feedback for player actions

## Learning Progression

### Start Here
1. Basic scripting with ServerScriptService and StarterPlayerScripts
2. Simple part manipulation and player detection
3. Basic GUI creation and interaction
4. Understanding Services and their purposes

### Then Move To
1. RemoteEvents for client-server communication
2. DataStores for saving player data
3. More complex game mechanics
4. Advanced scripting patterns

### Advanced Topics (Later)
1. Custom physics and math
2. Complex data structures
3. Performance optimization
4. Advanced UI systems

Remember: Focus on building fun games and learning through experimentation!