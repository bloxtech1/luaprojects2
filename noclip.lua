--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Trajectory Prediction System
-- By Educationalist

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Main GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrajectoryGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 280)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Corner and Stroke for styling
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 80)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 20, 0, 20)
Logo.Position = UDim2.new(0, 8, 0, 5)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://7072716644" -- Default Roblox icon, replace with your own
Logo.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 35, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TRAJECTORY PREDICTION"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = TitleBar

-- Control Buttons
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12
CloseButton.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -50, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 14
MinimizeButton.Parent = TitleBar

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Description
local Description = Instance.new("TextLabel")
Description.Name = "Description"
Description.Size = UDim2.new(1, 0, 0, 40)
Description.BackgroundTransparency = 1
Description.Text = "Toggle trajectory prediction lines for different entities"
Description.TextColor3 = Color3.fromRGB(200, 200, 200)
Description.Font = Enum.Font.Gotham
Description.TextSize = 12
Description.TextWrapped = true
Description.Parent = ContentFrame

-- Toggle Buttons
local buttonTemplates = {
    {
        Name = "Character",
        Text = "CHARACTER TRAJECTORY",
        Description = "Shows your movement trajectory",
        Color = Color3.fromRGB(76, 175, 80)
    },
    {
        Name = "Players",
        Text = "PLAYERS TRAJECTORY", 
        Description = "Shows other players' trajectories",
        Color = Color3.fromRGB(33, 150, 243)
    },
    {
        Name = "Objects",
        Text = "OBJECTS TRAJECTORY",
        Description = "Shows moving objects trajectories",
        Color = Color3.fromRGB(255, 87, 87)
    }
}

local toggleStates = {
    Character = false,
    Players = false,
    Objects = false
}

local buttons = {}
local yOffset = 50

for i, template in ipairs(buttonTemplates) do
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = template.Name .. "Frame"
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.Position = UDim2.new(0, 0, 0, yOffset)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = ContentFrame
    
    local button = Instance.new("TextButton")
    button.Name = template.Name .. "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = template.Color
    button.Text = template.Text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = buttonFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -10, 0, 15)
    description.Position = UDim2.new(0, 5, 1, 5)
    description.BackgroundTransparency = 1
    description.Text = template.Description
    description.TextColor3 = Color3.fromRGB(180, 180, 180)
    description.Font = Enum.Font.Gotham
    description.TextSize = 10
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = buttonFrame
    
    buttons[template.Name] = button
    yOffset = yOffset + 60
end

-- Trajectory Visualization System
local trajectories = {}
local connection
local trajectoryFolder = Instance.new("Folder")
trajectoryFolder.Name = "TrajectoryLines"
trajectoryFolder.Parent = workspace

local function createTrajectoryLine(color, parent)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Size = Vector3.new(0.1, 0.1, 1)
    part.Transparency = 0.3
    part.CastShadow = false
    part.Parent = parent or trajectoryFolder
    
    return part
end

local function clearTrajectory(key)
    if trajectories[key] then
        for _, part in ipairs(trajectories[key]) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        trajectories[key] = nil
    end
end

local function clearAllTrajectories()
    for key, _ in pairs(trajectories) do
        clearTrajectory(key)
    end
end

local function updateCharacterTrajectory()
    local key = "Character"
    
    if not toggleStates.Character then
        clearTrajectory(key)
        return
    end
    
    if not player.Character then
        clearTrajectory(key)
        return
    end
    
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then 
        clearTrajectory(key)
        return
    end
    
    local velocity = rootPart.Velocity
    local position = rootPart.Position
    
    -- Clear previous trajectory
    clearTrajectory(key)
    
    -- Create new trajectory
    local newTrajectory = {}
    local gravity = Vector3.new(0, -workspace.Gravity, 0)
    local predictionTime = 2
    local segments = 20
    
    local lastPoint = position + Vector3.new(0, 2, 0) -- Raise line up by 2 studs
    
    for i = 1, segments do
        local t = (i / segments) * predictionTime
        local point = position + (velocity * t) + (0.5 * gravity * t * t) + Vector3.new(0, 2, 0) -- Raise line up
        
        if i == 1 then
            -- Starting point indicator
            local line = createTrajectoryLine(Color3.new(0, 1, 0))
            line.Size = Vector3.new(0.4, 0.4, 0.4)
            line.Position = point
            line.Shape = Enum.PartType.Ball
            table.insert(newTrajectory, line)
        else
            -- Create line between points
            local distance = (lastPoint - point).Magnitude
            
            if distance > 0.1 then
                local line = createTrajectoryLine(Color3.new(0, 1, 0))
                line.Size = Vector3.new(0.15, 0.15, distance)
                
                -- Make line face forward horizontally, not towards ground
                local lookVector = (point - lastPoint).Unit
                if lookVector.Magnitude > 0 then
                    line.CFrame = CFrame.lookAt((lastPoint + point) / 2, point)
                end
                
                table.insert(newTrajectory, line)
            end
        
            lastPoint = point
        end
    end
    
    trajectories[key] = newTrajectory
end

local function updatePlayersTrajectories()
    -- Clear all player trajectories if toggle is off
    if not toggleStates.Players then
        for key, trajectory in pairs(trajectories) do
            if string.sub(key, 1, 7) == "Player_" then
                clearTrajectory(key)
            end
        end
        return
    end
    
    -- Update trajectories for all players
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local key = "Player_" .. otherPlayer.UserId
            local character = otherPlayer.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not rootPart then continue end
            
            local velocity = rootPart.Velocity
            local position = rootPart.Position
            
            -- Clear previous trajectory
            clearTrajectory(key)
            
            -- Create new trajectory
            local newTrajectory = {}
            local gravity = Vector3.new(0, -workspace.Gravity, 0)
            local predictionTime = 2
            local segments = 20
            
            local lastPoint = position + Vector3.new(0, 2, 0) -- Raise line up by 2 studs
            
            for i = 1, segments do
                local t = (i / segments) * predictionTime
                local point = position + (velocity * t) + (0.5 * gravity * t * t) + Vector3.new(0, 2, 0) -- Raise line up
                
                if i == 1 then
                    local line = createTrajectoryLine(Color3.new(0, 0, 1))
                    line.Size = Vector3.new(0.4, 0.4, 0.4)
                    line.Position = point
                    line.Shape = Enum.PartType.Ball
                    table.insert(newTrajectory, line)
                else
                    local distance = (lastPoint - point).Magnitude
                    
                    if distance > 0.1 then
                        local line = createTrajectoryLine(Color3.new(0, 0, 1))
                        line.Size = Vector3.new(0.15, 0.15, distance)
                        
                        -- Make line face forward horizontally
                        local lookVector = (point - lastPoint).Unit
                        if lookVector.Magnitude > 0 then
                            line.CFrame = CFrame.lookAt((lastPoint + point) / 2, point)
                        end
                        
                        table.insert(newTrajectory, line)
                    end
                
                    lastPoint = point
                end
            end
            
            trajectories[key] = newTrajectory
        end
    end
end

local function updateObjectsTrajectory()
    local key = "Objects"
    
    if not toggleStates.Objects then
        clearTrajectory(key)
        return
    end
    
    -- Clear previous object trajectories
    clearTrajectory(key)
    
    -- Find moving objects in workspace
    local newTrajectory = {}
    
    -- Look for moving parts that aren't characters
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and not obj:IsDescendantOf(trajectoryFolder) then
            -- Check if it's moving significantly
            local velocity = obj.Velocity
            if velocity.Magnitude > 2 then -- Minimum speed threshold
                -- Check if it's not part of a character
                local isCharacterPart = false
                local parent = obj.Parent
                if parent then
                    if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                        isCharacterPart = true
                    end
                    if parent.Parent and parent.Parent:IsA("Model") and parent.Parent:FindFirstChildOfClass("Humanoid") then
                        isCharacterPart = true
                    end
                end
                
                if not isCharacterPart then
                    local position = obj.Position
                    local gravity = Vector3.new(0, -workspace.Gravity, 0)
                    local predictionTime = 3 -- Longer prediction for objects
                    local segments = 15
                    
                    local lastPoint = position + Vector3.new(0, 2, 0) -- Raise line up by 2 studs
                    
                    for i = 1, segments do
                        local t = (i / segments) * predictionTime
                        local point = position + (velocity * t) + (0.5 * gravity * t * t) + Vector3.new(0, 2, 0) -- Raise line up
                        
                        if i == 1 then
                            local line = createTrajectoryLine(Color3.new(1, 0.5, 0))
                            line.Size = Vector3.new(0.4, 0.4, 0.4)
                            line.Position = point
                            line.Shape = Enum.PartType.Ball
                            table.insert(newTrajectory, line)
                        else
                            local distance = (lastPoint - point).Magnitude
                            
                            if distance > 0.1 then
                                local line = createTrajectoryLine(Color3.new(1, 0.5, 0))
                                line.Size = Vector3.new(0.15, 0.15, distance)
                                
                                -- Make line face forward horizontally
                                local lookVector = (point - lastPoint).Unit
                                if lookVector.Magnitude > 0 then
                                    line.CFrame = CFrame.lookAt((lastPoint + point) / 2, point)
                                end
                                
                                table.insert(newTrajectory, line)
                            end
                        
                            lastPoint = point
                        end
                    end
                end
            end
        end
    end
    
    trajectories[key] = newTrajectory
end

local function updateAllTrajectories()
    updateCharacterTrajectory()
    updatePlayersTrajectories()
    updateObjectsTrajectory()
end

-- GUI Interaction Functions
local function toggleButton(buttonName)
    toggleStates[buttonName] = not toggleStates[buttonName]
    
    local button = buttons[buttonName]
    if button then
        if toggleStates[buttonName] then
            button.BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.3)
        else
            -- Find the original color from templates
            for _, template in ipairs(buttonTemplates) do
                if template.Name == buttonName then
                    button.BackgroundColor3 = template.Color
                    break
                end
            end
        end
    end
    
    -- Immediately update trajectories when toggling
    if buttonName == "Character" then
        updateCharacterTrajectory()
    elseif buttonName == "Players" then
        updatePlayersTrajectories()
    elseif buttonName == "Objects" then
        updateObjectsTrajectory()
    end
    
    -- Start/stop the update loop if any trajectory is active
    local anyActive = false
    for _, state in pairs(toggleStates) do
        if state then
            anyActive = true
            break
        end
    end
    
    if anyActive and not connection then
        connection = RunService.RenderStepped:Connect(updateAllTrajectories)
        print("Trajectory system activated")
    elseif not anyActive and connection then
        connection:Disconnect()
        connection = nil
        clearAllTrajectories()
        print("Trajectory system deactivated")
    end
end

-- Button Connections
for name, button in pairs(buttons) do
    button.MouseButton1Click:Connect(function()
        toggleButton(name)
    end)
end

-- Make GUI Draggable
local dragging = false
local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Close and Minimize Functions
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if connection then
        connection:Disconnect()
    end
    trajectoryFolder:Destroy()
end)

local minimized = false
local originalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    if minimized then
        -- Minimize
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 30)})
        tween:Play()
    else
        -- Restore
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(MainFrame, tweenInfo, {Size = originalSize})
        tween:Play()
    end
end)

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        if connection then
            connection:Disconnect()
        end
        trajectoryFolder:Destroy()
    end
end)

-- Initialization
print("Trajectory Prediction System Loaded! - By Educationalist")
print("Features:")
print("- Character trajectory prediction (Green lines)")
print("- Players trajectory prediction (Blue lines)") 
print("- Objects trajectory prediction (Orange lines)")
print("- Draggable GUI with minimize/close buttons")
print("- Lines are raised 2 studs above ground level")
