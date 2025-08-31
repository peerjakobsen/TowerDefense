# Product Roadmap

## Phase 1: Foundation
**Goal:** Establish basic game loop and core mechanics
**Success Criteria:** Player can place one tower that successfully shoots at and destroys moving enemies

### Features
- [ ] Create rectangular map with spawn/goal points - Basic map layout with clearly defined start and end positions `S`
- [ ] Implement linear enemy movement - Enemy moves in straight line from spawn to goal `S`
- [ ] Build single tower type - Tower detects enemies in range and shoots projectiles `M`
- [ ] Basic health/score UI - Simple interface showing player health and score `S`
- [ ] Enemy destruction system - Enemies take damage and are removed when health reaches zero `S`

### Dependencies
- Roblox Studio setup and basic Lua knowledge

## Phase 2: Pathfinding & Core Systems
**Goal:** Implement proper AI movement and expand enemy variety
**Success Criteria:** Multiple enemy types successfully pathfind along complex routes while taking damage from towers

### Features
- [ ] Integrate PathfindingService - Replace linear movement with Roblox's native pathfinding `M`
- [ ] Create winding path with obstacles - Design map with obstacles that require navigation `S`
- [ ] Add multiple enemy types - 2-3 enemy variants with different speeds, health, and rewards `M`
- [ ] Implement damage/health system - Proper damage calculation with visual feedback `S`
- [ ] Add particle effects - Visual effects for shots and enemy destruction `S`
- [ ] Enemy spawn management - Basic spawning system for different enemy types `S`

### Dependencies
- Phase 1 completion
- Understanding of PathfindingService API

## Phase 3: AI Decision Making
**Goal:** Build sophisticated AI systems for both towers and enemies  
**Success Criteria:** Towers intelligently select targets based on configurable strategies, enemies make pathfinding decisions

### Features
- [ ] Tower targeting decision trees - Multiple targeting strategies (closest, strongest, weakest) `L`
- [ ] Enemy path choice AI - Enemies select between multiple route options `M`
- [ ] Wave spawning system - Automatic wave management with increasing difficulty `M`
- [ ] Enemy state machines - Implement idle, moving, attacking, dying states `L`
- [ ] Tower range visualization - Visual indicators for tower range and targeting `S`
- [ ] AI behavior configuration - Settings to adjust AI decision parameters `M`

### Dependencies
- Phase 2 completion
- Understanding of state machine patterns and decision trees

## Phase 4: Strategic Depth
**Goal:** Add strategic gameplay elements and advanced AI
**Success Criteria:** Complete tower defense experience with strategic depth and adaptive AI opponents

### Features
- [ ] Multiple tower types - 3-4 distinct tower types with unique behaviors `L`
- [ ] Tower upgrade system - Branching upgrade paths for each tower type `L`
- [ ] Resource economy - Money system for earning from kills and spending on towers `M`
- [ ] Adaptive enemy AI - Enemies respond intelligently to player tower placement `XL`
- [ ] Boss enemy system - Special enemies with unique behaviors and challenges `L`
- [ ] Wave progression - Comprehensive wave management with scaling difficulty `M`
- [ ] Game balance tuning - Adjust costs, damage, and timing for optimal gameplay `M`

### Dependencies
- Phase 3 completion
- Advanced AI programming concepts
- Game balance testing and iteration