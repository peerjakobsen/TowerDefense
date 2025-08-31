# Spec Requirements Document

> Spec: Linear Enemy Movement System
> Created: 2025-08-31
> Status: Planning

## Overview

Implement a foundational enemy movement system for the Tower Defense Learning Game that demonstrates core movement concepts. For Phase 1, enemies spawn at the map's spawn point and move in a straight line toward the goal using simple interpolation (no PathfindingService). This prioritizes educational clarity and alignment with the Rectangular Map Phase 1, while setting up a clean structure to introduce PathfindingService in Phase 2.

The system enables basic gameplay where enemies move predictably along a straight path from spawn to goal while towers can target and engage them.

## User Stories

**As a player**, I want to see enemies spawn and move toward my base so that I understand the core tower defense challenge.

**As a student learning AI programming**, I want to examine clear, well-documented enemy movement code that demonstrates pathfinding concepts in a practical context.

**As a developer**, I want a modular enemy system that can be extended with different enemy types, behaviors, and movement patterns in future phases.

## Spec Scope

### Core Features
- **Enemy Spawning System**: Enemies spawn at designated spawn points with configurable timing
- **Linear Movement (Phase 1)**: Straight-line interpolation from spawn to goal (no PathfindingService)
- **Optional Debug Output**: Log movement state changes to the shared LogService
- **Health Management**: Basic enemy health system for tower interaction
- **Cleanup System**: Proper enemy removal when reaching target or being destroyed

### Educational Components
- **Clear Code Documentation**: Comments explaining linear interpolation and update loops
- **Modular Architecture**: Enemy behavior separated into reusable modules
- **State Tracking**: Basic enemy states (spawning, moving, reached_target, destroyed)

## Out of Scope

- PathfindingService and obstacle avoidance (deferred to Phase 2)
- Multiple enemy types with different characteristics
- Dynamic path recalculation based on environmental changes
- Enemy formations or group behaviors
- Advanced visual effects or animations
- Performance optimization for large numbers of enemies

## Expected Deliverable

A complete Phase 1 enemy movement system consisting of:

1. **EnemyService (ServerScriptService, .luau)**: Core service managing enemy lifecycle and spawning
2. **Enemy ModuleScript (.luau)**: Individual enemy behavior and linear movement logic
3. **Constants (.luau)**: Enemy speed/health and map positions via shared constants
4. **Integration Points**: Clean interfaces for tower targeting and damage systems
5. **Test Environment**: Rectangular Map Phase 1 with spawn/goal and clear corridor
6. **Documentation**: Code comments and usage examples for educational purposes

The system should demonstrate enemies successfully moving from spawn to goal along the straight path, providing a solid foundation for tower targeting. PathfindingService and obstacle navigation will be introduced in Phase 2.

## Spec Documentation

- Tasks: @.agent-os/specs/2025-08-31-linear-enemy-movement/tasks.md
- Technical Specification: @.agent-os/specs/2025-08-31-linear-enemy-movement/sub-specs/technical-spec.md
- API Specification: @.agent-os/specs/2025-08-31-linear-enemy-movement/sub-specs/api-spec.md
