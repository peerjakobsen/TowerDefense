# MapService API Documentation

## Overview
MapService provides core functionality for managing the rectangular game map, including platform creation, spawn/goal markers, and tower placement validation.

## Public Methods

### MapService.Initialize()
Initializes the game map by creating the base platform and markers in Workspace.Map.

**Returns:** `void`
**Throws:** None (idempotent - safe to call multiple times)

**Creates:**
- `Workspace.Map` folder
- Base platform (100x1x100 studs, gray, at origin)
- Spawn marker (green, 2x2x2 studs, at spawn position + elevation)
- Goal marker (red, 2x2x2 studs, at goal position + elevation)

### MapService.GetSpawnPosition()
Returns the spawn position for enemies.

**Returns:** `Vector3` - The spawn position from MapConstants
**Throws:** Error if called before initialization

**Usage for WaveService:**
```lua
local spawnPos = MapService.GetSpawnPosition()
-- Use for enemy spawn location
```

### MapService.GetGoalPosition()
Returns the goal position for enemy pathfinding.

**Returns:** `Vector3` - The goal position from MapConstants  
**Throws:** Error if called before initialization

**Usage for WaveService:**
```lua
local goalPos = MapService.GetGoalPosition()
-- Use as enemy pathfinding target
```

### MapService.IsValidTowerPosition(position: Vector3)
Validates if a position is suitable for tower placement.

**Parameters:**
- `position: Vector3` - The world position to validate

**Returns:** `boolean` - True if position is valid for tower placement

**Validation Rules:**
1. Position must be within map bounds (±50 studs in X and Z)
2. Position must be outside the path corridor (>2 studs from spawn-goal line)

**Usage for TowerService:**
```lua
local position = Vector3.new(10, 1, 15)
if MapService.IsValidTowerPosition(position) then
    -- Safe to place tower here
    TowerService.PlaceTower(towerType, position)
else
    -- Show error to player
end
```

### MapService.IsInitialized()
Checks if the map has been properly initialized.

**Returns:** `boolean` - True if map is ready

**Usage for Service Dependencies:**
```lua
-- Wait for map before starting other services
if not MapService.IsInitialized() then
    MapService.Initialize()
end
```

### MapService.GetMapObjects()
Returns references to created map objects for testing/debugging.

**Returns:** `table | nil` - Map object references or nil if not initialized

**Structure:**
```lua
{
    mapFolder: Folder,
    basePlatform: Part,
    spawnMarker: Part,
    goalMarker: Part
}
```

## Integration Points for Future Services

### WaveService Integration
- Use `GetSpawnPosition()` for enemy spawn locations
- Use `GetGoalPosition()` for pathfinding targets
- Map initialization must complete before wave spawning

### TowerService Integration
- Use `IsValidTowerPosition()` before all tower placements
- Consider map bounds for tower range calculations
- Use spawn/goal positions for tower targeting logic

### Coordinate System
- Origin (0,0,0) is center of base platform
- Spawn at (-45, 1, 0) - left side of map
- Goal at (45, 1, 0) - right side of map
- Path corridor is Z=0 ±2 studs (horizontal line between spawn and goal)

## Constants Integration
All map dimensions and positions are defined in `MapConstants.luau`:
- `MAP_WIDTH`, `MAP_HEIGHT` - Map dimensions
- `SPAWN_POSITION`, `GOAL_POSITION` - Key locations
- `PATH_HALF_WIDTH` - Exclusion zone for towers
- Visual properties for colors and sizes