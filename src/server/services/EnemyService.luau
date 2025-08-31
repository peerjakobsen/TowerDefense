--!strict

-- EnemyService.luau
-- Singleton service that manages the enemy lifecycle, spawning, updates, and integration with the game loop.
-- Handles enemy tracking, removal, and provides public API for the enemy system.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enemy = require(ReplicatedStorage.Shared.enemies.Enemy)
local EnemyConstants = require(ReplicatedStorage.Shared.constants.EnemyConstants)
local MapConstants = require(ReplicatedStorage.Shared.constants.MapConstants)
local LogService = require(ReplicatedStorage.Shared.LogService)

local EnemyService = {}

-- Private state
local serviceInitialized = false
local activeEnemies: {[string]: Enemy.Enemy} = {}
local heartbeatConnection: RBXScriptConnection?
local lastSpawnTime = 0
local totalEnemiesSpawned = 0

-- Private helper to get current count of active enemies
local function getActiveEnemyCount(): number
	local count = 0
	for _ in pairs(activeEnemies) do
		count += 1
	end
	return count
end

-- Private helper to remove enemy from tracking and cleanup
local function removeEnemyFromTracking(enemyId: string)
	local enemy = activeEnemies[enemyId]
	if enemy then
		-- Clean up the enemy instance
		enemy:Destroy()
		-- Remove from tracking table
		activeEnemies[enemyId] = nil
		
		LogService.info("EnemyService: Removed enemy from tracking", {
			enemyId = enemyId,
			activeCount = getActiveEnemyCount(),
		})
	end
end

-- Update loop function called by RunService.Heartbeat
local function updateEnemies(deltaTime: number)
	local enemiesToRemove: {string} = {}
	
	-- Update all active enemies
	for enemyId, enemy in pairs(activeEnemies) do
		local stillActive = enemy:Update(deltaTime)
		
		-- Check if enemy should be removed (reached target or destroyed)
		if not stillActive or 
		   enemy:GetState() == EnemyConstants.STATES.REACHED_TARGET or
		   enemy:GetState() == EnemyConstants.STATES.DESTROYED or
		   not enemy:IsAlive() then
			table.insert(enemiesToRemove, enemyId)
		end
	end
	
	-- Remove completed/destroyed enemies
	for _, enemyId in ipairs(enemiesToRemove) do
		removeEnemyFromTracking(enemyId)
	end
end

-- Initialize the enemy service and start the update loop
function EnemyService.Initialize()
	if serviceInitialized then
		LogService.warn("EnemyService.Initialize() called but service already initialized")
		return
	end

	LogService.info("EnemyService: Beginning service initialization")
	
	-- Reset state
	activeEnemies = {}
	lastSpawnTime = 0
	totalEnemiesSpawned = 0
	
	-- Connect to RunService.Heartbeat for 60 FPS enemy updates
	heartbeatConnection = RunService.Heartbeat:Connect(updateEnemies)
	
	serviceInitialized = true
	LogService.info("EnemyService: Service initialization completed successfully", {
		updateRate = "60 FPS via RunService.Heartbeat",
		maxConcurrentEnemies = EnemyConstants.MAX_CONCURRENT_ENEMIES,
		spawnInterval = EnemyConstants.SPAWN_INTERVAL,
	})
end

-- Spawn a new enemy if limits allow
function EnemyService.SpawnEnemy(): boolean
	if not serviceInitialized then
		LogService.error("EnemyService.SpawnEnemy() called before initialization")
		return false
	end
	
	-- Check concurrent enemy limit
	local currentCount = getActiveEnemyCount()
	if currentCount >= EnemyConstants.MAX_CONCURRENT_ENEMIES then
		LogService.debug("EnemyService: Cannot spawn enemy - at concurrent limit", {
			currentCount = currentCount,
			limit = EnemyConstants.MAX_CONCURRENT_ENEMIES,
		})
		return false
	end
	
	-- Check spawn timing (prevent spam spawning)
	local currentTime = tick()
	if currentTime - lastSpawnTime < EnemyConstants.SPAWN_INTERVAL then
		LogService.debug("EnemyService: Cannot spawn enemy - too soon since last spawn", {
			timeSinceLastSpawn = currentTime - lastSpawnTime,
			requiredInterval = EnemyConstants.SPAWN_INTERVAL,
		})
		return false
	end
	
	-- Create new enemy instance
	local spawnPosition = MapConstants.SPAWN_POSITION
	local goalPosition = MapConstants.GOAL_POSITION
	local enemy = Enemy.new(spawnPosition, goalPosition)
	
	-- Add to tracking
	activeEnemies[enemy:GetId()] = enemy
	lastSpawnTime = currentTime
	totalEnemiesSpawned += 1
	
	LogService.info("EnemyService: Enemy spawned successfully", {
		enemyId = enemy:GetId(),
		spawnPosition = spawnPosition,
		goalPosition = goalPosition,
		activeCount = getActiveEnemyCount(),
		totalSpawned = totalEnemiesSpawned,
	})
	
	return true
end

-- Get all currently active enemies
function EnemyService.GetActiveEnemies(): {Enemy.Enemy}
	if not serviceInitialized then
		LogService.error("EnemyService.GetActiveEnemies() called before initialization")
		return {}
	end
	
	local enemies = {}
	for _, enemy in pairs(activeEnemies) do
		table.insert(enemies, enemy)
	end
	
	return enemies
end

-- Get count of active enemies
function EnemyService.GetActiveEnemyCount(): number
	if not serviceInitialized then
		LogService.error("EnemyService.GetActiveEnemyCount() called before initialization")
		return 0
	end
	
	return getActiveEnemyCount()
end

-- Remove a specific enemy by ID
function EnemyService.RemoveEnemy(enemyId: string): boolean
	if not serviceInitialized then
		LogService.error("EnemyService.RemoveEnemy() called before initialization")
		return false
	end
	
	if activeEnemies[enemyId] then
		removeEnemyFromTracking(enemyId)
		LogService.info("EnemyService: Enemy removed manually", {
			enemyId = enemyId,
			activeCount = getActiveEnemyCount(),
		})
		return true
	else
		LogService.warn("EnemyService: Attempted to remove non-existent enemy", {
			enemyId = enemyId,
		})
		return false
	end
end

-- Check if the service has been initialized
function EnemyService.IsInitialized(): boolean
	return serviceInitialized
end

-- Get service statistics (for debugging/monitoring)
function EnemyService.GetStatistics()
	if not serviceInitialized then
		LogService.error("EnemyService.GetStatistics() called before initialization")
		return nil
	end
	
	return {
		activeEnemyCount = getActiveEnemyCount(),
		totalEnemiesSpawned = totalEnemiesSpawned,
		lastSpawnTime = lastSpawnTime,
		timeSinceLastSpawn = tick() - lastSpawnTime,
		maxConcurrentEnemies = EnemyConstants.MAX_CONCURRENT_ENEMIES,
		spawnInterval = EnemyConstants.SPAWN_INTERVAL,
		isRunning = heartbeatConnection ~= nil,
	}
end

-- Shutdown the service and cleanup (for testing/debugging)
function EnemyService.Shutdown()
	if not serviceInitialized then
		LogService.warn("EnemyService.Shutdown() called but service not initialized")
		return
	end
	
	LogService.info("EnemyService: Beginning service shutdown")
	
	-- Disconnect update loop
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
	
	-- Clean up all active enemies
	local enemyCount = getActiveEnemyCount()
	for enemyId in pairs(activeEnemies) do
		removeEnemyFromTracking(enemyId)
	end
	
	-- Reset state
	serviceInitialized = false
	lastSpawnTime = 0
	totalEnemiesSpawned = 0
	
	LogService.info("EnemyService: Service shutdown completed", {
		enemiesRemoved = enemyCount,
	})
end

return EnemyService