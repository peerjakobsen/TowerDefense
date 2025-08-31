# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tower Defense Learning Game is an educational Roblox game designed to teach AI programming and iterative development through practical tower defense implementation. The project emphasizes learning pathfinding, decision trees, and state machines within a modular architecture.

## Architecture

### Code Organization
```
src/
├── shared/          # ReplicatedStorage - utilities and constants shared between client/server
├── server/          # ServerScriptService - game logic, AI systems, entity management
└── client/          # StarterPlayerScripts - UI, effects, client-side interactions
```

### Planned Architecture (to be implemented)
```
src/
├── shared/
│   ├── constants/   # Game configuration and settings
│   └── utils/       # Shared utility functions
├── server/
│   ├── services/    # Singleton game system services
│   ├── entities/    # Enemy and tower logic modules
│   └── ai/          # AI decision systems and state machines
└── client/
│   ├── ui/          # GUI management
│   └── effects/     # Visual and audio effects
```

### Key Technical Patterns
- **ModuleScript Architecture**: All game systems as Roblox ModuleScripts for modularity
- **Service Pattern**: Singleton services for core game systems (WaveService, TowerService, etc.)
- **Event-Driven Communication**: BindableEvents for loose coupling between systems
- **State Machines**: Custom implementations for enemy and tower behaviors
- **PathfindingService Integration**: Native Roblox pathfinding for enemy navigation

## Roblox-Specific Considerations

### Core Services Usage
- **PathfindingService**: Primary system for enemy AI movement and navigation
- **RunService**: Game loop management and frame-based updates
- **UserInputService**: Player interactions (tower placement, UI)
- **TweenService**: Smooth animations and visual transitions

### Development Constraints
- **No Unit Testing**: Manual testing in Roblox Studio only
- **No Build Scripts**: Roblox handles compilation, focus on `rojo serve` workflow
- **Educational Focus**: Code should prioritize readability and learning over optimization
- **Incremental Development**: Each phase must result in a playable game state

## Agent OS Integration

This project uses Agent OS for structured development:
- **Mission**: `.agent-os/product/mission.md` - Complete product vision
- **Tech Stack**: `.agent-os/product/tech-stack.md` - Technical architecture details  
- **Roadmap**: `.agent-os/product/roadmap.md` - 4-phase development plan
- **Mission Lite**: `.agent-os/product/mission-lite.md` - Condensed context for AI

### Development Phases
1. **Foundation**: Basic game loop with simple tower and enemy
2. **Pathfinding & Core Systems**: PathfindingService integration, multiple enemy types
3. **AI Decision Making**: Tower targeting strategies, enemy state machines
4. **Strategic Depth**: Multiple tower types, economy system, adaptive AI