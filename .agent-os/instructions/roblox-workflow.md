---
description: Simple Roblox Development Workflow for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Simple Roblox Development Workflow

## Overview

Streamlined workflow for developing Roblox games using Rojo for code syncing, focused on learning and rapid iteration without complex tooling.

## Initial Setup

### Prerequisites
- Roblox Studio installed
- Rojo installed (`cargo install rojo` or download from GitHub)
- VS Code or Cursor with Luau LSP extension
- Git for version control

### Project Initialization
1. Create project folder: `mkdir my-roblox-game && cd my-roblox-game`
2. Initialize Rojo project: `rojo init`
3. Initialize Git: `git init`
4. Create basic folder structure:
   ```
   src/
   ├── server/     # ServerScriptService scripts
   ├── client/     # StarterPlayerScripts
   ├── shared/     # ReplicatedStorage modules
   └── workspace/  # Workspace models/parts
   ```

### Rojo Configuration
The default `default.project.json` should map folders to Roblox services:

```json
{
  "name": "my-roblox-game",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "$path": "src/server"
    },
    "StarterPlayer": {
      "StarterPlayerScripts": {
        "$path": "src/client"
      }
    },
    "ReplicatedStorage": {
      "$path": "src/shared"
    },
    "Workspace": {
      "$path": "src/workspace"
    }
  }
}
```

## Daily Development Workflow

### Start Development Session
1. Open project folder in VS Code/Cursor
2. Start Rojo server: `rojo serve`
3. Open Roblox Studio
4. In Studio, go to Plugins → Rojo → Connect (connect to localhost:34872)
5. Start coding in your editor

### Development Loop
1. **Write Code** in your editor (VS Code/Cursor)
2. **Save File** - Rojo automatically syncs to Studio
3. **Test Immediately** in Studio - no build process needed!
4. **Debug** using print statements and Studio output
5. **Iterate** quickly - make changes and test instantly

### Key Commands
- `rojo serve` - Start live development server
- `rojo build --output game.rbxl` - Build for publishing (rarely needed)
- **NEVER** create .rbxl files for testing - always use `rojo serve`

## File Organization Best Practices

### Server Scripts (`src/server/`)
- Main game logic
- Player management
- Game state management
- Security-critical code

Example structure:
```
src/server/
├── PlayerManager.lua
├── GameManager.lua
├── Events/
│   ├── PlayerJoined.lua
│   └── PlayerLeft.lua
└── Data/
    └── PlayerData.lua
```

### Client Scripts (`src/client/`)
- UI logic
- Input handling
- Client-side effects
- Local player interactions

Example structure:
```
src/client/
├── UI/
│   ├── MainMenu.lua
│   └── HUD.lua
├── Input/
│   └── KeyboardHandler.lua
└── Effects/
    └── ParticleEffects.lua
```

### Shared Modules (`src/shared/`)
- Utility functions
- Constants
- Shared data structures
- Helper modules

Example structure:
```
src/shared/
├── Utils/
│   ├── MathUtils.lua
│   └── StringUtils.lua
├── Constants.lua
└── Types.lua
```

## Testing and Debugging

### In-Studio Testing
- Use print() for debugging output
- Check Output window for errors and messages
- Use breakpoints in Studio debugger when needed
- Test with multiple players using Studio's player emulation

### Common Debug Patterns
```lua
-- Debug player actions
print("Player", player.Name, "performed action:", actionName)

-- Debug values
print("Health:", player.Character.Humanoid.Health)

-- Debug function calls
local function myFunction(param)
    print("myFunction called with:", param)
    -- function logic
end
```

## Version Control

### Git Setup
Create `.gitignore`:
```
# Roblox Studio files
*.rbxl
*.rbxlx
*.rbxm

# OS files
.DS_Store
Thumbs.db

# Rojo build output
build/
```

### Commit Strategy
- Commit working features frequently
- Use descriptive commit messages
- Don't commit broken code
- Keep commits focused on single features

## Publishing Your Game

### When Ready to Publish
1. Test thoroughly in Studio
2. Optional: `rojo build --output MyGame.rbxl` to create publishable file
3. In Studio: File → Publish to Roblox
4. Configure game settings and permissions
5. Make game public when ready

### Publishing Checklist
- [ ] Game works without errors
- [ ] All features tested with multiple players
- [ ] Game description and thumbnail added
- [ ] Appropriate age rating set
- [ ] Game privacy settings configured

## Troubleshooting

### Common Issues

**Rojo won't connect:**
- Check that `rojo serve` is running
- Verify port 34872 is not blocked
- Restart Rojo server and try connecting again

**Scripts not updating:**
- Check Output window for sync errors
- Verify file paths match project.json configuration
- Restart Rojo server if sync stops working

**Studio crashes or behaves strangely:**
- Save your place in Studio
- Restart Studio and reconnect to Rojo
- Check for infinite loops in your scripts

### Getting Help
- Roblox Developer Hub: https://developer.roblox.com/
- Roblox DevForum: https://devforum.roblox.com/
- Rojo Documentation: https://rojo.space/docs/

## Remember
- **ALWAYS use `rojo serve` for development** - never create .rbxl files for testing
- Keep it simple - focus on learning and building
- Test frequently in Studio
- Have fun and experiment!

The goal is rapid iteration and learning, not perfect tooling. Start simple and add complexity as you grow more comfortable with Roblox development.