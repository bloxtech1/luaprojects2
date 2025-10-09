local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerListGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- UI palautusnappi (pallo)
local uiButton = Instance.new("TextButton")
uiButton.Size = UDim2.new(0, 40, 0, 40)
uiButton.Position = UDim2.new(0, 10, 0.5, -20)
uiButton.BackgroundColor3 = Color3.new(0, 0, 0)
uiButton.Text = "UI"
uiButton.Visible = false
uiButton.Parent = screenGui
local cornerBall = Instance.new("UICorner")
cornerBall.CornerRadius = UDim.new(1, 0)
cornerBall.Parent = uiButton

-- Liikuteltavuus UI-pallolle
local draggingBall = false
local dragInputBall, dragStartBall, startPosBall

uiButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingBall = true
		dragStartBall = input.Position
		startPosBall = uiButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingBall = false
			end
		end)
	end
end)

uiButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInputBall = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInputBall and draggingBall then
		local delta = input.Position - dragStartBall
		uiButton.Position = UDim2.new(
			startPosBall.X.Scale,
			startPosBall.X.Offset + delta.X,
			startPosBall.Y.Scale,
			startPosBall.Y.Offset + delta.Y
		)
	end
end)

-- Pääkehys
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.7
frame.Parent = screenGui
frame.ClipsDescendants = true
frame.BorderSizePixel = 0

-- Reunat
local function luoReuna(position, size)
	local border = Instance.new("Frame")
	border.BackgroundColor3 = Color3.new(0, 0, 0)
	border.BackgroundTransparency = 0
	border.BorderSizePixel = 0
	border.Position = position
	border.Size = size
	border.Parent = frame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = border
end

luoReuna(UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 2))
luoReuna(UDim2.new(0, 0, 1, -2), UDim2.new(1, 0, 0, 2))
luoReuna(UDim2.new(0, 0, 0, 0), UDim2.new(0, 2, 1, 0))
luoReuna(UDim2.new(1, -2, 0, 0), UDim2.new(0, 2, 1, 0))

-- Liikuteltavuus
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Piilotus ja sulku napit
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -70, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 16
minimize.Parent = frame

close.MouseButton1Click:Connect(function()
	frame.Visible = false
	uiButton.Visible = false
end)

minimize.MouseButton1Click:Connect(function()
	frame.Visible = false
	uiButton.Visible = true
end)

uiButton.MouseButton1Click:Connect(function()
	frame.Visible = true
	uiButton.Visible = false
end)

-- ScrollFrame pelaajille
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.Parent = frame

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)

-- Päivitä pelaajalista
local function updateList()
	for _, child in pairs(scroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local yOffset = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local entry = Instance.new("Frame")
			entry.Size = UDim2.new(1, -10, 0, 50)
			entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			entry.BorderSizePixel = 0
			entry.Parent = scroll
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = entry

			local thumb = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			local img = Instance.new("ImageLabel")
			img.Size = UDim2.new(0, 48, 0, 48)
			img.Position = UDim2.new(0, 5, 0, 1)
			img.BackgroundTransparency = 1
			img.Image = thumb
			img.Parent = entry

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.5, -60, 1, 0)
			nameLabel.Position = UDim2.new(0, 58, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = Color3.new(1, 1, 1)
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 16
			nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = entry

			local gotoButton = Instance.new("TextButton")
			gotoButton.Size = UDim2.new(0, 60, 0, 30)
			gotoButton.Position = UDim2.new(1, -70, 0.5, -15)
			gotoButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
			gotoButton.TextColor3 = Color3.new(1, 1, 1)
			gotoButton.Font = Enum.Font.GothamBold
			gotoButton.TextSize = 14
			gotoButton.Text = "GoTo"
			gotoButton.Parent = entry

			gotoButton.MouseButton1Click:Connect(function()
				local character = localPlayer.Character
				local targetCharacter = player.Character
				if character and targetCharacter and
					character:FindFirstChild("HumanoidRootPart") and
					targetCharacter:FindFirstChild("HumanoidRootPart") then
					character:MoveTo(targetCharacter.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
				end
			end)

			yOffset = yOffset + 56
		end
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
