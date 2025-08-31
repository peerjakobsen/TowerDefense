# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-08-31-rectangular-game-map/spec.md

> Created: 2025-08-31
> Status: Ready for Implementation

## Tasks

### 1. Create Map Constants Module
- [x] 1.1. Create MapConstants.luau in src/shared/constants/ directory
- [x] 1.2. Define MAP_WIDTH (100), MAP_HEIGHT (100), BASE_THICKNESS (1) constants
- [x] 1.3. Define SPAWN_POSITION Vector3.new(-45, 1, 0) and GOAL_POSITION Vector3.new(45, 1, 0)
- [x] 1.4. Define PATH_HALF_WIDTH constant (2 studs) for tower placement exclusion
- [x] 1.5. Define visual constants for colors and marker sizes
- [x] 1.6. Update default.project.json to map src/shared/constants to ReplicatedStorage/Shared/constants
- [x] 1.7. Test constants accessibility from both server and client scripts
- [x] 1.8. Verify all constant values match technical specification requirements

### 2. Implement MapService Core Module
- [x] 2.1. Create MapService.luau in src/server/services/ directory structure
- [x] 2.2. Implement Initialize() method to create base platform Part in Workspace.Map
- [x] 2.3. Set platform properties: Size(100,1,100), Position(0,0,0), Color gray, Material Plastic
- [x] 2.4. Create spawn marker: green Part(2,2,2) at spawn position, slightly elevated
- [x] 2.5. Create goal marker: red Part(2,2,2) at goal position, slightly elevated
- [x] 2.6. Implement GetSpawnPosition() and GetGoalPosition() accessor methods
- [x] 2.7. Add proper error handling and LogService integration for debugging
- [x] 2.8. Test MapService.Initialize() creates all 3 Parts correctly in Workspace

### 3. Implement Tower Placement Validation
- [x] 3.1. Design basic coordinate validation tests for IsValidTowerPosition method
- [x] 3.2. Implement IsValidTowerPosition(position: Vector3) boolean method
- [x] 3.3. Add map boundary checking (within 100x100 rectangle bounds)
- [x] 3.4. Calculate path corridor exclusion using spawn→goal line and PATH_HALF_WIDTH
- [x] 3.5. Implement perpendicular distance calculation from point to spawn-goal line
- [x] 3.6. Add validation to reject positions within ±2 studs of the straight path
- [x] 3.7. Add LogService messages for validation results during testing
- [x] 3.8. Test placement validation with positions inside/outside corridor and map bounds

### 4. Integrate with Existing Project Structure
- [x] 4.1. Test LogService integration from existing src/shared/LogService.luau
- [x] 4.2. Update rojo configuration to include new server services directory
- [x] 4.3. Verify MapConstants accessible from both server and client contexts
- [x] 4.4. Create simple initialization script that calls MapService.Initialize()
- [x] 4.5. Test map creation in Roblox Studio using rojo serve workflow
- [x] 4.6. Verify Workspace.Map folder organization and Part hierarchy
- [x] 4.7. Document API methods for future WaveService and TowerService integration
- [x] 4.8. Confirm rectangular map fully functional with spawn, goal, and placement validation

### 5. Visual Verification and Phase 1 Validation
- [x] 5.1. Create manual test script to validate map dimensions and positioning
- [x] 5.2. Verify spawn point clearly visible as bright green marker on left edge
- [x] 5.3. Verify goal point clearly visible as bright red marker on right edge
- [x] 5.4. Test tower placement validation across multiple map positions
- [x] 5.5. Confirm path corridor protection prevents tower placement near spawn→goal line
- [x] 5.6. Validate map provides foundation for Phase 1 linear enemy movement
- [x] 5.7. Test all MapService public API methods return expected values
- [x] 5.8. Confirm rectangular map ready for integration with enemy movement system