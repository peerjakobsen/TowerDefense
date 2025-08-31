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
local lastStatsLogTime = 0
local statsLogInterval = 10.0 -- Log stats every 10 seconds

-- Events for game state changes and enemy lifecycle
local enemySpawnedEvent: BindableEvent?
local enemyDestroyedEvent: BindableEvent?
local enemyReachedGoalEvent: BindableEvent?
local enemyHealthChangedEvent: BindableEvent?

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
			
			-- Fire appropriate lifecycle event before removal
			if enemy:GetState() == EnemyConstants.STATES.REACHED_TARGET then
				if enemyReachedGoalEvent then
					enemyReachedGoalEvent:Fire(enemy)
				end
			elseif not enemy:IsAlive() or enemy:GetState() == EnemyConstants.STATES.DESTROYED then
				if enemyDestroyedEvent then
					enemyDestroyedEvent:Fire(enemy)
				end
			end
			
			table.insert(enemiesToRemove, enemyId)
		end
	end
	
	-- Remove completed/destroyed enemies
	for _, enemyId in ipairs(enemiesToRemove) do
		removeEnemyFromTracking(enemyId)
	end
	
	-- Log performance metrics periodically for educational monitoring
	local currentTime = tick()
	if currentTime - lastStatsLogTime >= statsLogInterval then
		lastStatsLogTime = currentTime
		
		LogService.info("EnemyService: Performance metrics", {
			activeEnemyCount = getActiveEnemyCount(),
			totalEnemiesSpawned = totalEnemiesSpawned,
			avgUpdateTime = string.format("%.2fms", deltaTime * 1000),
			systemUptime = string.format("%.1fs", currentTime - (lastSpawnTime - totalEnemiesSpawned * EnemyConstants.SPAWN_INTERVAL)),
			spawnRate = string.format("%.1f enemies/min", (totalEnemiesSpawned / math.max(1, (currentTime - (lastSpawnTime - totalEnemiesSpawned * EnemyConstants.SPAWN_INTERVAL)))) * 60),
		})
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
	lastStatsLogTime = 0
	
	-- Create lifecycle events for other systems to connect to
	enemySpawnedEvent = Instance.new("BindableEvent")
	enemySpawnedEvent.Name = "EnemySpawned"
	
	enemyDestroyedEvent = Instance.new("BindableEvent")
	enemyDestroyedEvent.Name = "EnemyDestroyed"
	
	enemyReachedGoalEvent = Instance.new("BindableEvent")
	enemyReachedGoalEvent.Name = "EnemyReachedGoal"
	
	enemyHealthChangedEvent = Instance.new("BindableEvent")
	enemyHealthChangedEvent.Name = "EnemyHealthChanged"
	
	-- Connect to RunService.Heartbeat for 60 FPS enemy updates
	heartbeatConnection = RunService.Heartbeat:Connect(updateEnemies)
	
	serviceInitialized = true
	LogService.info("EnemyService: Service initialization completed successfully", {
		updateRate = "60 FPS via RunService.Heartbeat",
		maxConcurrentEnemies = EnemyConstants.MAX_CONCURRENT_ENEMIES,
		spawnInterval = EnemyConstants.SPAWN_INTERVAL,
		eventsCreated = 4,
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
	
	-- Fire enemy spawned event for other systems
	if enemySpawnedEvent then
		enemySpawnedEvent:Fire(enemy)
	end
	
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

-- Display comprehensive debug information for educational purposes
function EnemyService.DisplayDebugInfo(): string
	if not serviceInitialized then
		return "EnemyService: Not initialized"
	end
	
	local debugLines = {}
	table.insert(debugLines, "=== ENEMY SYSTEM DEBUG INFO ===")
	table.insert(debugLines, "")
	
	-- Service status
	table.insert(debugLines, "Service Status:")
	table.insert(debugLines, string.format("  Initialized: %s", serviceInitialized))
	table.insert(debugLines, string.format("  Update Loop Running: %s", heartbeatConnection ~= nil))
	table.insert(debugLines, string.format("  Active Enemies: %d/%d", getActiveEnemyCount(), EnemyConstants.MAX_CONCURRENT_ENEMIES))
	table.insert(debugLines, string.format("  Total Spawned: %d", totalEnemiesSpawned))
	table.insert(debugLines, "")
	
	-- Enemy details
	if getActiveEnemyCount() > 0 then
		table.insert(debugLines, "Active Enemy Details:")
		local enemyIndex = 1
		for enemyId, enemy in pairs(activeEnemies) do
			table.insert(debugLines, string.format("  Enemy #%d (%s):", enemyIndex, string.sub(enemyId, 1, 8)))
			table.insert(debugLines, string.format("    State: %s", enemy:GetState()))
			table.insert(debugLines, string.format("    Health: %d/%d", enemy:GetHealth(), enemy:GetMaxHealth()))
			table.insert(debugLines, string.format("    Position: (%.1f, %.1f, %.1f)", enemy:GetPosition().X, enemy:GetPosition().Y, enemy:GetPosition().Z))
			table.insert(debugLines, string.format("    Distance to Target: %.1f studs", enemy:GetDistanceToTarget()))
			table.insert(debugLines, string.format("    Speed: %.1f studs/sec", enemy:GetSpeed()))
			enemyIndex += 1
		end
	else
		table.insert(debugLines, "No active enemies")
	end
	
	table.insert(debugLines, "")
	table.insert(debugLines, "Configuration:")
	table.insert(debugLines, string.format("  Spawn Interval: %.1fs", EnemyConstants.SPAWN_INTERVAL))
	table.insert(debugLines, string.format("  Max Concurrent: %d", EnemyConstants.MAX_CONCURRENT_ENEMIES))
	table.insert(debugLines, string.format("  Enemy Speed: %.1f studs/sec", EnemyConstants.BASE_SPEED))
	table.insert(debugLines, string.format("  Goal Detection Distance: %.1f studs", EnemyConstants.GOAL_DETECTION_DISTANCE))
	
	local debugInfo = table.concat(debugLines, "\n")
	
	-- Log debug info for external monitoring
	LogService.debug("EnemyService: Debug information displayed", {
		debugInfo = debugInfo,
		activeEnemyCount = getActiveEnemyCount(),
		totalSpawned = totalEnemiesSpawned,
	})
	
	return debugInfo
end

-- Get enemy by ID (for tower targeting integration)
function EnemyService.GetEnemyById(enemyId: string)
	if not serviceInitialized then
		LogService.error("EnemyService.GetEnemyById() called before initialization")
		return nil
	end
	
	return activeEnemies[enemyId]
end

-- Get enemies within radius of a position (for tower range checking)
function EnemyService.GetEnemiesInRadius(position: Vector3, radius: number): {Enemy.Enemy}
	if not serviceInitialized then
		LogService.error("EnemyService.GetEnemiesInRadius() called before initialization")
		return {}
	end
	
	local enemiesInRange = {}
	for _, enemy in pairs(activeEnemies) do
		local distance = (enemy:GetPosition() - position).Magnitude
		if distance <= radius then
			table.insert(enemiesInRange, enemy)
		end
	end
	
	return enemiesInRange
end

-- Get the closest enemy to a position (for basic tower targeting)
function EnemyService.GetClosestEnemyToPosition(position: Vector3)
	if not serviceInitialized then
		LogService.error("EnemyService.GetClosestEnemyToPosition() called before initialization")
		return nil
	end
	
	local closestEnemy = nil
	local closestDistance = math.huge
	
	for _, enemy in pairs(activeEnemies) do
		local distance = (enemy:GetPosition() - position).Magnitude
		if distance < closestDistance then
			closestDistance = distance
			closestEnemy = enemy
		end
	end
	
	return closestEnemy, closestDistance
end

-- Damage enemy by ID (for tower shooting integration)
function EnemyService.DamageEnemy(enemyId: string, damage: number): boolean
	if not serviceInitialized then
		LogService.error("EnemyService.DamageEnemy() called before initialization")
		return false
	end
	
	local enemy = activeEnemies[enemyId]
	if enemy then
		local wasAlive = enemy:IsAlive()
		local oldHealth = enemy:GetHealth()
		enemy:TakeDamage(damage)
		local newHealth = enemy:GetHealth()
		
		-- Fire health changed event
		if enemyHealthChangedEvent then
			enemyHealthChangedEvent:Fire(enemy, oldHealth, newHealth, damage)
		end
		
		-- Log significant events
		if wasAlive and not enemy:IsAlive() then
			LogService.info("EnemyService: Enemy destroyed by damage", {
				enemyId = enemyId,
				damage = damage,
				remainingHealth = newHealth,
			})
		end
		
		return true
	else
		LogService.warn("EnemyService: Attempted to damage non-existent enemy", {
			enemyId = enemyId,
		})
		return false
	end
end

-- Get lifecycle events for other systems to connect to
function EnemyService.GetEnemySpawnedEvent()
	return enemySpawnedEvent
end

function EnemyService.GetEnemyDestroyedEvent()
	return enemyDestroyedEvent
end

function EnemyService.GetEnemyReachedGoalEvent()
	return enemyReachedGoalEvent
end

function EnemyService.GetEnemyHealthChangedEvent()
	return enemyHealthChangedEvent
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
	
	-- Clean up lifecycle events
	if enemySpawnedEvent then
		enemySpawnedEvent:Destroy()
		enemySpawnedEvent = nil
	end
	if enemyDestroyedEvent then
		enemyDestroyedEvent:Destroy()
		enemyDestroyedEvent = nil
	end
	if enemyReachedGoalEvent then
		enemyReachedGoalEvent:Destroy()
		enemyReachedGoalEvent = nil
	end
	if enemyHealthChangedEvent then
		enemyHealthChangedEvent:Destroy()
		enemyHealthChangedEvent = nil
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
	lastStatsLogTime = 0
	
	LogService.info("EnemyService: Service shutdown completed", {
		enemiesRemoved = enemyCount,
		eventsDestroyed = 4,
	})
end

return EnemyService