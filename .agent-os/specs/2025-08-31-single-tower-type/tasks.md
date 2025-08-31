# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-08-31-single-tower-type/spec.md

> Created: 2025-08-31
> Status: Ready for Implementation

## Tasks

### Task 1: TowerService Foundation
Create the core singleton service that manages all tower operations and coordinates with other game systems.

- [x] 1.1 Create TowerService ModuleScript in `src/server/services/`
- [x] 1.2 Implement singleton pattern with proper initialization
- [x] 1.3 Add tower storage and management data structures
- [x] 1.4 Create tower placement validation methods
- [x] 1.5 Implement tower creation and destruction lifecycle
- [x] 1.6 Add BindableEvent connections for inter-service communication
- [x] 1.7 Create manual test scenarios for service initialization and basic operations
- [x] 1.8 Integrate TowerService with existing GameManager system

### Task 2: Tower Entity Implementation
Develop the individual tower behavior system including targeting, firing, and state management.

- [x] 2.1 Create Tower ModuleScript in `src/server/entities/`
- [x] 2.2 Implement tower state management (idle, targeting, firing)
- [x] 2.3 Add enemy detection system using magnitude-based range checking
- [x] 2.4 Implement closest-enemy targeting algorithm
- [x] 2.5 Create firing rate management with cooldown tracking
- [x] 2.6 Add RunService.Heartbeat connection for tower updates (0.1s intervals)
- [x] 2.7 Create manual test scenarios for tower detection and targeting
- [x] 2.8 Integrate with existing EnemyService for enemy position data

### Task 3: Projectile System
Build the projectile creation, movement, and impact system for tower combat.

- [ ] 3.1 Create Projectile ModuleScript in `src/server/entities/`
- [ ] 3.2 Implement projectile creation with visual part instantiation
- [ ] 3.3 Add TweenService-based projectile movement system
- [ ] 3.4 Create distance-based hit detection for target impact
- [ ] 3.5 Implement damage application to enemy targets
- [ ] 3.6 Add projectile cleanup system (timeout and impact cleanup)
- [ ] 3.7 Create manual test scenarios for projectile travel and damage
- [ ] 3.8 Optimize projectile performance with proper cleanup timing

### Task 4: Tower Placement System
Develop the player interaction system for tower placement with validation and feedback.

- [ ] 4.1 Create placement validation logic (boundaries, collisions, path blocking)
- [ ] 4.2 Implement client-server communication for placement requests
- [ ] 4.3 Add UserInputService integration for click-to-place interaction
- [ ] 4.4 Create placement preview system with visual feedback
- [ ] 4.5 Implement valid/invalid placement area visualization
- [ ] 4.6 Add tower model instantiation and positioning
- [ ] 4.7 Create manual test scenarios for placement validation edge cases
- [ ] 4.8 Integrate placement system with existing UI systems

### Task 5: Visual Systems and Polish
Implement visual components and effects that enhance the tower defense experience.

- [ ] 5.1 Create basic tower 3D model using simple geometric parts
- [ ] 5.2 Design projectile visual (sphere or cylinder part)
- [ ] 5.3 Implement range visualization system (translucent sphere indicator)
- [ ] 5.4 Add tower rotation to face current target
- [ ] 5.5 Create placement preview materials and transparency effects
- [ ] 5.6 Implement visual feedback for tower firing (muzzle flash, etc.)
- [ ] 5.7 Create manual test scenarios for visual system integration
- [ ] 5.8 Optimize visual performance and ensure smooth animations

## Implementation Notes

### Testing Approach
Since this is a Roblox project with manual testing only:
- Each task includes "Create manual test scenarios" subtasks
- Test scenarios should cover normal operation, edge cases, and integration points
- Use Roblox Studio's test environment with `rojo serve` for live development
- Focus on visual verification and gameplay functionality testing

### Technical Dependencies
- Task 1 must be completed before Task 2 (TowerService needed for Tower entities)
- Task 2 must be completed before Task 3 (Tower needed to create projectiles)
- Task 4 can be developed in parallel with Tasks 2-3
- Task 5 can be implemented throughout other tasks for incremental visual improvements

### Integration Requirements
- All tasks must integrate with existing EnemyService and WaveService
- Event-driven communication should be used between all systems
- Configuration values should be centralized for easy tuning
- Code should follow the established ModuleScript architecture pattern

### Performance Targets
- Tower targeting updates: 10 FPS (every 0.1 seconds)
- Projectile animations: 30 FPS via TweenService
- Memory management: Proper cleanup of all created instances
- Event connections: Clean disconnection on tower destruction