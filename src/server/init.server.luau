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
