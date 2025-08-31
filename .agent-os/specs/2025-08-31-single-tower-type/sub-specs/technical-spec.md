# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-08-31-single-tower-type/spec.md

> Created: 2025-08-31
> Version: 1.0.0

## Technical Requirements

### Core Systems Architecture

#### TowerService (Singleton Service)
- **Location**: `src/server/services/TowerService.lua`
- **Responsibilities**: 
  - Manage all tower instances and lifecycle
  - Handle tower placement requests and validation
  - Coordinate between towers and other game systems
  - Provide tower creation and destruction methods

#### Tower ModuleScript
- **Location**: `src/server/entities/Tower.lua`
- **Responsibilities**:
  - Individual tower behavior and state management
  - Enemy detection within range using Region3 or magnitude checks
  - Target selection using closest-enemy algorithm
  - Firing rate management and cooldown tracking
  - Projectile creation and firing

#### Projectile System
- **Location**: `src/server/entities/Projectile.lua`
- **Responsibilities**:
  - Create visual projectiles with proper trajectory
  - Handle projectile travel using TweenService
  - Apply damage on target hit or proximity
  - Clean up projectile instances after impact

### Tower Placement System

#### Placement Validation
```lua
-- Core validation checks
- Position within game boundaries
- No collision with existing towers
- No collision with enemy path
- Valid surface/terrain for placement
```

#### Placement Process
1. Player clicks on game world
2. Client sends placement request to server
3. Server validates placement location
4. Server creates tower instance if valid
5. Server updates all clients with new tower

### Combat Mechanics

#### Enemy Detection
- **Method**: Magnitude-based detection within tower range
- **Frequency**: Every 0.1 seconds via RunService.Heartbeat
- **Range**: Configurable radius (default 20 studs)

#### Targeting Algorithm
```lua
-- Simple closest-enemy targeting
1. Get all enemies within range
2. Calculate distance to each enemy
3. Select enemy with shortest distance
4. Maintain target until out of range or destroyed
```

#### Projectile Physics
- **Travel**: Linear interpolation using TweenService
- **Speed**: Configurable (default 50 studs/second)
- **Damage**: Fixed damage value per tower type
- **Hit Detection**: Distance-based proximity checking

### Performance Considerations

#### Update Frequency
- Tower targeting: 10 FPS (every 0.1 seconds)
- Projectile updates: 30 FPS via TweenService
- Placement validation: On-demand only

#### Memory Management
- Projectile cleanup after impact or timeout
- Tower cleanup on destruction
- Event connection cleanup on tower removal

## Approach

### Implementation Phases

#### Phase 1: Core Tower Structure
1. Create TowerService singleton
2. Implement basic Tower ModuleScript
3. Set up tower placement system
4. Add basic tower visualization

#### Phase 2: Combat System
1. Implement enemy detection logic
2. Add targeting system
3. Create projectile system
4. Integrate damage application

#### Phase 3: Visual Polish
1. Add range visualization
2. Improve tower and projectile models
3. Add placement preview system
4. Enhance visual feedback

### Integration Points

#### With Existing Systems
- **EnemyService**: Get enemy positions and health
- **WaveService**: React to wave start/end events
- **GameManager**: Handle game state changes
- **Client UI**: Communicate tower placement feedback

#### Event Communication
```lua
-- Server Events
TowerService.TowerPlaced:Fire(tower, position)
TowerService.TowerDestroyed:Fire(tower)
TowerService.ProjectileFired:Fire(tower, target)

-- Integration Events
EnemyService.EnemyDestroyed:Connect(onEnemyDestroyed)
GameManager.GameStateChanged:Connect(onGameStateChanged)
```

### Configuration System

#### Tower Stats
```lua
local TOWER_CONFIG = {
    damage = 25,
    range = 20,
    fireRate = 1.0, -- shots per second
    projectileSpeed = 50,
    cost = 100 -- for future economy system
}
```

## External Dependencies

### Roblox Services
- **RunService**: Game loop and update cycles
- **TweenService**: Projectile movement animation
- **UserInputService**: Player interaction detection
- **ReplicatedStorage**: Shared constants and utilities

### Custom Systems (Already Implemented)
- **EnemyService**: Enemy management and health system
- **WaveService**: Enemy wave spawning and management
- **GameManager**: Core game state and loop management

### Required Assets
- Basic tower 3D model (simple geometric shapes)
- Projectile visual (sphere or cylinder)
- Range indicator effect (translucent sphere)
- Placement preview materials

### Future Integration Points
- Economy system for tower costs
- Multiple tower types system
- Tower upgrade system
- Save/load game state system