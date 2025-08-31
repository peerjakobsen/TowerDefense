--!strict

-- TowerService.luau
-- Singleton service that manages all tower operations and coordinates with other game systems.
-- Handles tower placement, lifecycle management, and inter-service communication.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LogService = require(ReplicatedStorage.Shared.LogService)
local MapConstants = require(ReplicatedStorage.Shared.constants.MapConstants)

local TowerService = {}

-- Private state
local serviceInitialized = false
local activeTowers: {[string]: any} = {} -- Will be typed properly when Tower module is created
local towerIdCounter = 0
local lastUpdateTime = 0
local updateInterval = 0.1 -- Update towers every 0.1 seconds (10 FPS)

-- Events for game state changes and tower lifecycle
local towerPlacedEvent: BindableEvent?
local towerDestroyedEvent: BindableEvent?
local towerTargetChangedEvent: BindableEvent?

-- Tower configuration constants
local TOWER_DAMAGE = 25
local TOWER_RANGE = 20 -- studs
local TOWER_FIRE_RATE = 1.0 -- attacks per second
local TOWER_SIZE = Vector3.new(2, 4, 2) -- Width, Height, Depth

-- Private helper to generate unique tower ID
local function generateTowerId(): string
	towerIdCounter += 1
	return "tower_" .. tostring(towerIdCounter)
end

-- Private helper to get active tower count
local function getActiveTowerCount(): number
	local count = 0
	for _ in pairs(activeTowers) do
		count += 1
	end
	return count
end

-- Initialize the tower service
function TowerService.Initialize()
	if serviceInitialized then
		LogService.warn("TowerService.Initialize() called but service already initialized")
		return
	end

	LogService.info("TowerService: Beginning service initialization")
	
	-- Initialize events
	towerPlacedEvent = Instance.new("BindableEvent")
	towerPlacedEvent.Name = "TowerPlaced"
	
	towerDestroyedEvent = Instance.new("BindableEvent")
	towerDestroyedEvent.Name = "TowerDestroyed"
	
	towerTargetChangedEvent = Instance.new("BindableEvent")
	towerTargetChangedEvent.Name = "TowerTargetChanged"
	
	-- Set up tower update loop using RunService
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local currentTime = tick()
		if currentTime - lastUpdateTime >= updateInterval then
			updateAllTowers()
			lastUpdateTime = currentTime
		end
	end)
	
	serviceInitialized = true
	LogService.info("TowerService: Service initialization completed", {
		updateInterval = updateInterval,
		towerDamage = TOWER_DAMAGE,
		towerRange = TOWER_RANGE,
		fireRate = TOWER_FIRE_RATE
	})
end

-- Private function to update all active towers
local function updateAllTowers()
	for towerId, tower in pairs(activeTowers) do
		-- Tower update logic will be implemented when Tower module is created
		-- This will handle enemy detection, targeting, and firing
	end
end

-- Tower placement validation methods
function TowerService.IsValidPlacement(position: Vector3): boolean
	-- Check if position is within map boundaries
	local halfMapWidth = MapConstants.MAP_WIDTH / 2
	local halfMapHeight = MapConstants.MAP_HEIGHT / 2
	
	if position.X < -halfMapWidth or position.X > halfMapWidth then
		return false
	end
	
	if position.Z < -halfMapHeight or position.Z > halfMapHeight then
		return false
	end
	
	-- Check if position is above the map surface
	if position.Y < MapConstants.BASE_THICKNESS then
		return false
	end
	
	-- Check for collisions with existing towers
	for _, tower in pairs(activeTowers) do
		-- Will implement collision checking when Tower module is created
		-- For now, assume no collision if tower tracking is empty
	end
	
	-- TODO: Add path blocking validation when pathfinding is integrated
	-- TODO: Add collision detection with existing towers
	
	return true
end

function TowerService.GetPlacementPreview(position: Vector3): {isValid: boolean, adjustedPosition: Vector3}
	local adjustedPosition = Vector3.new(
		position.X,
		MapConstants.BASE_THICKNESS + (TOWER_SIZE.Y / 2), -- Place tower on map surface
		position.Z
	)
	
	local isValid = TowerService.IsValidPlacement(adjustedPosition)
	
	return {
		isValid = isValid,
		adjustedPosition = adjustedPosition
	}
end

-- Tower creation and destruction lifecycle methods
function TowerService.CreateTower(position: Vector3): string?
	if not serviceInitialized then
		LogService.warn("TowerService.CreateTower() called but service not initialized")
		return nil
	end
	
	-- Validate placement
	local placementInfo = TowerService.GetPlacementPreview(position)
	if not placementInfo.isValid then
		LogService.debug("TowerService: Tower placement invalid", {
			requestedPosition = position,
			adjustedPosition = placementInfo.adjustedPosition
		})
		return nil
	end
	
	-- Generate unique tower ID
	local towerId = generateTowerId()
	
	-- Create tower visual representation (basic model)
	local towerFolder = workspace:FindFirstChild("Towers")
	if not towerFolder then
		towerFolder = Instance.new("Folder")
		towerFolder.Name = "Towers"
		towerFolder.Parent = workspace
	end
	
	local towerPart = Instance.new("Part")
	towerPart.Name = "Tower_" .. towerId
	towerPart.Size = TOWER_SIZE
	towerPart.Position = placementInfo.adjustedPosition
	towerPart.Color = Color3.fromRGB(100, 100, 100) -- Gray tower
	towerPart.Material = Enum.Material.Metal
	towerPart.Anchored = true
	towerPart.CanCollide = true
	towerPart.Parent = towerFolder
	
	-- Create tower data structure (placeholder for now)
	local towerData = {
		id = towerId,
		position = placementInfo.adjustedPosition,
		part = towerPart,
		damage = TOWER_DAMAGE,
		range = TOWER_RANGE,
		fireRate = TOWER_FIRE_RATE,
		lastFireTime = 0,
		currentTarget = nil,
		createdTime = tick()
	}
	
	-- Store in active towers
	activeTowers[towerId] = towerData
	
	-- Fire placement event
	if towerPlacedEvent then
		towerPlacedEvent:Fire(towerId, towerData)
	end
	
	LogService.info("TowerService: Tower created successfully", {
		towerId = towerId,
		position = placementInfo.adjustedPosition,
		activeTowerCount = getActiveTowerCount()
	})
	
	return towerId
end

function TowerService.DestroyTower(towerId: string): boolean
	if not serviceInitialized then
		LogService.warn("TowerService.DestroyTower() called but service not initialized")
		return false
	end
	
	local tower = activeTowers[towerId]
	if not tower then
		LogService.debug("TowerService: Attempted to destroy non-existent tower", {
			towerId = towerId
		})
		return false
	end
	
	-- Clean up tower visual
	if tower.part then
		tower.part:Destroy()
	end
	
	-- Remove from active towers
	activeTowers[towerId] = nil
	
	-- Fire destruction event
	if towerDestroyedEvent then
		towerDestroyedEvent:Fire(towerId, tower)
	end
	
	LogService.info("TowerService: Tower destroyed successfully", {
		towerId = towerId,
		activeTowerCount = getActiveTowerCount()
	})
	
	return true
end

function TowerService.GetTower(towerId: string)
	return activeTowers[towerId]
end

function TowerService.GetAllTowers()
	return activeTowers
end

-- Public API methods
function TowerService.GetStatistics()
	return {
		activeTowerCount = getActiveTowerCount(),
		totalTowersSpawned = towerIdCounter,
		serviceInitialized = serviceInitialized
	}
end

function TowerService.Shutdown()
	if not serviceInitialized then
		return
	end
	
	LogService.info("TowerService: Beginning service shutdown")
	
	-- Disconnect RunService connection
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
	
	-- Clean up all active towers
	for towerId, tower in pairs(activeTowers) do
		-- Tower cleanup will be implemented when Tower module is created
	end
	activeTowers = {}
	
	-- Clean up events
	if towerPlacedEvent then
		towerPlacedEvent:Destroy()
		towerPlacedEvent = nil
	end
	
	if towerDestroyedEvent then
		towerDestroyedEvent:Destroy()
		towerDestroyedEvent = nil
	end
	
	if towerTargetChangedEvent then
		towerTargetChangedEvent:Destroy()
		towerTargetChangedEvent = nil
	end
	
	serviceInitialized = false
	LogService.info("TowerService: Service shutdown completed")
end

-- Manual Test Scenarios for Development and Validation
-- These functions can be called from the Roblox Studio Command Bar for testing

function TowerService.RunManualTests()
	LogService.info("TowerService: Starting manual test scenarios")
	
	-- Test 1: Service initialization
	TowerService.TestServiceInitialization()
	
	-- Test 2: Tower placement validation
	TowerService.TestPlacementValidation()
	
	-- Test 3: Tower creation and destruction
	TowerService.TestTowerLifecycle()
	
	-- Test 4: Statistics and data integrity
	TowerService.TestStatistics()
	
	LogService.info("TowerService: Manual test scenarios completed")
end

function TowerService.TestServiceInitialization()
	LogService.info("=== Test 1: Service Initialization ===")
	
	-- Test initialization state
	local initialStats = TowerService.GetStatistics()
	LogService.info("Initial state", initialStats)
	
	-- Test double initialization (should warn)
	TowerService.Initialize()
	
	-- Test post-initialization state
	local postInitStats = TowerService.GetStatistics()
	LogService.info("Post-init state", postInitStats)
	
	LogService.info("✓ Service initialization test completed")
end

function TowerService.TestPlacementValidation()
	LogService.info("=== Test 2: Placement Validation ===")
	
	-- Test valid positions
	local validPositions = {
		Vector3.new(0, 5, 0), -- Center of map
		Vector3.new(10, 5, 10), -- Corner within bounds
		Vector3.new(-5, 5, -5) -- Negative coordinates within bounds
	}
	
	for i, pos in ipairs(validPositions) do
		local preview = TowerService.GetPlacementPreview(pos)
		LogService.info("Valid position test " .. i, {
			original = pos,
			adjusted = preview.adjustedPosition,
			isValid = preview.isValid
		})
	end
	
	-- Test invalid positions (outside map)
	local invalidPositions = {
		Vector3.new(100, 5, 0), -- Too far X
		Vector3.new(0, 5, 100), -- Too far Z
		Vector3.new(0, -5, 0) -- Below map surface
	}
	
	for i, pos in ipairs(invalidPositions) do
		local isValid = TowerService.IsValidPlacement(pos)
		LogService.info("Invalid position test " .. i, {
			position = pos,
			shouldBeValid = false,
			actualResult = isValid
		})
	end
	
	LogService.info("✓ Placement validation test completed")
end

function TowerService.TestTowerLifecycle()
	LogService.info("=== Test 3: Tower Lifecycle ===")
	
	-- Test tower creation
	local testPosition = Vector3.new(5, 5, 5)
	local towerId = TowerService.CreateTower(testPosition)
	
	if towerId then
		LogService.info("Tower created successfully", {
			towerId = towerId,
			position = testPosition
		})
		
		-- Test tower retrieval
		local towerData = TowerService.GetTower(towerId)
		LogService.info("Tower data retrieved", towerData)
		
		-- Test tower destruction
		local destroySuccess = TowerService.DestroyTower(towerId)
		LogService.info("Tower destruction", {
			towerId = towerId,
			success = destroySuccess
		})
		
		-- Test accessing destroyed tower
		local destroyedTowerData = TowerService.GetTower(towerId)
		LogService.info("Destroyed tower data", {
			shouldBeNil = true,
			actualResult = destroyedTowerData
		})
	else
		LogService.warn("Tower creation failed during test")
	end
	
	LogService.info("✓ Tower lifecycle test completed")
end

function TowerService.TestStatistics()
	LogService.info("=== Test 4: Statistics ===")
	
	-- Create multiple towers for stats testing
	local testTowers = {}
	for i = 1, 3 do
		local pos = Vector3.new(i * 3, 5, i * 3)
		local towerId = TowerService.CreateTower(pos)
		if towerId then
			table.insert(testTowers, towerId)
		end
	end
	
	-- Check statistics
	local stats = TowerService.GetStatistics()
	LogService.info("Statistics with active towers", stats)
	
	-- Test GetAllTowers
	local allTowers = TowerService.GetAllTowers()
	LogService.info("All towers count", {
		expected = #testTowers,
		actual = getActiveTowerCount()
	})
	
	-- Clean up test towers
	for _, towerId in ipairs(testTowers) do
		TowerService.DestroyTower(towerId)
	end
	
	-- Final statistics check
	local finalStats = TowerService.GetStatistics()
	LogService.info("Final statistics", finalStats)
	
	LogService.info("✓ Statistics test completed")
end

return TowerService