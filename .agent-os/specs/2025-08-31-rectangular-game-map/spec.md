# Spec Requirements Document

> Spec: Rectangular Game Map
> Created: 2025-08-31
> Status: Planning

## Overview

Create a rectangular game map that serves as the play area with one spawn point (S) where enemies enter and one goal point (G) where they attempt to exit. This map will establish the enemy's linear path for Phase 1, forming the foundation for tower placement and enemy movement in the educational Tower Defense game.

Note on implementation consistency:
- MapService resides in ServerScriptService and creates Parts in Workspace.
- Shared constants live in ReplicatedStorage under `Shared/constants`.
- File extensions in this repository are `.luau` (not `.lua`).

## User Stories

### Basic Map Layout
As a player, I want to see a clear rectangular play area so I understand the game boundaries and where gameplay takes place.

### Clear Path Visualization  
As a player, I want to see clearly marked spawn and goal points so I know where enemies will appear and where they're trying to reach along a simple straight path.

### Tower Placement Foundation
As a player, I want to place towers on designated areas of the map so I can prepare defenses for the linear enemy movement in Phase 1.

## Spec Scope

1. **Basic Map Structure** - Create rectangular play area using simple Roblox Parts
2. **Spawn Point Marker** - Clearly visible spawn point (S) where enemies will appear  
3. **Goal Point Marker** - Clearly visible goal point (G) where enemies attempt to reach
4. **Straight Path Support** - Clear straight-line path from spawn to goal for Phase 1 linear movement, with a defined path corridor thickness (±2 studs) to prevent tower placement on the path
5. **Tower Placement Areas** - Define valid areas where players can place towers
6. **Visual Boundaries** - Clear play area boundaries to prevent confusion

## Out of Scope

- PathfindingService integration (reserved for Phase 2)
- NavMesh generation and complex pathfinding
- Multiple spawn or goal points
- Dynamic map modification during gameplay
- Advanced visual effects or animations
- Obstacle placement or winding paths
- Map editor functionality

## Expected Deliverable

A simple rectangular game map implemented as a ModuleScript that supports Phase 1's linear enemy movement. The map will provide:

1. **MapService ModuleScript** - Basic map initialization and coordinate management (ServerScriptService)
2. **Clear visual markers** for spawn point (S) and goal point (G) 
3. **Straight-line path** from spawn to goal for simple enemy movement
4. **Basic tower placement areas** - designated zones where towers can be built and a rule preventing placement within the path corridor
5. **Clean, educational code** that demonstrates fundamental Roblox Part creation

## Spec Documentation

 - Tasks: @.agent-os/specs/2025-08-31-rectangular-game-map/tasks.md (to be provided separately)
 - Technical Specification: @.agent-os/specs/2025-08-31-rectangular-game-map/sub-specs/technical-spec.md
