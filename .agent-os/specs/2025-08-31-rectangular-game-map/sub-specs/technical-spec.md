# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-08-31-rectangular-game-map/spec.md

> Created: 2025-08-31
> Version: 1.0.0

## Technical Requirements

### Map Structure (Phase 1 - Simple Approach)
- **Dimensions**: 100x100 studs rectangular area (configurable via constants)
- **Base Platform**: Single large Roblox Part for the play area floor
- **Spawn Point**: Bright green Part positioned at left edge (-45, 1, 0)
- **Goal Point**: Bright red Part positioned at right edge (45, 1, 0)
- **Straight Path**: Clear line-of-sight from spawn to goal with no obstacles
- **Path Corridor**: Towers cannot be placed within a ±2 stud corridor along the straight path from spawn to goal (configurable via constant)

### ModuleScript Architecture
```lua
-- Server: src/server/services/MapService.luau
local MapService = {}

-- Shared: src/shared/constants/MapConstants.luau
-- return {
--   MAP_WIDTH = 100,
--   MAP_HEIGHT = 100,
--   BASE_THICKNESS = 1,
--   SPAWN_POSITION = Vector3.new(-45, 1, 0),
--   GOAL_POSITION = Vector3.new(45, 1, 0),
--   PATH_HALF_WIDTH = 2,
-- }

-- Public API
-- MapService.Initialize(): Creates base platform and S/G markers under Workspace.Map
-- MapService.GetSpawnPosition(): Vector3
-- MapService.GetGoalPosition(): Vector3
-- MapService.IsValidTowerPosition(position: Vector3): boolean (in-bounds and outside path corridor)
return MapService
```

### Linear Movement Support
- **Clear Path**: Unobstructed straight line from spawn to goal
- **Movement Calculation**: Simple Vector3 interpolation for enemy movement  
- **No Pathfinding**: Phase 1 uses basic position tweening, not PathfindingService
- **Future-Ready**: Structure allows Phase 2 pathfinding integration

### Basic Tower Placement
- **Simple Validation**: Check if position is within bounds and outside the path corridor
- **Grid Snapping**: Optional 4x4 stud grid alignment for consistent placement
- **Path Protection**: Prevent tower placement within `PATH_HALF_WIDTH` of the spawn→goal line

## Approach

### Implementation Strategy (Phase 1 Focus)
1. **Base Platform Creation**: Create single large Part for the rectangular play area
2. **Marker Placement**: Position bright green spawn and red goal markers (slightly elevated Y for visibility)
3. **Basic Validation**: Simple coordinate-based tower placement checking including a path corridor exclusion
4. **Clean Structure**: Educational code that's easy to understand and extend
5. **Testing**: Verify spawn/goal positioning, corridor thickness, and tower placement validation

### Code Organization
```
src/server/services/MapService.luau     # Simple map creation and management (ServerScriptService)
src/shared/constants/MapConstants.luau  # Map dimensions and key positions (ReplicatedStorage/Shared/constants)
```

Rojo mapping note: Update `default.project.json` to include
`src/server/services` under `ServerScriptService` and `src/shared/constants`
under `ReplicatedStorage/Shared/constants`.

### Visual Design (Simple & Clear)
- **Base Platform**: Gray baseplate (Color3.fromRGB(128, 128, 128)), Size `Vector3.new(100, 1, 100)`
- **Spawn Point**: Bright green (Color3.fromRGB(0, 255, 0)), at `Vector3.new(-45, 1, 0)`
- **Goal Point**: Bright red (Color3.fromRGB(255, 0, 0)), at `Vector3.new(45, 1, 0)`
- **Markers**: Small Parts (e.g., `Vector3.new(2, 2, 2)`) slightly elevated (Y=1) for visibility
- **Corridor**: Use `PATH_HALF_WIDTH = 2` studs as the default exclusion radius

## External Dependencies

### Roblox Services (Phase 1 Only)
- **Workspace**: For creating and positioning Part instances
- **ReplicatedStorage**: For storing the MapService ModuleScript

### Project Dependencies
- **LogService**: For development debugging (from existing codebase at `src/shared/LogService.luau`); use for map init/validation messages
- **Future services**: MapService will provide coordinates to:
  - WaveService (spawn point for enemy creation)
  - TowerService (validation for tower placement)
  - EnemyService (goal point for movement targets)

### Performance Considerations (Phase 1)
- **Minimal Part Count**: Only 3 Parts total (base platform + 2 markers)
- **Static Structure**: No dynamic creation/destruction during gameplay
- **Simple Calculations**: Basic coordinate math for tower placement validation
- **Future-Proof**: Design allows easy PathfindingService addition in Phase 2
