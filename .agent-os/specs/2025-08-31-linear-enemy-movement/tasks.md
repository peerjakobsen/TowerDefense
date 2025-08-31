# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-08-31-linear-enemy-movement/spec.md

> Created: 2025-08-31
> Status: Ready for Implementation

## Tasks

### 1. Enemy Constants and Configuration

**Objective**: Create centralized enemy configuration constants that define enemy characteristics and behavior parameters for Phase 1 linear movement.

- [ ] 1.1 Create `src/shared/constants/EnemyConstants.luau` with enemy health, speed, and timing constants
- [ ] 1.2 Add enemy visual properties (size, color, material) for basic enemy representation
- [ ] 1.3 Define enemy states enum (SPAWNING, MOVING, REACHED_TARGET, DESTROYED) 
- [ ] 1.4 Configure spawn timing and enemy limits for Phase 1 (5-10 concurrent enemies)
- [ ] 1.5 Add distance threshold constant for goal detection and cleanup
- [ ] 1.6 Update Rojo project mapping to include new constants file under ReplicatedStorage
- [ ] 1.7 Test constants accessibility from server scripts in Roblox Studio
- [ ] 1.8 Verify constants load correctly and values are reasonable for gameplay testing

### 2. Enemy Entity Module

**Objective**: Implement the core Enemy ModuleScript that handles individual enemy behavior, linear movement logic, and state management.

- [ ] 2.1 Create `src/shared/enemies/Enemy.luau` ModuleScript with Enemy class structure
- [ ] 2.2 Implement `Enemy.new()` constructor accepting spawn and target positions
- [ ] 2.3 Add health management system (`TakeDamage`, `GetHealth`, death detection)
- [ ] 2.4 Implement linear movement logic in `Update(deltaTime)` using direction vector and speed
- [ ] 2.5 Add position and state tracking methods (`GetPosition`, `GetState`, `SetState`)
- [ ] 2.6 Implement goal detection using distance threshold from EnemyConstants
- [ ] 2.7 Add proper cleanup and destruction logic in `Destroy()` method
- [ ] 2.8 Test Enemy module instantiation and basic movement calculation in Studio

### 3. Enemy Roblox Part Management

**Objective**: Create the visual representation system that manages enemy Parts in the Roblox workspace with proper organization and cleanup.

- [ ] 3.1 Add Part creation logic in Enemy module using workspace folders for organization
- [ ] 3.2 Implement CollectionService tagging for efficient enemy querying and management
- [ ] 3.3 Apply visual styling from EnemyConstants (size, color, material) to enemy Parts
- [ ] 3.4 Add Part position synchronization with Enemy logical position in Update loop
- [ ] 3.5 Implement proper Part cleanup when enemy is destroyed or reaches target
- [ ] 3.6 Create workspace folder structure ("Enemies") for organized enemy management
- [ ] 3.7 Test enemy Part creation and visual representation in Studio workspace
- [ ] 3.8 Verify Part cleanup works correctly when enemies are removed

### 4. EnemyService Core System

**Objective**: Develop the singleton EnemyService that manages the enemy lifecycle, spawning, updates, and integration with the game loop.

- [ ] 4.1 Create `src/server/services/EnemyService.luau` with singleton service pattern
- [ ] 4.2 Implement enemy spawning system using MapConstants for spawn/goal positions
- [ ] 4.3 Add active enemy tracking with proper data structures (ActiveEnemies table)
- [ ] 4.4 Create RunService.Heartbeat connection for 60 FPS enemy position updates
- [ ] 4.5 Implement enemy removal system for destroyed or completed enemies
- [ ] 4.6 Add enemy count limits and spawn timing controls from EnemyConstants
- [ ] 4.7 Create public API methods (SpawnEnemy, GetActiveEnemies, RemoveEnemy)
- [ ] 4.8 Test EnemyService initialization and basic enemy spawning in Studio

### 5. Linear Movement Implementation

**Objective**: Implement the core linear interpolation movement system that moves enemies from spawn to goal in a straight line for Phase 1.

- [ ] 5.1 Calculate normalized direction vector from spawn to goal position in Enemy.new()
- [ ] 5.2 Implement frame-based movement using direction × speed × deltaTime formula
- [ ] 5.3 Add boundary checking to prevent enemies from overshooting the goal
- [ ] 5.4 Implement smooth movement updates synchronized with RunService.Heartbeat
- [ ] 5.5 Add movement state transitions (SPAWNING → MOVING → REACHED_TARGET)
- [ ] 5.6 Test linear movement accuracy using MapConstants spawn/goal positions
- [ ] 5.7 Verify movement speed is consistent and visually smooth in Studio
- [ ] 5.8 Confirm enemies properly detect arrival at goal position

### 6. Logging and Debug Integration

**Objective**: Integrate enemy system with existing LogService to provide educational debugging output and system monitoring.

- [ ] 6.1 Add enemy spawn logging with position and timing information to LogService
- [ ] 6.2 Implement movement milestone logging (started moving, halfway point, near goal)
- [ ] 6.3 Log enemy state changes (SPAWNING, MOVING, REACHED_TARGET, DESTROYED)
- [ ] 6.4 Add enemy removal logging with completion reason (reached goal vs destroyed)
- [ ] 6.5 Include enemy count and performance metrics in periodic service logs  
- [ ] 6.6 Create debug information display for enemy positions and states
- [ ] 6.7 Test log output in Studio console and verify educational value
- [ ] 6.8 Confirm logging integrates properly with existing LogService HTTP functionality

### 7. Game Integration and Lifecycle

**Objective**: Integrate the enemy system with existing game services and establish proper initialization and cleanup procedures.

- [ ] 7.1 Update `src/server/init.server.luau` to initialize EnemyService on game start
- [ ] 7.2 Create integration points for future TowerService targeting system
- [ ] 7.3 Implement proper service shutdown and cleanup procedures
- [ ] 7.4 Add enemy system integration with existing MapService if needed
- [ ] 7.5 Create event connections for game state changes and enemy lifecycle
- [ ] 7.6 Establish enemy spawning triggers (manual for testing, automatic for waves)
- [ ] 7.7 Test complete game startup with enemy system initialization in Studio
- [ ] 7.8 Verify enemy system properly integrates with existing logging and map systems

### 8. Manual Testing and Verification

**Objective**: Conduct comprehensive manual testing in Roblox Studio to verify all enemy system functionality works correctly for Phase 1 requirements.

- [ ] 8.1 Test enemy spawning at correct MapConstants.SPAWN_POSITION location
- [ ] 8.2 Verify enemies move in straight line toward MapConstants.GOAL_POSITION
- [ ] 8.3 Confirm movement speed matches EnemyConstants configuration values
- [ ] 8.4 Test enemy goal detection and proper removal upon reaching target
- [ ] 8.5 Verify enemy health system and damage response functionality
- [ ] 8.6 Test multiple concurrent enemies (5-10) with proper performance
- [ ] 8.7 Confirm LogService integration provides useful debugging information
- [ ] 8.8 Complete end-to-end testing: spawn → movement → goal arrival → cleanup works as expected