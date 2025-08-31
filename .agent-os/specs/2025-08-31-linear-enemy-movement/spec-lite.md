# Linear Enemy Movement System - Lite Summary

Implement foundational enemy AI that spawns enemies and moves them in a straight line from spawn to goal (no PathfindingService in Phase 1), creating the core tower defense challenge while demonstrating basic update loop and interpolation concepts for educational purposes.

## Key Points
- Enemies spawn at designated points and move toward the goal via linear interpolation
- Modular architecture with EnemyService and Enemy modules; reserve PathManager for Phase 2
- Basic health system and cleanup for tower interaction; obstacle navigation deferred to Phase 2
