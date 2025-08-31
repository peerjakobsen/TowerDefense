# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-08-31-linear-enemy-movement/spec.md

> Created: 2025-08-31
> Version: 1.0.0

## Technical Requirements

### Core Architecture (Phase 1 - Straight-Line)
- **Roblox ModuleScript Pattern**: All enemy logic implemented as ModuleScripts (.luau)
- **Service Singleton Pattern**: EnemyService as singleton managing all enemy instances
- **Movement Implementation**: Linear interpolation from spawn to goal; no PathfindingService
- **Event-Driven Communication**: BindableEvents for loose coupling with other game systems

### Performance Constraints
- **Target Enemy Count**: Support 5-10 concurrent enemies for Phase 1
- **Update Frequency**: Enemy position updates on RunService.Heartbeat (60 FPS target)
- **Memory Management**: Proper cleanup of enemy instances and movement data

### Roblox-Specific Implementation
- **Part-Based Enemies**: Enemies represented as Roblox Parts
- **Straight-Line Movement**: TweenService or manual interpolation toward goal
- **Workspace Integration**: Enemy parts created and managed in workspace folders
- **CollectionService Tags**: Tag enemies for efficient querying and management

## Approach

### 1. Core Service Architecture
```lua
-- EnemyService (ServerScriptService, .luau)
local EnemyService = {}
EnemyService.ActiveEnemies = {}
EnemyService.SpawnPoints = {}
EnemyService.TargetPoint = nil

function EnemyService:SpawnEnemy(spawnPoint: Vector3, targetPoint: Vector3?)
function EnemyService:RemoveEnemy(enemy)
function EnemyService:UpdateEnemies(deltaTime: number)
function EnemyService:GetActiveEnemies(): {any}
```

### 2. Enemy Entity Module
```lua
-- Enemy ModuleScript (.luau)
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(spawnPosition: Vector3, targetPosition: Vector3)
function Enemy:Update(deltaTime: number) -- linear movement toward target
function Enemy:GetPosition(): Vector3
function Enemy:GetSpeed(): number
function Enemy:TakeDamage(damage: number)
function Enemy:Destroy()
```

### 3. Movement Implementation
- **Linear Interpolation**: Move enemies toward the goal using normalized direction * speed * dt
- **Arrival Detection**: Threshold check at goal to mark completion
- **Tween Alternative**: Optional TweenService for simple straight-line tweens

### 4. State Management
```lua
local STATES = {
  SPAWNING = "Spawning",
  MOVING = "Moving",
  REACHED_TARGET = "ReachedTarget",
  DESTROYED = "Destroyed",
}
```

### 5. Placement, Mapping, and Logging
- **Module Placement**:
  - Server: `src/server/services/EnemyService.luau`
  - Shared (optional types/config): `src/shared/enemies/Enemy.luau`, `src/shared/constants/EnemyConstants.luau`
- **Rojo Mapping**: Update `default.project.json` to map `src/server/services` under `ServerScriptService` and `src/shared/*` under `ReplicatedStorage/Shared`
- **Logging**: Use `src/shared/LogService.luau` for spawn, movement, and completion logs

## External Dependencies

### Roblox Services
- **RunService**: Game loop integration for enemy updates
- **TweenService**: Optional for straight-line tweening
- **CollectionService**: Enemy instance management and querying
- **Workspace**: Enemy part creation and spatial management

### Game Systems Integration
- **TowerService**: Interface for tower targeting and damage dealing (future phase)
- **GameStateService**: Integration with wave management and game progression
- **EffectsService**: Visual feedback for enemy spawn/destruction (future phase)

### Configuration Dependencies
- **EnemyConstants**: Centralized enemy statistics (health, speed, spawn rates)
- **MapConstants**: Spawn/goal positions from Rectangular Map Phase 1
- **GameConstants**: Shared constants for timing, distances, and thresholds
