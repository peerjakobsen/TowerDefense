local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LogService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LogService"))
local MapService = require(script.services.MapService)
local EnemyConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("constants"):WaitForChild("EnemyConstants"))

LogService.info("Server script started")

-- Initialize the game map
MapService.Initialize()
LogService.info("Map initialization completed")

-- Test EnemyConstants accessibility
LogService.info("Testing EnemyConstants accessibility from server script")
LogService.info(("Enemy base health: %d"):format(EnemyConstants.BASE_HEALTH))
LogService.info(("Enemy base speed: %d"):format(EnemyConstants.BASE_SPEED))
LogService.info(("Max concurrent enemies: %d"):format(EnemyConstants.MAX_CONCURRENT_ENEMIES))
LogService.info(("Enemy states available: %s"):format(table.concat({
	EnemyConstants.STATES.SPAWNING,
	EnemyConstants.STATES.MOVING,
	EnemyConstants.STATES.REACHED_TARGET,
	EnemyConstants.STATES.DESTROYED
}, ", ")))
LogService.info("EnemyConstants test completed successfully")

-- Log when players join (server context)
Players.PlayerAdded:Connect(function(player)
	LogService.info(("Player joined: %s (%d)"):format(player.Name, player.UserId), {
		userId = player.UserId,
		name = player.Name,
	})
end)
