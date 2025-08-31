local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LogService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LogService"))

-- Optional: override URL if needed (defaults to http://127.0.0.1:5000/log)
-- LogService.setHttpUrl("http://127.0.0.1:5000/log")

LogService.info("Client script started", {
	player = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown",
})
