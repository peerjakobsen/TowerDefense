# Technical Stack

## Application Framework
- **Platform:** Roblox Studio
- **Language:** Lua 5.1 (Luau)
- **Version Control:** Git with Rojo for syncing

## Development Environment
- **Primary IDE:** Cursor
- **Roblox Sync:** Rojo serve for live development
- **Code Organization:** ModuleScript architecture

## Core Roblox Services
- **PathfindingService:** Enemy navigation and AI movement
- **RunService:** Game loop and frame-based updates
- **UserInputService:** Player interaction handling
- **TweenService:** Smooth animations and effects
- **SoundService:** Audio feedback and music
- **Lighting:** Visual effects and atmosphere

## Architecture Patterns
- **Module System:** Roblox ModuleScript organization
- **Event-Driven:** BindableEvents for system communication
- **State Management:** Custom state machines for entities
- **Service Layer:** Singleton services for game systems

## Asset Management
- **3D Models:** Roblox Studio built-in parts and meshes
- **UI Framework:** Roblox GUI system with ScreenGuis
- **Animations:** Roblox Animation system
- **Audio:** Roblox Sound objects
- **Effects:** ParticleEmitter and Beam objects

## Testing Approach
- **Testing Strategy:** No unit testing (as specified)
- **Validation:** Manual testing in Roblox Studio
- **Debugging:** Roblox output console and print statements
- **Quality Assurance:** Incremental development with validation at each phase

## Development Workflow
- **Live Sync:** `rojo serve` for real-time code updates
- **Build Process:** No build scripts needed (Roblox handles compilation)
- **Deployment:** Roblox Studio publish to platform
- **Version Control:** Git tracking of source files only

## Performance Considerations
- **Multiplayer Ready:** Designed for potential multi-player expansion
- **Efficient Pathfinding:** Cached paths and optimized NavMesh usage
- **Memory Management:** Proper cleanup of destroyed entities
- **Frame Rate:** 60 FPS target with efficient update loops

## Code Organization Structure
```
src/
├── shared/          # Shared utilities and constants
├── server/          # Server-side game logic
│   ├── services/    # Game system services
│   ├── entities/    # Enemy and tower logic
│   └── ai/          # AI decision systems
├── client/          # Client-side UI and effects
└── config/          # Game configuration and settings
```