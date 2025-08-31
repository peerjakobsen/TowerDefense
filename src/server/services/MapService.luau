--!strict

-- MapService.luau
-- Core service for managing the rectangular game map, including platform creation,
-- spawn/goal markers, and providing position accessor methods

local MapConstants = require(game.ReplicatedStorage.Shared.constants.MapConstants)
local LogService = require(game.ReplicatedStorage.Shared.LogService)

local MapService = {}

-- Private state
local mapInitialized = false
local mapFolder: Folder?
local basePlatform: Part?
local spawnMarker: Part?
local goalMarker: Part?

-- Initialize the map by creating the base platform and markers
function MapService.Initialize()
	if mapInitialized then
		LogService.warn("MapService.Initialize() called but map already initialized")
		return
	end

	LogService.info("MapService: Beginning map initialization")
	
	-- Create or get the Map folder in Workspace
	mapFolder = workspace:FindFirstChild("Map") :: Folder?
	if not mapFolder then
		mapFolder = Instance.new("Folder")
		mapFolder.Name = "Map"
		mapFolder.Parent = workspace
		LogService.info("MapService: Created Workspace.Map folder")
	end

	-- Create base platform
	basePlatform = Instance.new("Part")
	basePlatform.Name = "BasePlatform"
	basePlatform.Size = Vector3.new(MapConstants.MAP_WIDTH, MapConstants.BASE_THICKNESS, MapConstants.MAP_HEIGHT)
	basePlatform.Position = Vector3.new(0, 0, 0)
	basePlatform.Color = MapConstants.BASE_COLOR
	basePlatform.Material = Enum.Material.Plastic
	basePlatform.Anchored = true
	basePlatform.CanCollide = true
	basePlatform.Parent = mapFolder
	LogService.info("MapService: Created base platform", {
		size = basePlatform.Size,
		position = basePlatform.Position,
		color = basePlatform.Color
	})

	-- Create spawn marker (green, slightly elevated)
	spawnMarker = Instance.new("Part")
	spawnMarker.Name = "SpawnMarker"
	spawnMarker.Size = MapConstants.MARKER_SIZE
	spawnMarker.Position = MapConstants.SPAWN_POSITION + Vector3.new(0, MapConstants.MARKER_ELEVATION, 0)
	spawnMarker.Color = MapConstants.SPAWN_COLOR
	spawnMarker.Material = Enum.Material.Neon
	spawnMarker.Anchored = true
	spawnMarker.CanCollide = false
	spawnMarker.Parent = mapFolder
	LogService.info("MapService: Created spawn marker", {
		position = spawnMarker.Position,
		color = spawnMarker.Color
	})

	-- Create goal marker (red, slightly elevated)
	goalMarker = Instance.new("Part")
	goalMarker.Name = "GoalMarker"
	goalMarker.Size = MapConstants.MARKER_SIZE
	goalMarker.Position = MapConstants.GOAL_POSITION + Vector3.new(0, MapConstants.MARKER_ELEVATION, 0)
	goalMarker.Color = MapConstants.GOAL_COLOR
	goalMarker.Material = Enum.Material.Neon
	goalMarker.Anchored = true
	goalMarker.CanCollide = false
	goalMarker.Parent = mapFolder
	LogService.info("MapService: Created goal marker", {
		position = goalMarker.Position,
		color = goalMarker.Color
	})

	mapInitialized = true
	LogService.info("MapService: Map initialization completed successfully")
end

-- Get the spawn position for enemies
function MapService.GetSpawnPosition(): Vector3
	if not mapInitialized then
		LogService.error("MapService.GetSpawnPosition() called before initialization")
		error("MapService must be initialized before getting spawn position")
	end
	
	return MapConstants.SPAWN_POSITION
end

-- Get the goal position for enemy pathfinding
function MapService.GetGoalPosition(): Vector3
	if not mapInitialized then
		LogService.error("MapService.GetGoalPosition() called before initialization")
		error("MapService must be initialized before getting goal position")
	end
	
	return MapConstants.GOAL_POSITION
end

-- Check if the map has been initialized
function MapService.IsInitialized(): boolean
	return mapInitialized
end

-- Check if a position is valid for tower placement
-- Position must be within map bounds and outside the path corridor
function MapService.IsValidTowerPosition(position: Vector3): boolean
	if not mapInitialized then
		LogService.error("MapService.IsValidTowerPosition() called before initialization")
		return false
	end
	
	-- Check map boundary (100x100 rectangle bounds)
	local halfWidth = MapConstants.MAP_WIDTH / 2
	local halfHeight = MapConstants.MAP_HEIGHT / 2
	
	if math.abs(position.X) > halfWidth or math.abs(position.Z) > halfHeight then
		LogService.debug("Tower placement rejected: position outside map bounds", {
			position = position,
			bounds = { x = halfWidth, z = halfHeight }
		})
		return false
	end
	
	-- Calculate path corridor exclusion using spawn→goal line and PATH_HALF_WIDTH
	local spawnPos = MapConstants.SPAWN_POSITION
	local goalPos = MapConstants.GOAL_POSITION
	
	-- Calculate perpendicular distance from point to spawn-goal line
	-- Line equation: spawn to goal is along X-axis (Z remains constant at 0)
	-- Since spawn is at (-45, 1, 0) and goal is at (45, 1, 0), the path is a horizontal line at Z=0
	local distanceFromPath = math.abs(position.Z - spawnPos.Z)
	
	if distanceFromPath <= MapConstants.PATH_HALF_WIDTH then
		LogService.debug("Tower placement rejected: position within path corridor", {
			position = position,
			distanceFromPath = distanceFromPath,
			pathHalfWidth = MapConstants.PATH_HALF_WIDTH
		})
		return false
	end
	
	LogService.debug("Tower placement approved", {
		position = position,
		distanceFromPath = distanceFromPath
	})
	return true
end

-- Get references to the created map objects (for testing/debugging)
function MapService.GetMapObjects()
	if not mapInitialized then
		LogService.warn("MapService.GetMapObjects() called before initialization")
		return nil
	end
	
	return {
		mapFolder = mapFolder,
		basePlatform = basePlatform,
		spawnMarker = spawnMarker,
		goalMarker = goalMarker
	}
end

return MapService