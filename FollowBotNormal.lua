getgenv().HowFastDanSchneiderCatchesYou = 1
getgenv().SelectedPlayer = nil
getgenv().Daddy_Catches_You = false

local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()

local w = library:CreateWindow("Player Follower")
local b = w:CreateFolder("Follow Settings")

b:Slider("Follow Speed", {
    min = 0; 
    max = 1; 
    precise = true;
}, function(value)
    getgenv().HowFastDanSchneiderCatchesYou = value
end)

local playerList = {}
local playerDropdown

local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end

    -- Recreate dropdown with new player list
    if playerDropdown then
        playerDropdown:Remove() -- remove old dropdown before making a new one
    end
    playerDropdown = b:Dropdown("Select Player", playerList, true, function(value)
        getgenv().SelectedPlayer = value
    end)
end

-- Button to manually refresh
b:Button("Refresh Player List", function()
    updatePlayerList()
end)

b:Toggle("Enable Following", function(bool)
    getgenv().Daddy_Catches_You = bool
end)

-- Auto update when players join/leave
game.Players.PlayerAdded:Connect(function()
    task.wait(1)
    updatePlayerList()
end)

game.Players.PlayerRemoving:Connect(function()
    task.wait(1)
    updatePlayerList()
end)

-- Initial load
task.spawn(function()
    task.wait(2)
    updatePlayerList()
end)

local localPlayer = game.Players.LocalPlayer

local function getSelectedPlayer()
    local selName = getgenv().SelectedPlayer
    if selName and game.Players:FindFirstChild(selName) then
        local player = game.Players[selName]
        if player.Character 
        and player.Character:FindFirstChild("Humanoid") 
        and player.Character.Humanoid.Health > 0 
        and player.Character:FindFirstChild("HumanoidRootPart") then
            return player
        end
    end
    return nil
end

game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().Daddy_Catches_You and getSelectedPlayer() then
        local targetPlayer = getSelectedPlayer()
        if localPlayer.Character 
        and localPlayer.Character:FindFirstChild("HumanoidRootPart") 
        and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            
            local targetPart = targetPlayer.Character.HumanoidRootPart
            local part = localPlayer.Character.HumanoidRootPart
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

            -- Lock rotation to face target
            humanoid.AutoRotate = false
            part.CFrame = part.CFrame:Lerp(
                CFrame.new(part.Position, targetPart.Position),
                getgenv().HowFastDanSchneiderCatchesYou
            )

            -- Move towards target
            humanoid:MoveTo(targetPart.Position)

            -- Jump if target is in freefall
            if targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            and targetPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid.Jump = true
            end
        end
    else
        -- Reset autorotate if not following
        if localPlayer.Character 
        and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character:FindFirstChildOfClass("Humanoid").AutoRotate = true
        end
    end
end)

-- Keybind toggle
local mouse = localPlayer:GetMouse()
mouse.KeyDown:Connect(function(key)
    if key == "x" then
        getgenv().Daddy_Catches_You = not getgenv().Daddy_Catches_You
    end
end)