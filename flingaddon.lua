getgenv().HowFastDanSchneiderCatchesYou = 1
getgenv().SelectedPlayer = "Nearest Player"
getgenv().Daddy_Catches_You = false
getgenv().MimicMoves = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

-- Notification wrapper
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 3;
    })
end

-- Load UI lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))()
local w = library:CreateWindow("Player Follower")

local mainFolder
local currentHighlight

-- Highlight handling
local function clearHighlight()
    if currentHighlight and currentHighlight.Parent then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

local function applyHighlight(targetPlayer)
    clearHighlight()
    if targetPlayer and targetPlayer.Character then
        local h = Instance.new("Highlight")
        h.Name = "TargetHighlight"
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.45
        h.Adornee = targetPlayer.Character
        h.Parent = targetPlayer.Character
        currentHighlight = h
    end
end

-- GUI builder
local function buildFolder()
    if mainFolder and mainFolder.Destroy then
        pcall(function() mainFolder:Destroy() end)
    end

    mainFolder = w:CreateFolder("Follow Settings")

    mainFolder:Slider("Follow Speed", {
        min = 0; max = 5; precise = true;
    }, function(value)
        getgenv().HowFastDanSchneiderCatchesYou = value
    end)

    mainFolder:Box("Enter Username", "string", function(value)
        if value == "" then
            notify("Input Error", "Please type a valid username.", 3)
            return
        end
        local found = Players:FindFirstChild(value)
        if found and found ~= localPlayer then
            getgenv().SelectedPlayer = found.Name
            applyHighlight(found)
            notify("Player Selected", "Following " .. found.Name, 2)
            buildFolder()
        else
            notify("Player Not Found", "Could not find player: " .. value, 3)
        end
    end)

    mainFolder:Button(
        (getgenv().SelectedPlayer == "Nearest Player" and "-> " or "") .. "Nearest Player",
        function()
            getgenv().SelectedPlayer = "Nearest Player"
            clearHighlight()
            notify("Player Selected", "Nearest Player", 2)
            buildFolder()
        end
    )

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local isSelected = getgenv().SelectedPlayer == plr.Name
            mainFolder:Button(
                (isSelected and "-> " or "") .. plr.Name,
                function()
                    getgenv().SelectedPlayer = plr.Name
                    applyHighlight(plr)
                    notify("Player Selected", plr.Name, 2)
                    buildFolder()
                end
            )
        end
    end

    mainFolder:Button("Refresh Player List", function()
        buildFolder()
        local selected = getgenv().SelectedPlayer
        if selected ~= "Nearest Player" and Players:FindFirstChild(selected) then
            applyHighlight(Players[selected])
        else
            clearHighlight()
        end
        notify("Player List", "Updated!", 2)
    end)

    mainFolder:Toggle("Enable Following", function(bool)
        getgenv().Daddy_Catches_You = bool
        notify("Following", bool and "Enabled" or "Disabled")
    end)

    mainFolder:Toggle("Mimic Movements", function(bool)
        getgenv().MimicMoves = bool
        if bool then
            getgenv().Daddy_Catches_You = true
            notify("Mimic", "Enabled (Follow forced on)")
        else
            notify("Mimic", "Disabled")
        end
    end)
end

-- First build
buildFolder()

-- Auto-update GUI on join/leave
Players.PlayerAdded:Connect(function()
    task.wait(0.3)
    buildFolder()
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.3)
    buildFolder()
end)

-- Helper functions
local function getNearestPlayer()
    local localChar = localPlayer.Character
    if not (localChar and localChar:FindFirstChild("HumanoidRootPart")) then return nil end
    local myPos = localChar.HumanoidRootPart.Position
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if d < dist then
                closest, dist = p, d
            end
        end
    end
    return closest
end

local function getSelectedPlayer()
    if getgenv().SelectedPlayer == "Nearest Player" then
        local n = getNearestPlayer()
        if n then
            applyHighlight(n)
        else
            clearHighlight()
        end
        return n
    elseif getgenv().SelectedPlayer and Players:FindFirstChild(getgenv().SelectedPlayer) then
        local p = Players[getgenv().SelectedPlayer]
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return p
            end
        end
    end
    clearHighlight()
    return nil
end

-- Main follow logic
RunService.RenderStepped:Connect(function()
    local target = getSelectedPlayer()
    if getgenv().Daddy_Catches_You and target then
        local localChar, targetChar = localPlayer.Character, target.Character
        if localChar and targetChar then
            local part, targetPart = localChar:FindFirstChild("HumanoidRootPart"), targetChar:FindFirstChild("HumanoidRootPart")
            if part and targetPart then
                local hum = localChar:FindFirstChildOfClass("Humanoid")
                if hum then hum.AutoRotate = false end

                if getgenv().MimicMoves then
                    part.CFrame = part.CFrame:Lerp(targetPart.CFrame, getgenv().HowFastDanSchneiderCatchesYou)
                    local thum = targetChar:FindFirstChildOfClass("Humanoid")
                    if thum and thum.Jump then hum.Jump = true end
                else
                    part.CFrame = part.CFrame:Lerp(
                        CFrame.new(part.Position, targetPart.Position),
                        getgenv().HowFastDanSchneiderCatchesYou
                    )
                    hum:MoveTo(targetPart.Position)
                end
            end
        end
    else
        local c = localPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c:FindFirstChildOfClass("Humanoid").AutoRotate = true
        end
    end
end)

-- Keybinds: simplified (no rebuild spam)
local mouse = localPlayer:GetMouse()
mouse.KeyDown:Connect(function(k)
    if k == "x" then
        getgenv().Daddy_Catches_You = not getgenv().Daddy_Catches_You
        notify("Following", getgenv().Daddy_Catches_You and "Enabled" or "Disabled")
    elseif k == "z" then
        getgenv().MimicMoves = not getgenv().MimicMoves
        if getgenv().MimicMoves then
            getgenv().Daddy_Catches_You = true
            notify("Mimic", "Enabled (Follow forced on)")
        else
            notify("Mimic", "Disabled")
        end
    end
end)
