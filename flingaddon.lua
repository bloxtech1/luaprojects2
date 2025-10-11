getgenv().HowFastDanSchneiderCatchesYou = 1
getgenv().SelectedPlayer = "Nearest Player"
getgenv().Daddy_Catches_You = false
getgenv().MimicMoves = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 3;
    })
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))()
local w = library:CreateWindow("Player Follower")
local b = w:CreateFolder("Follow Settings")

-- Speed slider
b:Slider("Follow Speed", {
    min = 0; max = 1; precise = true;
}, function(value)
    getgenv().HowFastDanSchneiderCatchesYou = value
end)

-- NEW: Manual Username Entry
b:Box("Type Username", "string", function(value)
    local trimmed = string.gsub(value, "%s+", "")
    if trimmed ~= "" then
        if trimmed == "Nearest" or trimmed == "Nearest Player" then
            getgenv().SelectedPlayer = "Nearest Player"
            notify("Player Selected", "Nearest Player", 2)
        elseif Players:FindFirstChild(trimmed) then
            getgenv().SelectedPlayer = trimmed
            notify("Player Selected", "Found and set to "..trimmed, 2)
        else
            getgenv().SelectedPlayer = nil
            notify("Player Not Found", "No player with username: " .. trimmed, 3)
        end
    end
end)

-- Button-based player selection logic with visual feedback
local playerButtons = {}

local function clearPlayerButtons()
    for _, btnData in ipairs(playerButtons) do
        if btnData.button and btnData.button.Destroy then
            btnData.button:Destroy()
        end
    end
    playerButtons = {}
end

local function drawPlayerButtons()
    clearPlayerButtons()
    -- Always add "Nearest Player" first
    table.insert(playerButtons, {
        name = "Nearest Player",
        button = b:Button(
            (getgenv().SelectedPlayer == "Nearest Player" and "-> " or "") .. "Nearest Player",
            function()
                getgenv().SelectedPlayer = "Nearest Player"
                drawPlayerButtons()
                notify("Player Selected", "Nearest Player", 2)
            end
        )
    })
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local displayName = player.Name
            local isSelected = getgenv().SelectedPlayer == player.Name
            table.insert(playerButtons, {
                name = displayName,
                button = b:Button(
                    (isSelected and "-> " or "") .. displayName,
                    function()
                        getgenv().SelectedPlayer = displayName
                        drawPlayerButtons()
                        notify("Player Selected", displayName, 2)
                    end
                )
            })
        end
    end
end

drawPlayerButtons()

-- Refresh button
b:Button("Refresh Player List", function()
    drawPlayerButtons()
    notify("Player List", "Updated!", 2)
end)

Players.PlayerAdded:Connect(function()
    task.wait(1)
    drawPlayerButtons()
end)
Players.PlayerRemoving:Connect(function()
    task.wait(1)
    drawPlayerButtons()
end)
task.delay(2, drawPlayerButtons)

-- Toggles
b:Toggle("Enable Following", function(bool)
    getgenv().Daddy_Catches_You = bool
    notify("Following", bool and "Enabled" or "Disabled")
end)

b:Toggle("Mimic Movements", function(bool)
    getgenv().MimicMoves = bool
    if bool then
        getgenv().Daddy_Catches_You = true
        notify("Mimic", "Enabled (Follow forced on)")
    else
        notify("Mimic", "Disabled")
    end
end)

-- Nearest player logic
local function getNearestPlayer()
    local closest, dist = nil, math.huge
    local localChar = localPlayer.Character
    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
        local myPos = localChar.HumanoidRootPart.Position
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local d = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < dist then
                    closest, dist = player, d
                end
            end
        end
    end
    return closest
end

-- Get selected target
local function getSelectedPlayer()
    if getgenv().SelectedPlayer == "Nearest Player" then
        return getNearestPlayer()
    elseif getgenv().SelectedPlayer and Players:FindFirstChild(getgenv().SelectedPlayer) then
        local player = Players[getgenv().SelectedPlayer]
        if player.Character and player.Character:FindFirstChild("Humanoid") 
            and player.Character.Humanoid.Health > 0 
            and player.Character:FindFirstChild("HumanoidRootPart") then
            return player
        end
    end
    return nil
end

-- Follow loop
RunService.RenderStepped:Connect(function()
    local targetPlayer = getSelectedPlayer()
    if getgenv().Daddy_Catches_You and targetPlayer then
        local targetChar = targetPlayer.Character
        local localChar = localPlayer.Character
        if localChar and targetChar and localChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
            local targetPart = targetChar.HumanoidRootPart
            local part = localChar.HumanoidRootPart

            localChar:FindFirstChildOfClass("Humanoid").AutoRotate = false

            if getgenv().MimicMoves then
                -- Mimic mode
                part.CFrame = part.CFrame:Lerp(targetPart.CFrame, getgenv().HowFastDanSchneiderCatchesYou)
                local humanoid = localChar:FindFirstChildOfClass("Humanoid")
                if humanoid and targetChar:FindFirstChildOfClass("Humanoid") then
                    humanoid:Move(Vector3.new(), true)
                    if targetChar:FindFirstChildOfClass("Humanoid").Jump then
                        humanoid.Jump = true
                    end
                end
            else
                -- Follow mode
                part.CFrame = part.CFrame:Lerp(
                    CFrame.new(part.Position, targetPart.Position) * CFrame.Angles(0, math.rad(25), 0),
                    getgenv().HowFastDanSchneiderCatchesYou
                )
                localChar:FindFirstChildOfClass("Humanoid"):MoveTo(targetPart.Position)

                if targetChar:FindFirstChildOfClass("Humanoid").GetState and
                   targetChar:FindFirstChildOfClass("Humanoid"):GetState() == Enum.HumanoidStateType.Freefall then
                    localChar:FindFirstChildOfClass("Humanoid").Jump = true
                end
            end
        end
    else
        if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character:FindFirstChildOfClass("Humanoid").AutoRotate = true
        end
    end
end)

-- Keybinds
local mouse = localPlayer:GetMouse()
mouse.KeyDown:Connect(function(key)
    if key == "x" then
        getgenv().Daddy_Catches_You = not getgenv().Daddy_Catches_You
        notify("Following", getgenv().Daddy_Catches_You and "Enabled" or "Disabled")
        drawPlayerButtons()
    elseif key == "z" then
        getgenv().MimicMoves = not getgenv().MimicMoves
        if getgenv().MimicMoves then
            getgenv().Daddy_Catches_You = true
            notify("Mimic", "Enabled (Follow forced on)")
        else
            notify("Mimic", "Disabled")
        end
        drawPlayerButtons()
    end
end)
