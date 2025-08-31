local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LogService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LogService"))
local MapService = require(script.services.MapService)
local EnemyService = require(script.services.EnemyService)

LogService.info("Server script started")

-- Initialize the game map
MapService.Initialize()
LogService.info("Map initialization completed")

-- Initialize the enemy system
EnemyService.Initialize()
LogService.info("Enemy system initialization completed")

-- Log when players join (server context)
Players.PlayerAdded:Connect(function(player)
	LogService.info(("Player joined: %s (%d)"):format(player.Name, player.UserId), {
		userId = player.UserId,
		name = player.Name,
	})
end)

-- Manual testing: Spawn enemies periodically for Phase 1 testing
-- This can be removed/modified once wave system is implemented
task.wait(2) -- Give services time to initialize
LogService.info("Starting manual enemy spawning test")

spawn(function()
	while true do
		-- Spawn an enemy every few seconds for testing
		task.wait(3)
		local spawned = EnemyService.SpawnEnemy()
		if spawned then
			local stats = EnemyService.GetStatistics()
			LogService.info("Test spawn successful", stats)
		else
			LogService.debug("Test spawn failed - likely at limit or too soon")
		end
	end
end)
