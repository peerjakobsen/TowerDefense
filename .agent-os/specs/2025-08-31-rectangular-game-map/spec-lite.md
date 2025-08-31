# Rectangular Game Map - Lite Summary

Create a rectangular game map with spawn point (S) and goal point (G) that establishes the foundation for simple straight-line movement and tower placement in our educational Tower Defense game.

## Key Points
- Rectangular play area with clear visual boundaries using Roblox Parts
- Single spawn point where enemies enter and goal point where they exit
- Basic tower placement validation with a path corridor exclusion (±2 studs)
- Phase 1: straight-line movement (no PathfindingService yet)
- MapService implemented in ServerScriptService (`.luau`) with shared constants in `src/shared/constants`
