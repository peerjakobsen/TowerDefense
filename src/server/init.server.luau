local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LogService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LogService"))

LogService.info("Server script started")

-- Log when players join (server context)
Players.PlayerAdded:Connect(function(player)
	LogService.info(("Player joined: %s (%d)"):format(player.Name, player.UserId), {
		userId = player.UserId,
		name = player.Name,
	})
end)

-- Sample messages to verify levels and server logging
task.delay(1, function()
	LogService.warn("Test warn from server")
end)

task.delay(2, function()
	LogService.error("Test error from server")
end)
