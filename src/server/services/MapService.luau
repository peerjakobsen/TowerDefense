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