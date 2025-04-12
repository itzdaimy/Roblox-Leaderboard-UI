--[[
 // made by daimy \\
 This goes in: StarterPlayer -> StarterPlayerScripts
]]

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

-- // CONFIG \\ --

local leaderboardTitle = "PLAYERS"
local maxEntries = 10
local animationDuration = 0.5
local defaultToggleKey = Enum.KeyCode.Tab
local ranksEnabled = true

-- // END OF CONFIG \\ --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local updateEvent = ReplicatedStorage:WaitForChild("UpdateLeaderboardUI")
local player = Players.LocalPlayer

local function createStroke(parent, thickness, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 1.5
	stroke.Color = color or Color3.fromRGB(255, 255, 255)
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function createGradient(parent, colorTop, colorBottom, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colorTop or Color3.fromRGB(45, 45, 85)),
		ColorSequenceKeypoint.new(1, colorBottom or Color3.fromRGB(35, 35, 65))
	})
	gradient.Rotation = rotation or 90
	gradient.Parent = parent
	return gradient
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomLeaderboard"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "LeaderboardContainer"
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(1, -340, 0, 80)
mainFrame.BackgroundTransparency = 1
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local bgFrame = Instance.new("Frame")
bgFrame.Name = "Background"
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
bgFrame.BackgroundTransparency = 0.1
bgFrame.BorderSizePixel = 0
bgFrame.Parent = mainFrame
createCorner(bgFrame, 12)
createGradient(bgFrame, Color3.fromRGB(35, 35, 75), Color3.fromRGB(20, 20, 40))
createStroke(bgFrame, 2, Color3.fromRGB(100, 100, 255), 0.7)

local headerContainer = Instance.new("Frame")
headerContainer.Name = "HeaderContainer"
headerContainer.Size = UDim2.new(1, 0, 0, 60)
headerContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
headerContainer.BackgroundTransparency = 0.2
headerContainer.BorderSizePixel = 0
headerContainer.Parent = bgFrame
createCorner(headerContainer, 12)
createGradient(headerContainer, Color3.fromRGB(50, 50, 120), Color3.fromRGB(30, 30, 80))

local headerShadow = Instance.new("Frame")
headerShadow.Name = "HeaderShadow"
headerShadow.Size = UDim2.new(1, 0, 0, 15)
headerShadow.Position = UDim2.new(0, 0, 1, -5)
headerShadow.BackgroundTransparency = 0
headerShadow.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
headerShadow.BorderSizePixel = 0
headerShadow.ZIndex = 2
headerShadow.Parent = headerContainer

local shadowGradient = createGradient(headerShadow, Color3.fromRGB(30, 30, 60, 0.8), Color3.fromRGB(30, 30, 60, 0))
shadowGradient.Rotation = 270

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = leaderboardTitle
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.Parent = headerContainer

local titleGlow = Instance.new("ImageLabel")
titleGlow.Name = "TitleGlow"
titleGlow.Size = UDim2.new(1.2, 0, 1.2, 0)
titleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
titleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
titleGlow.BackgroundTransparency = 1
titleGlow.Image = "rbxassetid://6947150722"
titleGlow.ImageColor3 = Color3.fromRGB(100, 100, 255)
titleGlow.ImageTransparency = 0.7
titleGlow.Parent = titleLabel

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(1, 0, 0, 20)
subtitleLabel.Position = UDim2.new(0, 0, 1, -20)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "ONLINE: 0"
subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 14
subtitleLabel.TextTransparency = 0.3
subtitleLabel.Parent = headerContainer

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -80)
contentFrame.Position = UDim2.new(0, 10, 0, 70)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
contentFrame.ScrollBarImageTransparency = 0.5
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = bgFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Name = "ListLayout"
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = contentFrame

local function createPlayerEntry(playerName, index)
	local entryFrame = Instance.new("Frame")
	entryFrame.Name = "Entry" .. index
	entryFrame.Size = UDim2.new(1, -10, 0, 50)
	entryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
	entryFrame.BackgroundTransparency = 0.3
	entryFrame.BorderSizePixel = 0
	entryFrame.LayoutOrder = index
	entryFrame.ClipsDescendants = true
	entryFrame.Parent = contentFrame
	createCorner(entryFrame, 8)

	if ranksEnabled then
		if index == 1 then
			createGradient(entryFrame, Color3.fromRGB(255, 215, 0), Color3.fromRGB(200, 170, 0), 45)
		elseif index == 2 then
			createGradient(entryFrame, Color3.fromRGB(192, 192, 192), Color3.fromRGB(150, 150, 150), 45)
		elseif index == 3 then
			createGradient(entryFrame, Color3.fromRGB(205, 127, 50), Color3.fromRGB(160, 100, 40), 45)
		else
			createGradient(entryFrame, Color3.fromRGB(60, 60, 100), Color3.fromRGB(40, 40, 80), 45)
		end
	else
		createGradient(entryFrame, Color3.fromRGB(60, 60, 100), Color3.fromRGB(40, 40, 80), 45)
	end

	local rankLabel = Instance.new("TextLabel")
	rankLabel.Name = "Rank"
	rankLabel.Size = UDim2.new(0, 40, 1, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = ranksEnabled and ("#" .. index) or ""
	rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rankLabel.Font = Enum.Font.GothamBold
	rankLabel.TextSize = 18
	rankLabel.Parent = entryFrame
	rankLabel.Visible = ranksEnabled

	local thumbnailPosition, namePosition
	if ranksEnabled then
		thumbnailPosition = UDim2.new(0, 45, 0.5, 0)
		namePosition = UDim2.new(0, 90, 0, 0)
	else
		thumbnailPosition = UDim2.new(0, 15, 0.5, 0)
		namePosition = UDim2.new(0, 60, 0, 0)
	end

	local thumbnail = Instance.new("ImageLabel")
	thumbnail.Name = "Avatar"
	thumbnail.Size = UDim2.new(0, 36, 0, 36)
	thumbnail.Position = thumbnailPosition
	thumbnail.AnchorPoint = Vector2.new(0, 0.5)
	thumbnail.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	thumbnail.BackgroundTransparency = 0.5
	thumbnail.BorderSizePixel = 0
	thumbnail.Image = ""
	thumbnail.Parent = entryFrame
	createCorner(thumbnail, 18)
	createStroke(thumbnail, 1.5, Color3.fromRGB(100, 100, 200), 0.5)

	local userId = Players:GetUserIdFromNameAsync(playerName)
	local success, _ = pcall(function()
		local content = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		thumbnail.Image = content
	end)
	if not success then
		thumbnail.Image = "rbxassetid://7962146544"
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerName"
	nameLabel.Size = UDim2.new(1, -100, 1, 0)
	nameLabel.Position = namePosition
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = playerName
	nameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
	nameLabel.Font = Enum.Font.GothamSemibold
	nameLabel.TextSize = 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = entryFrame

	if playerName == player.Name then
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
		local youIndicator = Instance.new("TextLabel")
		youIndicator.Name = "YouIndicator"
		youIndicator.Size = UDim2.new(0, 40, 0, 20)
		youIndicator.Position = UDim2.new(1, -45, 0.5, 0)
		youIndicator.AnchorPoint = Vector2.new(0, 0.5)
		youIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
		youIndicator.BackgroundTransparency = 0.7
		youIndicator.BorderSizePixel = 0
		youIndicator.Text = "YOU"
		youIndicator.TextColor3 = Color3.fromRGB(255, 255, 0)
		youIndicator.Font = Enum.Font.GothamBold
		youIndicator.TextSize = 12
		youIndicator.Parent = entryFrame
		createCorner(youIndicator, 4)
	end

	return entryFrame
end

local footerLabel = Instance.new("TextLabel")
footerLabel.Name = "Footer"
footerLabel.Size = UDim2.new(1, 0, 0, 30)
footerLabel.Position = UDim2.new(0, 0, 1, -30)
footerLabel.BackgroundTransparency = 1
footerLabel.Text = "Press TAB to toggle"
footerLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
footerLabel.TextTransparency = 0.5
footerLabel.Font = Enum.Font.Gotham
footerLabel.TextSize = 14
footerLabel.Parent = bgFrame

local function animateEntry(frame, index)
	frame.Visible = true
	frame.Position = UDim2.new(0, -frame.Size.X.Offset, 0, frame.Position.Y.Offset)
	frame.BackgroundTransparency = 1
	for _, obj in ipairs(frame:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("ImageLabel") or obj:IsA("Frame") then
			obj.Transparency = 1
		end
	end

	local tweenInfo = TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, index * 0.05)
	local tween = TweenService:Create(frame, tweenInfo, {
		Position = UDim2.new(0, 0, 0, frame.Position.Y.Offset),
		BackgroundTransparency = 0.3
	})
	tween:Play()

	for _, obj in ipairs(frame:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("ImageLabel") or obj:IsA("Frame") then
			local fadeTween = TweenService:Create(obj, tweenInfo, {Transparency = 0})
			fadeTween:Play()
		end
	end
end

local playerEntries = {}

local function updatePlayerList()
	for _, entry in pairs(playerEntries) do
		entry:Destroy()
	end
	playerEntries = {}

	local playerList = Players:GetPlayers()

	subtitleLabel.Text = "ONLINE: " .. #playerList

	for i, plr in ipairs(playerList) do
		local entry = createPlayerEntry(plr.Name, i)
		playerEntries[plr.Name] = entry

		if isVisible then
			animateEntry(entry, i)
		end
	end

	contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

local function toggleLeaderboard(visible)
	local startPos = visible and UDim2.new(1, -340, 0, 80) or UDim2.new(1, -340, 0, 80)
	local endPos = visible and UDim2.new(1, -340, 0, 80) or UDim2.new(1, 20, 0, 80)
	local startSize = visible and UDim2.new(0, 0, 0, 420) or UDim2.new(0, 320, 0, 420)
	local endSize = visible and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 0, 0, 420)

	mainFrame.Position = startPos
	mainFrame.Size = startSize

	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = endPos,
		Size = endSize
	})

	tween:Play()

	if visible then
		task.spawn(function()
			tween.Completed:Wait()
			updatePlayerList()
		end)
	end
end

local isVisible = false
mainFrame.Size = UDim2.new(0, 0, 0, 420)

UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == defaultToggleKey then
		isVisible = not isVisible
		toggleLeaderboard(isVisible)
	end
end)

updatePlayerList()

Players.PlayerAdded:Connect(function()
	updatePlayerList()
end)

Players.PlayerRemoving:Connect(function()
	updatePlayerList()
end)

spawn(function()
	while true do
		updatePlayerList()
		task.wait(5)
	end
end)

toggleLeaderboard(false)
