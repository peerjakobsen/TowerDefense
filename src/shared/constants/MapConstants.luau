--!strict

-- MapConstants.luau
-- Core constants for the rectangular game map layout and configuration

local MapConstants = {}

-- Map dimensions (studs)
MapConstants.MAP_WIDTH = 100
MapConstants.MAP_HEIGHT = 100
MapConstants.BASE_THICKNESS = 1

-- Key positions on the map
MapConstants.SPAWN_POSITION = Vector3.new(-45, 1, 0)
MapConstants.GOAL_POSITION = Vector3.new(45, 1, 0)

-- Tower placement exclusion zone around the straight path
MapConstants.PATH_HALF_WIDTH = 2

-- Visual constants for map elements
MapConstants.SPAWN_COLOR = Color3.new(0, 1, 0)  -- Bright green
MapConstants.GOAL_COLOR = Color3.new(1, 0, 0)   -- Bright red
MapConstants.BASE_COLOR = Color3.new(0.5, 0.5, 0.5)  -- Gray

MapConstants.MARKER_SIZE = Vector3.new(2, 2, 2)
MapConstants.MARKER_ELEVATION = 0.5  -- Height above base platform

return MapConstants