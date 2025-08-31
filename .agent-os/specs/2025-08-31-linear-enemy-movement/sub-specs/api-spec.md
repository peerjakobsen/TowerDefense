# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-08-31-linear-enemy-movement/spec.md

> Created: 2025-08-31
> Version: 1.0.0

## Endpoints

### EnemyService API (Phase 1)

#### Core Service Methods
```lua
EnemyService:SpawnEnemy(spawnPoint: Vector3, targetPoint: Vector3?) -> Enemy
```
- Purpose: Creates and initializes a new enemy at the specified spawn point
- Parameters: `spawnPoint` - World position for enemy spawn; `targetPoint` - optional override for default goal
- Returns: Enemy instance initialized for straight-line movement
- Side Effects: Adds enemy to ActiveEnemies table, creates enemy Part in workspace

```lua
EnemyService:RemoveEnemy(enemy: Enemy) -> ()
```
- Purpose: Safely removes enemy from game and cleans up resources
- Parameters: `enemy` - Enemy instance to remove
- Side Effects: Removes from ActiveEnemies, destroys enemy Part, cleans up references

```lua
EnemyService:GetActiveEnemies() -> {Enemy}
```
- Purpose: Returns array of all currently active enemies
- Returns: Table of Enemy instances currently in the game
- Use Case: Tower targeting system integration

```lua
EnemyService:SetSpawnPoints(points: {Vector3}) -> ()
```
- Purpose: Configures spawn locations for enemy creation
- Parameters: `points` - Array of world positions for enemy spawning

```lua
EnemyService:SetTargetPoint(target: Vector3) -> ()
```
- Purpose: Sets the destination point enemies will move toward
- Parameters: `target` - World position of player base/target

### Enemy Entity API (Phase 1)

#### Core Enemy Methods
```lua
Enemy.new(spawnPos: Vector3, targetPos: Vector3) -> Enemy
```
- **Purpose**: Constructor for new enemy instance
- **Parameters**: 
  - `spawnPos` - Starting world position
  - `targetPos` - Destination world position
- **Returns**: Initialized Enemy instance with linear movement setup

```lua
Enemy:GetPosition() -> Vector3
```
- **Purpose**: Returns current world position of enemy
- **Returns**: Current enemy Part position
- **Use Case**: Tower targeting calculations

```lua
Enemy:GetHealth() -> number
```
- **Purpose**: Returns current enemy health value
- **Returns**: Current health (0-100)
- **Use Case**: Tower damage assessment

```lua
Enemy:TakeDamage(damage: number) -> void
```
- **Purpose**: Applies damage to enemy and handles destruction
- **Parameters**: `damage` - Damage amount to apply
- **Side Effects**: Reduces health, triggers destruction if health <= 0

```lua
Enemy:GetState() -> string
```
- **Purpose**: Returns current enemy state for game logic
- **Returns**: One of "Spawning", "Moving", "ReachedTarget", "Destroyed"

```lua
Enemy:GetSpeed() -> number
```
- **Purpose**: Returns current movement speed
- **Returns**: Movement speed in studs per second

### Movement Controller (Phase 1)
```lua
-- Handles straight-line enemy movement
MovementController:UpdateEnemyPosition(enemy: Enemy, deltaTime: number)
MovementController:CheckArrival(enemy: Enemy, threshold: number) -> boolean
MovementController:HandleArrival(enemy: Enemy)
```

## Controllers

### Spawn Controller
```lua
-- Manages enemy spawning logic and timing
SpawnController:ScheduleEnemySpawn(delay: number, spawnPoint: Vector3)
SpawnController:GetNextSpawnPoint() -> Vector3
SpawnController:CanSpawnEnemy() -> boolean
```

### Health Controller
```lua
-- Manages enemy health and damage processing
HealthController:ProcessDamage(enemy: Enemy, damage: number, source: any)
HealthController:HandleEnemyDestruction(enemy: Enemy)
HealthController:GetHealthPercentage(enemy: Enemy) -> number
```

## Events API

### BindableEvents for System Communication
```lua
-- EnemySpawned: Fired when new enemy enters game
EnemySpawned:Fire(enemy: Enemy)

-- EnemyDestroyed: Fired when enemy is removed from game  
EnemyDestroyed:Fire(enemy: Enemy, reason: string)

-- EnemyReachedTarget: Fired when enemy reaches player base
EnemyReachedTarget:Fire(enemy: Enemy)

-- EnemyDamaged: Fired when enemy takes damage
EnemyDamaged:Fire(enemy: Enemy, damage: number, newHealth: number)
```
