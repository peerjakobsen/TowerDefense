# Tower Defense Learning Game

An educational Roblox game designed to teach AI programming and iterative development through practical tower defense implementation. This project emphasizes learning pathfinding, decision trees, and state machines within a modular architecture.

## 🎯 Project Overview

This tower defense game serves as a hands-on learning platform for AI programming concepts, featuring:

- **Educational Focus**: Each phase introduces new AI programming concepts
- **Modular Architecture**: Clean separation of concerns with service-based design
- **Progressive Complexity**: Four development phases from basic mechanics to advanced AI
- **Roblox Integration**: Leverages native Roblox services like PathfindingService

## 🏗️ Architecture

### Code Organization
```
src/
├── shared/          # ReplicatedStorage - utilities and constants shared between client/server
│   ├── constants/   # Game configuration and settings
│   └── LogService   # Logging utility with Studio console and HTTP support
├── server/          # ServerScriptService - game logic, AI systems, entity management
│   └── services/    # Singleton game system services (MapService, etc.)
└── client/          # StarterPlayerScripts - UI, effects, client-side interactions
```

### Key Technical Patterns
- **ModuleScript Architecture**: All game systems as Roblox ModuleScripts for modularity
- **Service Pattern**: Singleton services for core game systems (WaveService, TowerService, etc.)
- **Event-Driven Communication**: BindableEvents for loose coupling between systems
- **State Machines**: Custom implementations for enemy and tower behaviors
- **PathfindingService Integration**: Native Roblox pathfinding for enemy navigation

## 🚀 Development Roadmap

### ✅ Phase 1: Foundation (In Progress)
**Goal:** Establish basic game loop and core mechanics  
**Success Criteria:** Player can place one tower that successfully shoots at and destroys moving enemies

#### Features
- [x] **Create rectangular map with spawn/goal points** - Basic map layout with clearly defined start and end positions
- [ ] **Implement linear enemy movement** - Enemy moves in straight line from spawn to goal
- [ ] **Build single tower type** - Tower detects enemies in range and shoots projectiles
- [ ] **Basic health/score UI** - Simple interface showing player health and score
- [ ] **Enemy destruction system** - Enemies take damage and are removed when health reaches zero

### 📋 Phase 2: Pathfinding & Core Systems
**Goal:** Implement proper AI movement and expand enemy variety  
**Success Criteria:** Multiple enemy types successfully pathfind along complex routes while taking damage from towers

#### Features
- [ ] **Integrate PathfindingService** - Replace linear movement with Roblox's native pathfinding
- [ ] **Create winding path with obstacles** - Design map with obstacles that require navigation
- [ ] **Add multiple enemy types** - 2-3 enemy variants with different speeds, health, and rewards
- [ ] **Implement damage/health system** - Proper damage calculation with visual feedback
- [ ] **Add particle effects** - Visual effects for shots and enemy destruction
- [ ] **Enemy spawn management** - Basic spawning system for different enemy types

### 📋 Phase 3: AI Decision Making
**Goal:** Build sophisticated AI systems for both towers and enemies  
**Success Criteria:** Towers intelligently select targets based on configurable strategies, enemies make pathfinding decisions

#### Features
- [ ] **Tower targeting decision trees** - Multiple targeting strategies (closest, strongest, weakest)
- [ ] **Enemy path choice AI** - Enemies select between multiple route options
- [ ] **Wave spawning system** - Automatic wave management with increasing difficulty
- [ ] **Enemy state machines** - Implement idle, moving, attacking, dying states
- [ ] **Tower range visualization** - Visual indicators for tower range and targeting
- [ ] **AI behavior configuration** - Settings to adjust AI decision parameters

### 📋 Phase 4: Strategic Depth
**Goal:** Add strategic gameplay elements and advanced AI  
**Success Criteria:** Complete tower defense experience with strategic depth and adaptive AI opponents

#### Features
- [ ] **Multiple tower types** - 3-4 distinct tower types with unique behaviors
- [ ] **Tower upgrade system** - Branching upgrade paths for each tower type
- [ ] **Resource economy** - Money system for earning from kills and spending on towers
- [ ] **Adaptive enemy AI** - Enemies respond intelligently to player tower placement
- [ ] **Boss enemy system** - Special enemies with unique behaviors and challenges
- [ ] **Wave progression** - Comprehensive wave management with scaling difficulty
- [ ] **Game balance tuning** - Adjust costs, damage, and timing for optimal gameplay

## 🛠️ Current Implementation

### MapService (Completed)
The foundation rectangular game map has been fully implemented:

- **100x100 stud base platform** in gray at world origin
- **Green spawn marker** at (-45, 1, 0) on the left edge
- **Red goal marker** at (45, 1, 0) on the right edge
- **Tower placement validation** with path corridor protection
- **Complete API** for future service integration

#### API Methods
```lua
MapService.Initialize()                    -- Create map platform and markers
MapService.GetSpawnPosition()             -- Returns Vector3 spawn position
MapService.GetGoalPosition()              -- Returns Vector3 goal position
MapService.IsValidTowerPosition(position) -- Validates tower placement
MapService.IsInitialized()                -- Check initialization status
```

## 🚀 Getting Started

### Prerequisites
- Roblox Studio installed
- Basic Lua programming knowledge
- [Rojo](https://rojo.space/) for project management

### Setup
1. Clone this repository
2. Install Rojo: `cargo install rojo`
3. Open terminal in project directory
4. Run `rojo serve` to start live sync
5. Open Roblox Studio and connect to localhost:34872
6. The game map will automatically initialize when you play

### Testing
Use these commands in Roblox Studio's Command Bar to test functionality:

```lua
-- Test server-side MapConstants access
require(game.ServerScriptService.Server["test-constants"]).run()

-- Test comprehensive MapService integration  
require(game.ServerScriptService.Server["test-integration"]).testIntegration()
```

## 🏛️ Core Services Used

- **PathfindingService**: Primary system for enemy AI movement and navigation
- **RunService**: Game loop management and frame-based updates
- **UserInputService**: Player interactions (tower placement, UI)
- **TweenService**: Smooth animations and visual transitions

## 📚 Learning Objectives

By completing this project, you'll learn:

1. **Phase 1**: Basic game architecture and Roblox development patterns
2. **Phase 2**: PathfindingService integration and entity management
3. **Phase 3**: AI decision trees and state machine implementation
4. **Phase 4**: Advanced AI systems and game balance

## 🔧 Development Workflow

This project uses Agent OS for structured development:
- **Specifications**: Detailed feature specs in `.agent-os/specs/`
- **Roadmap**: Phase-based development tracking
- **Modular Implementation**: Each feature as a separate specification

## 🤝 Contributing

This is an educational project designed for learning AI programming concepts. Each phase builds upon the previous, introducing new complexity and teaching opportunities.

## 📄 License

This project is for educational purposes. Feel free to use and modify for learning AI programming with Roblox.

---

**Next Up:** Implement linear enemy movement to complete Phase 1 foundation!