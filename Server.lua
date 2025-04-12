--[[
 // made by daimy \\
 This goes in: ServerScriptServices
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local updateEvent = ReplicatedStorage:FindFirstChild("UpdateLeaderboardUI")

if not updateEvent then
	updateEvent = Instance.new("RemoteEvent")
	updateEvent.Name = "UpdateLeaderboardUI"
	updateEvent.Parent = ReplicatedStorage
end
