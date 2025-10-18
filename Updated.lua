if getgenv().ZukaLuaHub then
    pcall(function() getgenv().ZukaLuaHub:Destroy() end)
    getgenv().ZukaLuaHub = nil
end

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Simple notify helper
local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- Create ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "ZukaLuaHub"
screen.ResetOnSpawn = false
screen.Parent = game.CoreGui
getgenv().ZukaLuaHub = screen

-- Helpers: styling & tween
local function makeUICorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end
local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function makeButton(parent, text, size, pos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.Text = text
    makeUICorner(btn, 6)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Color3.fromRGB(65,65,65)}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Color3.fromRGB(45,45,45)}) end)
    btn.MouseButton1Click:Connect(function() pcall(callback, btn) end)
    return btn
end

-- Main window
local MainFrame = Instance.new("Frame", screen)
MainFrame.Size = UDim2.new(0, 740, 0, 420)
MainFrame.Position = UDim2.new(0.5, -370, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BackgroundTransparency = 0.13
MainFrame.BorderSizePixel = 0
makeUICorner(MainFrame, 10)

-- Titlebar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
TitleBar.BackgroundTransparency = 0.16
makeUICorner(TitleBar, 10)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -160, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ZukaTech v13.3.7"
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = makeButton(TitleBar, "Close", UDim2.new(0,70,0,24), UDim2.new(1, -80, 0, 6), function()
    if getgenv().ZukaLuaHub then
        pcall(function() getgenv().ZukaLuaHub:Destroy() end)
        getgenv().ZukaLuaHub = nil
    end
end)
local MinBtn = makeButton(TitleBar, "–", UDim2.new(0,30,0,24), UDim2.new(1, -120, 0, 6), nil)

-- Manual dragging (robust)
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Tabs area + pages
local TabsColumn = Instance.new("Frame", MainFrame)
TabsColumn.Size = UDim2.new(0, 120, 1, -36)
TabsColumn.Position = UDim2.new(0, 0, 0, 36)
TabsColumn.BackgroundColor3 = Color3.fromRGB(28,28,28)
TabsColumn.BackgroundTransparency = 0.18
makeUICorner(TabsColumn, 8)

local PagesArea = Instance.new("Frame", MainFrame)
PagesArea.Size = UDim2.new(1, -120, 1, -36)
PagesArea.Position = UDim2.new(0, 120, 0, 36)
PagesArea.BackgroundTransparency = 1

local pages = {}
local function createPage(name)
    local p = Instance.new("Frame", PagesArea)
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.Visible = false
    pages[name] = p
    return p
end



    local EditorPage = createPage("Editor")
    local CommandsPage = createPage("Commands")
    local SpecialPage = createPage("Special")
    local InfoPage = createPage("Info")
    local AimbotPage = createPage("Aimbot")
    local ExtenderPage = createPage("Extender")

-- Tab helper

local function switchPage(name)
    for k,v in pairs(pages) do v.Visible = (k == name) end
    -- highlight active tab
    for _, child in pairs(TabsColumn:GetChildren()) do
        if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(45,45,45) end
    end
    local tabBtn = TabsColumn:FindFirstChild(name .. "_Tab")
    if tabBtn then tabBtn.BackgroundColor3 = Color3.fromRGB(80,80,80) end
end

local function makeTab(name, y)
    local btn = makeButton(TabsColumn, name, UDim2.new(1, -16, 0, 44), UDim2.new(0, 8, 0, y), function() switchPage(name) end)
    btn.Name = name .. "_Tab"
    return btn
end




    makeTab("Editor", 12)
    makeTab("Commands", 12 + 44 + 6)
    makeTab("Special", 12 + 2 * (44 + 6))
    makeTab("Info", 12 + 3 * (44 + 6))
    makeTab("Aimbot", 12 + 4 * (44 + 6))
    makeTab("Rage Bot", 12 + 5 * (44 + 6))
    makeTab("Zuka Bot", 12 + 6 * (44 + 6))
    switchPage("Editor")
-- ========== Zuka Bot Page ========== 
do
    local ZukaBotPage = createPage("Zuka Bot")
    local page = ZukaBotPage
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(120,200,255)
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.Text = "Zuka Bot (Auto Follow)"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local desc = Instance.new("TextLabel", page)
    desc.Size = UDim2.new(1, -20, 0, 22)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(180,220,255)
    desc.Font = Enum.Font.Code
    desc.TextSize = 15
    desc.Text = "Automatically follows the user 'OverZuka' if they are in the game."
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Center

    local followToggle = Instance.new("TextButton", page)
    followToggle.Size = UDim2.new(0, 160, 0, 32)
    followToggle.Position = UDim2.new(0, 20, 0, 90)
    followToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    followToggle.TextColor3 = Color3.fromRGB(255,255,255)
    followToggle.Font = Enum.Font.Code
    followToggle.TextSize = 16
    followToggle.Text = "Auto Follow: OFF"
    makeUICorner(followToggle, 6)

    -- Teleport button
    local teleportBtn = Instance.new("TextButton", page)
    teleportBtn.Size = UDim2.new(0, 160, 0, 32)
    teleportBtn.Position = UDim2.new(1, -180, 0, 90)
    teleportBtn.AnchorPoint = Vector2.new(0, 0)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
    teleportBtn.TextColor3 = Color3.fromRGB(255,255,255)
    teleportBtn.Font = Enum.Font.Code
    teleportBtn.TextSize = 16
    teleportBtn.Text = "Teleport to OverZuka"
    makeUICorner(teleportBtn, 6)
    teleportBtn.MouseButton1Click:Connect(function()
        local target = Players:FindFirstChild("OverZuka")
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -7.5)
                notify("Zuka Bot", "Teleported to OverZuka!", 2)
            else
                notify("Zuka Bot", "Your character is not loaded!", 2)
            end
        else
            notify("Zuka Bot", "OverZuka is not in the game!", 2)
        end
    end)

    local followEnabled = false
    followToggle.MouseButton1Click:Connect(function()
        followEnabled = not followEnabled
        followToggle.Text = "Auto Follow: " .. (followEnabled and "ON" or "OFF")
    end)

    local followDist = 5.5 -- Increased to keep a comfortable gap
    RunService.RenderStepped:Connect(function()
        if followEnabled then
            local target = Players:FindFirstChild("OverZuka")
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("Humanoid") and myChar.Humanoid.Health > 0 then
                    local targetHRP = target.Character.HumanoidRootPart
                    local myHRP = myChar.HumanoidRootPart
                    local offset = (targetHRP.Position - myHRP.Position)
                    local dist = offset.Magnitude
                    if dist < followDist - 1 then
                        -- Too close, step back
                        myHRP.CFrame = CFrame.new(myHRP.Position - offset.Unit * 0.5, targetHRP.Position)
                    elseif dist > followDist + 1 then
                        -- Too far, move closer
                        local direction = offset.Unit
                        local desiredPos = targetHRP.Position - direction * followDist
                        myHRP.CFrame = CFrame.new(desiredPos, targetHRP.Position)
                    end
                end
            end
        end
    end)
    -- Extra loadstring buttons
    local lsBtn1 = makeButton(page, "Load: Fling V.1", UDim2.new(0,160,0,32), UDim2.new(1, -340, 0, 130), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/miso517/scirpt/refs/heads/main/main.lua"))();
        end)
        if ok then
            notify("Zuka Bot", "Fling V.1 loaded", 2)
        else
            notify("Zuka Bot", "Failed to load: " .. tostring(err), 4)
        end
    end)

    local lsBtn2 = makeButton(page, "Load: Reach", UDim2.new(0,160,0,32), UDim2.new(1, -340, 0, 170), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Anaszaxo555/Y/refs/heads/main/Y"))();
        end)
        if ok then
            notify("Zuka Bot", "Reach Y loaded", 2)
        else
            notify("Zuka Bot", "Failed to load: " .. tostring(err), 4)
        end
    end)

    local lsBtn3 = makeButton(page, "Load: Shit-talking AI", UDim2.new(0,160,0,32), UDim2.new(1, -340, 0, 210), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/theogcheater2020-pixel/luaprojects2/refs/heads/main/chat.lua"))();
        end)
        if ok then
            notify("Zuka Bot", "Best AI loaded", 2)
        else
            notify("Zuka Bot", "Failed to load: " .. tostring(err), 4)
        end
    end)
end

-- ========== Rage Bot Page ========== 
do
    local RageBotPage = createPage("Rage Bot")
    local page = RageBotPage
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,80,80)
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.Text = "Rage Bot (PvP Autofarm)"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local desc = Instance.new("TextLabel", page)
    desc.Size = UDim2.new(1, -20, 0, 22)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(220,180,180)
    desc.Font = Enum.Font.Code
    desc.TextSize = 15
    desc.Text = "Automatically hovers behind and attacks selected players."
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Center

    -- Player list
    local playerListLabel = Instance.new("TextLabel", page)
    playerListLabel.Size = UDim2.new(0, 120, 0, 22)
    playerListLabel.Position = UDim2.new(0, 20, 0, 90)
    playerListLabel.BackgroundTransparency = 1
    playerListLabel.Text = "Player List:"
    playerListLabel.TextColor3 = Color3.fromRGB(255,180,180)
    playerListLabel.Font = Enum.Font.Code
    playerListLabel.TextSize = 15
    playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerListLabel.TextYAlignment = Enum.TextYAlignment.Center

    local playerDropdown = Instance.new("TextButton", page)
    playerDropdown.Size = UDim2.new(0, 180, 0, 28)
    playerDropdown.Position = UDim2.new(0, 140, 0, 90)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    playerDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    playerDropdown.Font = Enum.Font.Code
    playerDropdown.TextSize = 15
    playerDropdown.Text = "Select Player"
    makeUICorner(playerDropdown, 6)

    local selectedPlayer = nil
    local function refreshPlayerList()
        local names = {}
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then table.insert(names, plr.Name) end
        end
        playerDropdown.Text = #names > 0 and ("Select Player: "..names[1]) or "No Players"
        selectedPlayer = #names > 0 and Players:FindFirstChild(names[1]) or nil
        playerDropdown.MouseButton1Click:Connect(function()
            local idx = table.find(names, selectedPlayer and selectedPlayer.Name or "") or 1
            idx = idx + 1; if idx > #names then idx = 1 end
            selectedPlayer = Players:FindFirstChild(names[idx])
            playerDropdown.Text = selectedPlayer and ("Select Player: "..selectedPlayer.Name) or "No Players"
        end)
    end
    refreshPlayerList()
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)

    -- Rage Bot toggles
    local rageToggle = Instance.new("TextButton", page)
    rageToggle.Size = UDim2.new(0, 160, 0, 32)
    rageToggle.Position = UDim2.new(0, 20, 0, 130)
    rageToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    rageToggle.TextColor3 = Color3.fromRGB(255,255,255)
    rageToggle.Font = Enum.Font.Code
    rageToggle.TextSize = 16
    rageToggle.Text = "Rage Bot: OFF"
    makeUICorner(rageToggle, 6)

    local rageEnabled = false
    rageToggle.MouseButton1Click:Connect(function()
        rageEnabled = not rageEnabled
        rageToggle.Text = "Rage Bot: " .. (rageEnabled and "ON" or "OFF")
    end)

    -- Hover distance
    local hoverLabel = Instance.new("TextLabel", page)
    hoverLabel.Size = UDim2.new(0, 120, 0, 22)
    hoverLabel.Position = UDim2.new(0, 20, 0, 170)
    hoverLabel.BackgroundTransparency = 1
    hoverLabel.Text = "Hover Distance:"
    hoverLabel.TextColor3 = Color3.fromRGB(255,180,180)
    hoverLabel.Font = Enum.Font.Code
    hoverLabel.TextSize = 15
    hoverLabel.TextXAlignment = Enum.TextXAlignment.Left
    hoverLabel.TextYAlignment = Enum.TextYAlignment.Center

    local hoverBox = Instance.new("TextBox", page)
    hoverBox.Size = UDim2.new(0, 80, 0, 22)
    hoverBox.Position = UDim2.new(0, 140, 0, 170)
    hoverBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    hoverBox.TextColor3 = Color3.fromRGB(255,255,255)
    hoverBox.Font = Enum.Font.Code
    hoverBox.TextSize = 15
    hoverBox.Text = "6"
    hoverBox.PlaceholderText = "Studs..."
    makeUICorner(hoverBox, 6)
    local hoverDist = 6
    hoverBox.FocusLost:Connect(function()
        local val = tonumber(hoverBox.Text)
        if val and val >= 2 and val <= 20 then
            hoverDist = val
            hoverBox.Text = tostring(hoverDist)
        else
            hoverBox.Text = tostring(hoverDist)
        end
    end)

    -- Auto-cycle UI: cycles through players automatically
    local autoCycleToggle = Instance.new("TextButton", page)
    autoCycleToggle.Size = UDim2.new(0, 180, 0, 28)
    autoCycleToggle.Position = UDim2.new(0, 20, 0, 200)
    autoCycleToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    autoCycleToggle.TextColor3 = Color3.fromRGB(255,255,255)
    autoCycleToggle.Font = Enum.Font.Code
    autoCycleToggle.TextSize = 15
    autoCycleToggle.Text = "Auto Cycle: OFF"
    makeUICorner(autoCycleToggle, 6)

    local ignoreForceToggle = Instance.new("TextButton", page)
    ignoreForceToggle.Size = UDim2.new(0, 240, 0, 28)
    ignoreForceToggle.Position = UDim2.new(0, 220, 0, 200)
    ignoreForceToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    ignoreForceToggle.TextColor3 = Color3.fromRGB(255,255,255)
    ignoreForceToggle.Font = Enum.Font.Code
    ignoreForceToggle.TextSize = 15
    ignoreForceToggle.Text = "Ignore players with spawn force field: OFF"
    makeUICorner(ignoreForceToggle, 6)

    local intervalLabel = Instance.new("TextLabel", page)
    intervalLabel.Size = UDim2.new(0, 120, 0, 22)
    intervalLabel.Position = UDim2.new(0, 20, 0, 236)
    intervalLabel.BackgroundTransparency = 1
    intervalLabel.Text = "Cycle Interval (s):"
    intervalLabel.TextColor3 = Color3.fromRGB(255,180,180)
    intervalLabel.Font = Enum.Font.Code
    intervalLabel.TextSize = 15
    intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
    intervalLabel.TextYAlignment = Enum.TextYAlignment.Center

    local intervalBox = Instance.new("TextBox", page)
    intervalBox.Size = UDim2.new(0, 80, 0, 22)
    intervalBox.Position = UDim2.new(0, 140, 0, 236)
    intervalBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    intervalBox.TextColor3 = Color3.fromRGB(255,255,255)
    intervalBox.Font = Enum.Font.Code
    intervalBox.TextSize = 15
    intervalBox.Text = "4"
    intervalBox.PlaceholderText = "Seconds"
    makeUICorner(intervalBox, 6)

    local autoCycleEnabled = false
    local ignoreSpawnForce = false
    local cycleInterval = 4

    autoCycleToggle.MouseButton1Click:Connect(function()
        autoCycleEnabled = not autoCycleEnabled
        autoCycleToggle.Text = "Auto Cycle: " .. (autoCycleEnabled and "ON" or "OFF")
    end)

    ignoreForceToggle.MouseButton1Click:Connect(function()
        ignoreSpawnForce = not ignoreSpawnForce
        ignoreForceToggle.Text = "Ignore players with spawn force field: " .. (ignoreSpawnForce and "ON" or "OFF")
    end)

    intervalBox.FocusLost:Connect(function()
        local v = tonumber(intervalBox.Text)
        if v and v >= 0.5 and v <= 60 then
            cycleInterval = v
            intervalBox.Text = tostring(cycleInterval)
        else
            intervalBox.Text = tostring(cycleInterval)
        end
    end)

    -- Force-object classes to detect spawn force fields
    local spawnForceClasses = {"BodyVelocity","BodyForce","BodyGyro","BodyAngularVelocity","VectorForce","AlignPosition","AlignOrientation","LinearVelocity","AngularVelocity"}

    local function playerHasSpawnForce(plr)
        if not plr or not plr.Character then return false end
        for _, obj in ipairs(plr.Character:GetDescendants()) do
            if table.find(spawnForceClasses, obj.ClassName) then
                return true
            end
        end
        return false
    end

    -- Cycling state
    local cycleElapsed = 0
    RunService.Heartbeat:Connect(function(dt)
        if not autoCycleEnabled then return end
        cycleElapsed = cycleElapsed + dt
        if cycleElapsed < cycleInterval then return end
        cycleElapsed = 0
        -- build list of valid players
        local players = Players:GetPlayers()
        if #players <= 1 then return end
        -- find index of current selectedPlayer in players list
        local startIdx = 1
        for i, plr in ipairs(players) do
            if selectedPlayer and plr == selectedPlayer then startIdx = i break end
        end
        -- iterate to next valid player
        local found = nil
        local idx = startIdx
        for i = 1, #players - 1 do
            idx = idx + 1
            if idx > #players then idx = 1 end
            local cand = players[idx]
            if cand ~= LocalPlayer then
                if ignoreSpawnForce then
                    if not playerHasSpawnForce(cand) then found = cand break end
                else
                    found = cand break
                end
            end
        end
        if found then
            selectedPlayer = found
            playerDropdown.Text = selectedPlayer and ("Select Player: "..selectedPlayer.Name) or "Select Player"
        end
    end)

    -- Rage Bot logic
    RunService.RenderStepped:Connect(function()
        if rageEnabled and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("Humanoid") and myChar.Humanoid.Health > 0 then
                local targetHRP = selectedPlayer.Character.HumanoidRootPart
                local myHRP = myChar.HumanoidRootPart
                -- Position behind target
                local backVec = -targetHRP.CFrame.LookVector * hoverDist
                myHRP.CFrame = CFrame.new(targetHRP.Position + backVec, targetHRP.Position)
                -- Auto-aim (face target)
                myHRP.CFrame = CFrame.new(myHRP.Position, targetHRP.Position)
                -- Auto-attack (simulate click)
                local tool = myChar:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    pcall(function()
                        tool:Activate()
                    end)
                end
            end
        end
    end)
end
-- ========== Aimbot Page ========== 

do
    local page = AimbotPage
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200,220,255)
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.Text = "Aimbot Settings"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local desc = Instance.new("TextLabel", page)
    desc.Size = UDim2.new(1, -20, 0, 22)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(180,180,200)
    desc.Font = Enum.Font.Code
    desc.TextSize = 15
    desc.Text = "Configure aimbot toggle and aim part."
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Center

    -- Toggle key
    local toggleKeyLabel = Instance.new("TextLabel", page)
    toggleKeyLabel.Size = UDim2.new(0, 120, 0, 22)
    toggleKeyLabel.Position = UDim2.new(0, 20, 0, 90)
    toggleKeyLabel.BackgroundTransparency = 1
    toggleKeyLabel.Text = "Toggle Key:"
    toggleKeyLabel.TextColor3 = Color3.fromRGB(180,220,255)
    toggleKeyLabel.Font = Enum.Font.Code
    toggleKeyLabel.TextSize = 15
    toggleKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleKeyLabel.TextYAlignment = Enum.TextYAlignment.Center

    local toggleKeyBox = Instance.new("TextBox", page)
    toggleKeyBox.Size = UDim2.new(0, 80, 0, 22)
    toggleKeyBox.Position = UDim2.new(0, 140, 0, 90)
    toggleKeyBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggleKeyBox.TextColor3 = Color3.fromRGB(255,255,255)
    toggleKeyBox.Font = Enum.Font.Code
    toggleKeyBox.TextSize = 15
    toggleKeyBox.Text = "MouseButton3"
    toggleKeyBox.PlaceholderText = "Key..."
    makeUICorner(toggleKeyBox, 6)

    -- Part to aim at
    local partLabel = Instance.new("TextLabel", page)
    partLabel.Size = UDim2.new(0, 120, 0, 22)
    partLabel.Position = UDim2.new(0, 20, 0, 130)
    partLabel.BackgroundTransparency = 1
    partLabel.Text = "Aim Part:"
    partLabel.TextColor3 = Color3.fromRGB(180,220,255)
    partLabel.Font = Enum.Font.Code
    partLabel.TextSize = 15
    partLabel.TextXAlignment = Enum.TextXAlignment.Left
    partLabel.TextYAlignment = Enum.TextYAlignment.Center

    local partDropdown = Instance.new("TextButton", page)
    partDropdown.Size = UDim2.new(0, 120, 0, 22)
    partDropdown.Position = UDim2.new(0, 140, 0, 130)
    partDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    partDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    partDropdown.Font = Enum.Font.Code
    partDropdown.TextSize = 15
    partDropdown.Text = "Head"
    makeUICorner(partDropdown, 6)

    local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
    local dropdownOpen = false
    local dropdownFrame

    partDropdown.MouseButton1Click:Connect(function()
        if dropdownOpen then
            if dropdownFrame then dropdownFrame:Destroy() end
            dropdownOpen = false
            return
        end
        dropdownOpen = true
        dropdownFrame = Instance.new("Frame", page)
        dropdownFrame.Size = UDim2.new(0, 120, 0, #parts * 22)
        dropdownFrame.Position = UDim2.new(0, 140, 0, 152)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        dropdownFrame.BorderSizePixel = 0
        makeUICorner(dropdownFrame, 6)
        for i, part in ipairs(parts) do
            local btn = Instance.new("TextButton", dropdownFrame)
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*22)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 15
            btn.Text = part
            btn.AutoButtonColor = true
            makeUICorner(btn, 6)
            btn.MouseButton1Click:Connect(function()
                partDropdown.Text = part
                dropdownFrame:Destroy()
                dropdownOpen = false
            end)
        end
    end)

    -- Status label
    local statusLabel = Instance.new("TextLabel", page)
    statusLabel.Size = UDim2.new(1, -20, 0, 22)
    statusLabel.Position = UDim2.new(0, 10, 0, 180)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(180,220,180)
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 15
    statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Select any block/humanoid by pressing V
    local selectLabel = Instance.new("TextLabel", page)
    selectLabel.Size = UDim2.new(1, -20, 0, 22)
    selectLabel.Position = UDim2.new(0, 10, 0, 210)
    selectLabel.BackgroundTransparency = 1
    selectLabel.TextColor3 = Color3.fromRGB(220,220,180)
    selectLabel.Font = Enum.Font.Code
    selectLabel.TextSize = 15
    selectLabel.Text = "Press V to select any block/humanoid under mouse."
    selectLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectLabel.TextYAlignment = Enum.TextYAlignment.Center

    local selectedTarget = nil
    local selectedPlayerTarget = nil
    local selectedNpcTarget = nil
    local selectedPart = nil -- specific part selected (player/NPC/block)
    local playerTargetEnabled = false

    -- Player list UI
    local playerListLabel = Instance.new("TextLabel", page)
    playerListLabel.Size = UDim2.new(0, 120, 0, 22)
    playerListLabel.Position = UDim2.new(0, 280, 0, 90)
    playerListLabel.BackgroundTransparency = 1
    playerListLabel.Text = "Player List:"
    playerListLabel.TextColor3 = Color3.fromRGB(180,220,255)
    playerListLabel.Font = Enum.Font.Code
    playerListLabel.TextSize = 15
    playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerListLabel.TextYAlignment = Enum.TextYAlignment.Center

    local playerDropdown = Instance.new("TextButton", page)
    playerDropdown.Size = UDim2.new(0, 160, 0, 22)
    playerDropdown.Position = UDim2.new(0, 400, 0, 90)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    playerDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    playerDropdown.Font = Enum.Font.Code
    playerDropdown.TextSize = 15
    playerDropdown.Text = "None"
    makeUICorner(playerDropdown, 6)

    local playerDropdownOpen = false
    local playerDropdownFrame

    local function buildPlayerDropdownFrame()
        if playerDropdownFrame then playerDropdownFrame:Destroy() playerDropdownFrame = nil end
        local playersList = Players:GetPlayers()
        playerDropdownFrame = Instance.new("Frame", page)
        playerDropdownFrame.Size = UDim2.new(0, 160, 0, (#playersList) * 22)
        playerDropdownFrame.Position = UDim2.new(0, 400, 0, 112)
        playerDropdownFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        playerDropdownFrame.BorderSizePixel = 0
        makeUICorner(playerDropdownFrame, 6)
        for i, plr in ipairs(playersList) do
            local btn = Instance.new("TextButton", playerDropdownFrame)
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*22)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 15
            btn.Text = plr.Name
            btn.AutoButtonColor = true
            makeUICorner(btn, 6)
            btn.MouseButton1Click:Connect(function()
                selectedPlayerTarget = plr
                playerDropdown.Text = plr.Name
                if playerDropdownFrame then playerDropdownFrame:Destroy() end
                playerDropdownOpen = false
                if playerTargetEnabled then
                    statusLabel.Text = "Aimbot: Will target " .. plr.Name
                end
                -- show ESP immediately
                showSelectedPlayerESP(plr)
            end)
        end
    end

    -- Toggle to target selected player
    local targetPlayerToggle = Instance.new("TextButton", page)
    targetPlayerToggle.Size = UDim2.new(0, 140, 0, 32)
    targetPlayerToggle.Position = UDim2.new(0, 280, 0, 122)
    targetPlayerToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    targetPlayerToggle.TextColor3 = Color3.fromRGB(255,255,255)
    targetPlayerToggle.Font = Enum.Font.Code
    targetPlayerToggle.TextSize = 15
    targetPlayerToggle.Text = "Target Selected: OFF"
    makeUICorner(targetPlayerToggle, 6)
    targetPlayerToggle.MouseButton1Click:Connect(function()
        playerTargetEnabled = not playerTargetEnabled
        targetPlayerToggle.Text = "Target Selected: " .. (playerTargetEnabled and "ON" or "OFF")
        if not playerTargetEnabled then
            selectedPlayerTarget = nil
            playerDropdown.Text = "None"
        end
    end)

    -- Build dropdown when clicked (auto-refreshing)
    playerDropdown.MouseButton1Click:Connect(function()
        if playerDropdownOpen then
            if playerDropdownFrame then playerDropdownFrame:Destroy() end
            playerDropdownOpen = false
            return
        end
        playerDropdownOpen = true
        buildPlayerDropdownFrame()
    end)

    -- Update list on player join/leave
    Players.PlayerAdded:Connect(function()
        -- if dropdown is open, rebuild to include new player
        if playerDropdownOpen then
            buildPlayerDropdownFrame()
        end
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if selectedPlayerTarget == plr then
            selectedPlayerTarget = nil
            playerDropdown.Text = "None"
            playerTargetEnabled = false
            targetPlayerToggle.Text = "Target Selected: OFF"
            clearSelectedPlayerESP()
        end
        if playerDropdownOpen then
            buildPlayerDropdownFrame()
        end
    end)
    UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.V then
            -- If any selection exists, pressing V clears all selections
            if selectedTarget or selectedPlayerTarget or selectedNpcTarget or selectedPart then
                selectedTarget = nil
                selectedPlayerTarget = nil
                selectedNpcTarget = nil
                selectedPart = nil
                currentTarget = nil
                statusLabel.Text = "Selection cleared."
                clearESP()
                clearSelectedPlayerESP()
                clearSelectedPartESP()
            else
                local mouse = LocalPlayer:GetMouse()
                local target = mouse.Target
                if target then
                    -- find model ancestor
                    local modelAncestor = target.Parent
                    while modelAncestor and not modelAncestor:IsA("Model") do
                        modelAncestor = modelAncestor.Parent
                    end
                    if modelAncestor and modelAncestor:FindFirstChildOfClass("Humanoid") then
                        -- character-like model (could be player or NPC)
                        local partName = partDropdown.Text
                        local chosenPart = modelAncestor:FindFirstChild(partName) or target
                        selectedPart = chosenPart
                        local plr = Players:GetPlayerFromCharacter(modelAncestor)
                        if plr then
                            selectedPlayerTarget = plr
                            playerDropdown.Text = plr.Name
                            statusLabel.Text = "Selected player: " .. plr.Name
                            showSelectedPlayerESP(plr)
                        else
                            selectedNpcTarget = modelAncestor
                            selectedTarget = chosenPart
                            statusLabel.Text = "Selected NPC: " .. (modelAncestor.Name or tostring(modelAncestor))
                            showSelectedPartESP(chosenPart)
                        end
                    else
                        -- arbitrary block/part
                        selectedTarget = target
                        selectedPart = target
                        statusLabel.Text = "Selected: " .. (target.Name or tostring(target))
                        showSelectedPartESP(target)
                    end
                else
                    statusLabel.Text = "No block/humanoid under mouse."
                end
            end
        end
    end)

    -- === Aimbot Logic ===
    local aiming = false
    local currentTarget = nil
    local espBox = nil
    local selectedPlayerEsp = nil
    local selectedPartEsp = nil
    local silentAimEnabled = false

    -- Helper: get closest player to mouse
    local function getClosestPlayer()
        local mouse = LocalPlayer:GetMouse()
        local minDist = math.huge
        local closest = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(partDropdown.Text) then
                local part = plr.Character[partDropdown.Text]
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = plr
                    end
                end
            end
        end
        return closest
    end

    -- Helper: create ESP box
    local function showESP(target)
        if espBox then espBox:Destroy() espBox = nil end
        if not target or not target.Character or not target.Character:FindFirstChild(partDropdown.Text) then return end
        local part = target.Character[partDropdown.Text]
        espBox = Instance.new("BoxHandleAdornment")
        espBox.Name = "AimbotESP"
        espBox.Adornee = part
        espBox.AlwaysOnTop = true
        espBox.ZIndex = 10
        espBox.Size = part.Size or Vector3.new(2,2,1)
        espBox.Color3 = Color3.fromRGB(255, 80, 80)
        espBox.Transparency = 0.4
        espBox.Parent = part
    end

    local function clearESP()
        if espBox then espBox:Destroy() espBox = nil end
    end

    -- Selected-player ESP (persistent highlight for chosen player)
    local function showSelectedPlayerESP(plr)
        if selectedPlayerEsp then selectedPlayerEsp:Destroy() selectedPlayerEsp = nil end
        if not plr or not plr.Character or not plr.Character:FindFirstChild(partDropdown.Text) then return end
        local part = plr.Character[partDropdown.Text]
        selectedPlayerEsp = Instance.new("BoxHandleAdornment")
        selectedPlayerEsp.Name = "SelectedPlayerESP"
        selectedPlayerEsp.Adornee = part
        selectedPlayerEsp.AlwaysOnTop = true
        selectedPlayerEsp.ZIndex = 9
        selectedPlayerEsp.Size = part.Size or Vector3.new(2,2,1)
        selectedPlayerEsp.Color3 = Color3.fromRGB(90, 170, 255)
        selectedPlayerEsp.Transparency = 0.25
        selectedPlayerEsp.Parent = part
    end

    local function clearSelectedPlayerESP()
        if selectedPlayerEsp then selectedPlayerEsp:Destroy() selectedPlayerEsp = nil end
    end

    local function showSelectedPartESP(part)
        if selectedPartEsp then selectedPartEsp:Destroy() selectedPartEsp = nil end
        if not part or not part:IsA("BasePart") then return end
        selectedPartEsp = Instance.new("BoxHandleAdornment")
        selectedPartEsp.Name = "SelectedPartESP"
        selectedPartEsp.Adornee = part
        selectedPartEsp.AlwaysOnTop = true
        selectedPartEsp.ZIndex = 9
        selectedPartEsp.Size = part.Size or Vector3.new(2,2,1)
        selectedPartEsp.Color3 = Color3.fromRGB(90, 200, 140)
        selectedPartEsp.Transparency = 0.28
        selectedPartEsp.Parent = part
    end

    local function clearSelectedPartESP()
        if selectedPartEsp then selectedPartEsp:Destroy() selectedPartEsp = nil end
    end

    -- Listen for toggle key
    UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        local key = toggleKeyBox.Text:upper()
        if key == "MOUSEBUTTON2" then
            if input.UserInputType == Enum.UserInputType.MouseButton3 then
                aiming = true
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode.Name:upper() == key then
                aiming = true
            end
        end
    end)
    UIS.InputEnded:Connect(function(input, processed)
        local key = toggleKeyBox.Text:upper()
        if key == "MOUSEBUTTON2" then
            if input.UserInputType == Enum.UserInputType.MouseButton3 then
                aiming = false
                clearESP()
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode.Name:upper() == key then
                aiming = false
                clearESP()
            end
        end
    end)

    -- Main aimbot loop
    RunService.RenderStepped:Connect(function()
        -- Refresh selected-player ESP if a player is selected
        if selectedPlayerTarget and selectedPlayerTarget.Character and selectedPlayerTarget.Character:FindFirstChild(partDropdown.Text) then
            if not selectedPlayerEsp or selectedPlayerEsp.Adornee ~= selectedPlayerTarget.Character[partDropdown.Text] then
                showSelectedPlayerESP(selectedPlayerTarget)
            else
                local part = selectedPlayerTarget.Character[partDropdown.Text]
                if selectedPlayerEsp and part then
                    selectedPlayerEsp.Size = part.Size or Vector3.new(2,2,1)
                    selectedPlayerEsp.Adornee = part
                end
            end
        else
            clearSelectedPlayerESP()
        end

        -- Refresh selected-part/NPC ESP
        if selectedPart and selectedPart:IsA("BasePart") then
            if not selectedPartEsp or selectedPartEsp.Adornee ~= selectedPart then
                showSelectedPartESP(selectedPart)
            else
                selectedPartEsp.Size = selectedPart.Size or Vector3.new(2,2,1)
                selectedPartEsp.Adornee = selectedPart
            end
        else
            clearSelectedPartESP()
        end

        if aiming then
            local target, part
            if playerTargetEnabled and selectedPlayerTarget and selectedPlayerTarget.Character and selectedPlayerTarget.Character:FindFirstChild(partDropdown.Text) then
                target = selectedPlayerTarget
                part = selectedPlayerTarget.Character[partDropdown.Text]
            elseif selectedTarget then
                -- If selectedTarget is a part in a character, lock to that player
                local parent = selectedTarget.Parent
                if parent and parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                    target = Players:GetPlayerFromCharacter(parent)
                    part = selectedTarget
                else
                    -- Otherwise, lock to the selected part/block
                    target = nil
                    part = selectedTarget
                end
            else
                target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild(partDropdown.Text) then
                    part = target.Character[partDropdown.Text]
                end
            end

            if part then
                if target then currentTarget = target end
                -- ESP
                if target then showESP(target) end
                if silentAimEnabled then
                    getgenv().ZukaSilentAimTarget = part.Position
                else
                    local cam = workspace.CurrentCamera
                    local camPos = cam.CFrame.Position
                    local look = (part.Position - camPos).Unit
                    cam.CFrame = CFrame.new(camPos, part.Position)
                end
                statusLabel.Text = "Aimbot: Targeting " .. (target and target.Name or part.Name)
            else
                clearESP()
                statusLabel.Text = "Aimbot: No target"
            end
        else
            clearESP()
            statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
        end
    end)
    -- Silent Aim toggle
    local silentAimToggle = Instance.new("TextButton", page)
    silentAimToggle.Size = UDim2.new(0, 180, 0, 32)
    silentAimToggle.Position = UDim2.new(0, 45, 0, 250)
    silentAimToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    silentAimToggle.TextColor3 = Color3.fromRGB(255,255,255)
    silentAimToggle.Font = Enum.Font.Code
    silentAimToggle.TextSize = 15
    silentAimToggle.Text = "Silent Aim: OFF"
    makeUICorner(silentAimToggle, 6)
    silentAimToggle.MouseButton1Click:Connect(function()
        silentAimEnabled = not silentAimEnabled
        silentAimToggle.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
    end)

    -- FOV Circle slider
    -- FOV circle UI removed
end

-- IDE-style Editor Page
do
    local editorBack = Instance.new("Frame", EditorPage)
    editorBack.Size = UDim2.new(1, -20, 1, -20)
    editorBack.Position = UDim2.new(0, 10, 0, 10)
    editorBack.BackgroundColor3 = Color3.fromRGB(18,18,22)
    editorBack.BackgroundTransparency = 0.13
    editorBack.BorderSizePixel = 0
    editorBack.ClipsDescendants = true
    makeUICorner(editorBack, 10)

    -- Subtle border
    local border = Instance.new("Frame", editorBack)
    border.Size = UDim2.new(1,0,1,0)
    border.Position = UDim2.new(0,0,0,0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 1
    border.BorderColor3 = Color3.fromRGB(40,40,60)

    -- Line number gutter
    local gutter = Instance.new("TextLabel", editorBack)
    gutter.Size = UDim2.new(0,44,1,-60)
    gutter.Position = UDim2.new(0,0,0,0)
    gutter.BackgroundColor3 = Color3.fromRGB(24,24,32)
    gutter.BackgroundTransparency = 0.08
    gutter.TextColor3 = Color3.fromRGB(120,140,180)
    gutter.Font = Enum.Font.Code
    gutter.TextSize = 14
    gutter.TextXAlignment = Enum.TextXAlignment.Right
    gutter.TextYAlignment = Enum.TextYAlignment.Top
    gutter.Text = "1"
    gutter.ClipsDescendants = true
    makeUICorner(gutter, 6)

    -- Editor shadow/highlight
    local shadow = Instance.new("ImageLabel", editorBack)
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, -4)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217" -- soft shadow asset
    shadow.ImageTransparency = 0.85
    shadow.ZIndex = 0

    local scroller = Instance.new("ScrollingFrame", editorBack)
    scroller.Size = UDim2.new(1, -58, 1, -60)
    scroller.Position = UDim2.new(0, 50, 0, 0)
    scroller.CanvasSize = UDim2.new(0,0,0,0)
    scroller.ScrollBarThickness = 8
    scroller.BackgroundColor3 = Color3.fromRGB(22,22,28)
    scroller.BackgroundTransparency = 0.12
    scroller.BorderSizePixel = 0
    scroller.AutomaticCanvasSize = Enum.AutomaticSize.None
    scroller.ClipsDescendants = true
    makeUICorner(scroller, 7)

    -- Modern scroll bar color
    pcall(function()
        scroller.ScrollBarImageColor3 = Color3.fromRGB(80,120,200)
        scroller.ScrollBarImageTransparency = 0.18
    end)

    local textBox = Instance.new("TextBox", scroller)
    textBox.Size = UDim2.new(1, -16, 0, 0)
    textBox.Position = UDim2.new(0, 8, 0, 8)
    textBox.MultiLine = true
    textBox.ClearTextOnFocus = false
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.Font = Enum.Font.Code
    textBox.TextSize = 15
    textBox.TextColor3 = Color3.fromRGB(235,240,255)
    textBox.Text = "-- Write your Lua here\n"
    textBox.PlaceholderText = "Type or paste Lua code here..."
    textBox.PlaceholderColor3 = Color3.fromRGB(120,130,160)
    textBox.BackgroundColor3 = Color3.fromRGB(16,16,20)
    textBox.BackgroundTransparency = 0.18
    textBox.TextWrapped = false
    textBox.ClipsDescendants = true
    textBox.AutomaticSize = Enum.AutomaticSize.Y
    textBox.TextTruncate = Enum.TextTruncate.None
    makeUICorner(textBox, 7)

    -- Sync gutter scroll with scroller
    scroller.CanvasPosition = Vector2.new(0,0)
    scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        gutter.Position = UDim2.new(0,0,0,-scroller.CanvasPosition.Y)
    end)

    -- Update gutter and canvas size on text change
    local function updateGutterAndCanvas()
        local lines = select(2, textBox.Text:gsub("\n","")) + 1
        local newNumbers = {}
        for i = 1, lines do newNumbers[#newNumbers+1] = tostring(i) end
        gutter.Text = table.concat(newNumbers, "\n")
        textBox.Size = UDim2.new(1, -16, 0, textBox.TextBounds.Y + 16)
        scroller.CanvasSize = UDim2.new(0, 0, 0, textBox.TextBounds.Y + 28)
    end
    textBox:GetPropertyChangedSignal("Text"):Connect(updateGutterAndCanvas)
    textBox:GetPropertyChangedSignal("TextBounds"):Connect(updateGutterAndCanvas)
    updateGutterAndCanvas()

    -- Bottom bar for run/clear/save/load
    local bar = Instance.new("Frame", editorBack)
    bar.Size = UDim2.new(1,0,0,50)
    bar.Position = UDim2.new(0,0,1,-50)
    bar.BackgroundColor3 = Color3.fromRGB(10,10,18)
    bar.BackgroundTransparency = 0.10
    makeUICorner(bar,8)

    makeButton(bar, "Run", UDim2.new(0,120,0,34), UDim2.new(0,10,0,8), function()
        local func, err = loadstring(textBox.Text)
        if func then
            local ok, res = pcall(func)
            if not ok then
                notify("Zuka Hub", "Runtime error: "..tostring(res), 4)
            else
                notify("Zuka Hub", "Executed", 2)
            end
        else
            notify("Zuka Hub", "Compile error: "..tostring(err), 4)
        end
    end)

    makeButton(bar, "Clear", UDim2.new(0,120,0,34), UDim2.new(0,140,0,8), function()
        textBox.Text = ""
        notify("Zuka Hub", "Editor cleared", 2)
    end)

    makeButton(bar, "Save", UDim2.new(0,120,0,34), UDim2.new(0,270,0,8), function()
        if writefile then
            pcall(writefile, "ZukaHubScript.lua", textBox.Text)
            notify("Zuka Hub", "Saved", 2)
        else
            notify("Zuka Hub", "writefile not supported", 3)
        end
    end)

    makeButton(bar, "Load", UDim2.new(0,120,0,34), UDim2.new(0,400,0,8), function()
        if readfile and isfile and isfile("ZukaHubScript.lua") then
            local ok, content = pcall(readfile, "ZukaHubScript.lua")
            if ok and content then
                textBox.Text = content
                notify("Zuka Hub", "Loaded", 2)
            else
                notify("Zuka Hub", "Failed to load", 3)
            end
        else
            notify("Zuka Hub", "No saved file", 3)
        end
    end)
end

-- ========== Info Page ========== 
do
    local page = InfoPage
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200,220,255)
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.Text = "Info"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local profileLabel = Instance.new("TextLabel", page)
    profileLabel.Size = UDim2.new(1, -20, 0, 28)
    profileLabel.Position = UDim2.new(0, 10, 0, 56)
    profileLabel.BackgroundTransparency = 1
    profileLabel.TextColor3 = Color3.fromRGB(180,255,180)
    profileLabel.Font = Enum.Font.Code
    profileLabel.TextSize = 16
    profileLabel.TextXAlignment = Enum.TextXAlignment.Left
    profileLabel.TextYAlignment = Enum.TextYAlignment.Center

    local gameLabel = Instance.new("TextLabel", page)
    gameLabel.Size = UDim2.new(1, -20, 0, 24)
    gameLabel.Position = UDim2.new(0, 10, 0, 90)
    gameLabel.BackgroundTransparency = 1
    gameLabel.TextColor3 = Color3.fromRGB(200,200,200)
    gameLabel.Font = Enum.Font.Code
    gameLabel.TextSize = 15
    gameLabel.TextXAlignment = Enum.TextXAlignment.Left
    gameLabel.TextYAlignment = Enum.TextYAlignment.Center

    local placeLabel = Instance.new("TextLabel", page)
    placeLabel.Size = UDim2.new(1, -20, 0, 24)
    placeLabel.Position = UDim2.new(0, 10, 0, 120)
    placeLabel.BackgroundTransparency = 1
    placeLabel.TextColor3 = Color3.fromRGB(200,200,200)
    placeLabel.Font = Enum.Font.Code
    placeLabel.TextSize = 15
    placeLabel.TextXAlignment = Enum.TextXAlignment.Left
    placeLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Set info
    local userId = tostring(LocalPlayer.UserId)
    local username = LocalPlayer.Name
    local displayName = LocalPlayer.DisplayName or username
    local profileUrl = "https://www.roblox.com/users/" .. userId .. "/profile"
    profileLabel.Text = "Roblox: " .. displayName .. " (" .. username .. ") | UserId: " .. userId .. "  [Profile]" 
    profileLabel.Text = profileLabel.Text .. "\n" .. profileUrl

    local placeId = tostring(game.PlaceId)
    local jobId = tostring(game.JobId)
    local gameUrl = "https://www.roblox.com/games/" .. placeId
    gameLabel.Text = "Game PlaceId: " .. placeId .. "  [Game Link]"
    gameLabel.Text = gameLabel.Text .. "\n" .. gameUrl

    placeLabel.Text = "JobId: " .. jobId
end

-- ========== Commands Page (grid layout) ========== 
do
-- ========== Special Page (Script Hub) ========== 
do
    local page = SpecialPage
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200,220,255)
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.Text = "Script Hub"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local desc = Instance.new("TextLabel", page)
    desc.Size = UDim2.new(1, -20, 0, 22)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(180,180,200)
    desc.Font = Enum.Font.Code
    desc.TextSize = 15
    desc.Text = "Run your favorite scripts."
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Center

    local scripts = {
        {name = "Chat Bypasser", url = "https://raw.githubusercontent.com/shadow62x/catbypass/main/upfix"},
        {name = "Script Searcher", url = "https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/ScriptSearcher"},
    {name = "Auto Click", url = "https://raw.githubusercontent.com/JustEzpi/ROBLOX-Scripts/refs/heads/main/ROBLOX_AutoClicker"},
        {name = "CHedHub V1", url = "https://raw.githubusercontent.com/idcgj36/CHedHub/refs/heads/main/Hub"},
    }

    local function makeScriptButton(parent, text, url, y)
        return makeButton(parent, text, UDim2.new(0, 260, 0, 36), UDim2.new(0, 20, 0, y), function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet(url))();
            end)
            if ok then
                notify("Script Hub", text .. " loaded!", 2)
            else
                notify("Script Hub", "Failed: " .. tostring(err), 4)
            end
        end)
    end

    -- (Removed: script buttons are now only created in scriptPanel below)

    -- Player List Section (side by side with scripts)
    local scriptPanelWidth = 300
    local playerPanelWidth = 260
    local panelTop = 80
    local playerPanelHeight = 180 -- Reduced height for player list
    local scannerPanelHeight = 120 -- Height for tool scanner
    local panelHeight = math.max(44 * #scripts + 36, playerPanelHeight + scannerPanelHeight + 12)

    -- Move script buttons into a frame for layout
    local scriptPanel = Instance.new("Frame", page)
    scriptPanel.Size = UDim2.new(0, scriptPanelWidth, 0, panelHeight)
    scriptPanel.Position = UDim2.new(0, 20, 0, panelTop)
    scriptPanel.BackgroundTransparency = 1
    scriptPanel.BorderSizePixel = 0

    for i, script in ipairs(scripts) do
        makeScriptButton(scriptPanel, script.name, script.url, 8 + (i-1)*44)
    end

    -- Player list panel (reduced height)
    local playerPanel = Instance.new("Frame", page)
    playerPanel.Size = UDim2.new(0, playerPanelWidth, 0, playerPanelHeight)
    playerPanel.Position = UDim2.new(0, 36 + scriptPanelWidth, 0, panelTop)
    playerPanel.BackgroundTransparency = 1
    playerPanel.BorderSizePixel = 0

    local playerListLabel = Instance.new("TextLabel", playerPanel)
    playerListLabel.Size = UDim2.new(0, 120, 0, 22)
    playerListLabel.Position = UDim2.new(0, 0, 0, 0)
    playerListLabel.BackgroundTransparency = 1
    playerListLabel.Text = "Players:"
    playerListLabel.TextColor3 = Color3.fromRGB(180,220,255)
    playerListLabel.Font = Enum.Font.Code
    playerListLabel.TextSize = 16
    playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerListLabel.TextYAlignment = Enum.TextYAlignment.Center

    local refreshBtn = makeButton(playerPanel, "Refresh", UDim2.new(0, 80, 0, 22), UDim2.new(0, 130, 0, 0), function() end)
    refreshBtn.TextSize = 14

    local playerScroller = Instance.new("ScrollingFrame", playerPanel)
    playerScroller.Size = UDim2.new(1, 0, 1, -28)
    playerScroller.Position = UDim2.new(0, 0, 0, 28)
    playerScroller.BackgroundColor3 = Color3.fromRGB(24,24,32)
    playerScroller.BackgroundTransparency = 0.08
    playerScroller.BorderSizePixel = 0
    playerScroller.ScrollBarThickness = 6
    playerScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    playerScroller.CanvasSize = UDim2.new(0,0,0,0)
    playerScroller.ClipsDescendants = true
    makeUICorner(playerScroller, 6)

    local function refreshPlayerList()
        for _, child in ipairs(playerScroller:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
        end
        local y = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            local row = Instance.new("Frame", playerScroller)
            row.Size = UDim2.new(1, -8, 0, 22)
            row.Position = UDim2.new(0, 4, 0, y)
            row.BackgroundTransparency = 1
            row.BorderSizePixel = 0

            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0.6, -4, 1, 0)
            btn.Position = UDim2.new(0, 0, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
            btn.BackgroundTransparency = 0.15
            btn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
            btn.TextColor3 = Color3.fromRGB(220,220,255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.TextYAlignment = Enum.TextYAlignment.Center
            btn.AutoButtonColor = true
            makeUICorner(btn, 5)
            btn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(plr.Name)
                    notify("Player List", "Copied: " .. plr.Name, 2)
                else
                    notify("Player List", "setclipboard not supported", 2)
                end
            end)

            local tpBtn = Instance.new("TextButton", row)
            tpBtn.Size = UDim2.new(0.4, -4, 1, 0)
            tpBtn.Position = UDim2.new(0.6, 4, 0, 0)
            tpBtn.BackgroundColor3 = Color3.fromRGB(60,100,180)
            tpBtn.BackgroundTransparency = 0.08
            tpBtn.Text = "Teleport"
            tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
            tpBtn.Font = Enum.Font.Code
            tpBtn.TextSize = 13
            tpBtn.AutoButtonColor = true
            makeUICorner(tpBtn, 5)
            tpBtn.MouseButton1Click:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    notify("Player List", "Teleported to " .. plr.Name, 2)
                else
                    notify("Player List", "Teleport failed", 2)
                end
            end)
            y = y + 26
        end
        playerScroller.CanvasSize = UDim2.new(0,0,0,math.max(y,80))
    end

    refreshBtn.MouseButton1Click:Connect(refreshPlayerList)
    refreshPlayerList()

    -- === Tool Scanner Section (now under player list) ===
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")

    local scannerPanel = Instance.new("Frame", page)
    scannerPanel.Size = UDim2.new(0, playerPanelWidth, 0, scannerPanelHeight)
    scannerPanel.Position = UDim2.new(0, 36 + scriptPanelWidth, 0, panelTop + playerPanelHeight + 8)
    scannerPanel.BackgroundTransparency = 1
    scannerPanel.BorderSizePixel = 0

    local scannerLabel = Instance.new("TextLabel", scannerPanel)
    scannerLabel.Size = UDim2.new(1, 0, 0, 22)
    scannerLabel.Position = UDim2.new(0, 0, 0, 0)
    scannerLabel.BackgroundTransparency = 1
    scannerLabel.Text = "Tool Scanner:"
    scannerLabel.TextColor3 = Color3.fromRGB(180,220,255)
    scannerLabel.Font = Enum.Font.Code
    scannerLabel.TextSize = 16
    scannerLabel.TextXAlignment = Enum.TextXAlignment.Left
    scannerLabel.TextYAlignment = Enum.TextYAlignment.Center

    local scanBtn = makeButton(scannerPanel, "Scan for Tools", UDim2.new(0, 120, 0, 22), UDim2.new(0, 0, 0, 28), function() end)
    scanBtn.TextSize = 14

    local resultBox = Instance.new("TextLabel", scannerPanel)
    resultBox.Size = UDim2.new(1, -8, 1, -60)
    resultBox.Position = UDim2.new(0, 4, 0, 56)
    resultBox.BackgroundColor3 = Color3.fromRGB(24,24,32)
    resultBox.BackgroundTransparency = 0.08
    resultBox.TextColor3 = Color3.fromRGB(220,220,255)
    resultBox.Font = Enum.Font.Code
    resultBox.TextSize = 14
    resultBox.TextXAlignment = Enum.TextXAlignment.Left
    resultBox.TextYAlignment = Enum.TextYAlignment.Top
    resultBox.Text = "Press scan to list tools."
    resultBox.ClipsDescendants = true
    resultBox.TextWrapped = true
    makeUICorner(resultBox, 6)

    local function scanForTools()
        local found = {}
        for _, container in ipairs({ReplicatedStorage, Workspace}) do
            for _, v in ipairs(container:GetChildren()) do
                if v:IsA("Tool") then
                    table.insert(found, v.Name)
                end
            end
        end
        if #found > 0 then
            resultBox.Text = "Tools found:\n" .. table.concat(found, "\n")
        else
            resultBox.Text = "No tools found in ReplicatedStorage or Workspace."
        end
    end

    scanBtn.MouseButton1Click:Connect(scanForTools)
end
    local page = CommandsPage
    local grid = Instance.new("Frame", page)
    grid.Size = UDim2.new(1, -20, 1, -20)
    grid.Position = UDim2.new(0, 10, 0, 10)
    grid.BackgroundTransparency = 1

    local function colX(i) return 12 + (i-1) * 170 end
    local function rowY(r) return (r-1) * 48 end

    -- State vars + connections
    local noclipOn = false
    local noclipConn = nil

    local flyOn = false
    local flyConn = nil
    local flySpeed = 60

    local speedOn = false
    local defaultWalk = 16
    local walkSpeed = 50

    local infJump = false

    local tpCtrlOn = false

    -- Anti-Fling
    local antiFlingOn = false
    local antiConn = nil
    local velocityThreshold = 120
    local displacementThreshold = 25
    local restoreDelay = 0.06
    local lastSafeCFrame = nil
    local lastSafeTime = tick()
    local restoreCooldown = 0.5
    local killForceClasses = {
        "BodyVelocity","BodyForce","BodyGyro","BodyAngularVelocity",
        "VectorForce","AlignPosition","AlignOrientation","LinearVelocity","AngularVelocity"
    }

    -- Utility: remove force objects from a character (best-effort)
    local function removeForceObjectsFromCharacter(char)
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                for _, child in ipairs(obj:GetChildren()) do
                    if table.find(killForceClasses, child.ClassName) then
                        pcall(function() child:Destroy() end)
                    end
                end
            else
                if table.find(killForceClasses, obj.ClassName) then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end

    local function restoreCharacterToSafe(char)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not lastSafeCFrame then return end
        if (tick() - lastSafeTime) < restoreCooldown then return end
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.CFrame = lastSafeCFrame
            task.wait(restoreDelay)
            if hum then hum.PlatformStand = false end
            removeForceObjectsFromCharacter(char)
        end)
        lastSafeTime = tick()
    end

    local function isVelocitySuspicious(vec)
        return vec.Magnitude >= velocityThreshold
    end
    
    local function isDisplacementSuspicious(oldCF, newCF)
        if not oldCF or not newCF then return false end
        return (oldCF.Position - newCF.Position).Magnitude >= displacementThreshold
    end

    local function startAntiFling()
        if antiConn then pcall(function() antiConn:Disconnect() end) end
        antiConn = RunService.Heartbeat:Connect(function()
            if not antiFlingOn then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

            -- strip force objects frequently
            removeForceObjectsFromCharacter(char)

            -- track safe cframe when stable
            local vel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.new()
            local stable = (vel.Magnitude < (velocityThreshold * 0.25)) and (not hum.PlatformStand) and hum.Health > 0
            if stable then
                lastSafeCFrame = hrp.CFrame
                lastSafeTime = tick()
            end

            if isVelocitySuspicious(vel) then
                pcall(function() hrp.Velocity = Vector3.new(0,0,0) end)
                restoreCharacterToSafe(char)
                removeForceObjectsFromCharacter(char)
            else
                if lastSafeCFrame and isDisplacementSuspicious(lastSafeCFrame, hrp.CFrame) then
                    restoreCharacterToSafe(char)
                end
            end
        end)
    end

    local function stopAntiFling()
        if antiConn then pcall(function() antiConn:Disconnect() end) end
        antiConn = nil
    end

    -- Noclip button
    local noclipBtn = makeButton(grid, "Noclip: Off", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(1)), function(self)
        noclipOn = not noclipOn
        self.Text = "Noclip: "..(noclipOn and "On" or "Off")
        if noclipOn then
            if noclipConn then pcall(function() noclipConn:Disconnect() end) end
            noclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            notify("Zuka Hub", "Noclip enabled", 2)
        else
            if noclipConn then pcall(function() noclipConn:Disconnect() end) end
            noclipConn = nil
            notify("Zuka Hub", "Noclip disabled", 2)
        end
    end)

    -- zombgui button
    local hopBtn = makeButton(grid, "Zombie Game upd3", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(6)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/osukfcdays/zlfucker/refs/heads/main/.luau"))();
        end)
        if ok then
            notify("Zuka Hub", "Addon Started", 2)
        else
            notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
        end
    end)

    -- infintyieldebug button
    local iycmdbypBtn = makeButton(grid, "InfiniteYield UI", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(7)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))();
        end)
        if ok then
            notify("Zuka Hub", "Admin Activated", 2)
        else
            notify("Zuka Hub", "Failed to load IYGui: " .. tostring(err), 4)
        end
    end)

    -- autofarms button
    local hopBtn = makeButton(grid, "Zombie Attack Auto", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(5)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ZZINS077/Zombie-Attack/refs/heads/main/ZZINS%20HUB"))();
        end)
        if ok then
            notify("Zuka Hub", "List Loaded", 2)
        else
            notify("Zuka Hub", "Failed to load list: " .. tostring(err), 4)
        end
    end)

    -- ServerHop button
    local hopBtn = makeButton(grid, "Rejoin Server", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(1)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/ServerHopper.lua"))();
        end)
        if ok then
            notify("Zuka Hub", "Game Loaded", 2)
        else
            notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
        end
    end)

    -- XVC button
    local xvcBtn = makeButton(grid, "XVC Hub", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(8)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/Piw5bqGq"))();
        end)
        if ok then
            notify("Zuka Hub", "Xvc Loaded", 2)
        else
            notify("Zuka Hub", "Failed to load XVC Hub: " .. tostring(err), 4)
        end
    end)

    -- AutoPilot button
    local autopiBtn = makeButton(grid, "Auto Sword Fighter E/R", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(7)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/swordnpc"))();
        end)
        if ok then
            notify("Zuka Hub", "Bot Activated, use e to target and r to toggle.", 2)
        else
            notify("Zuka Hub", "Failed to load Script: " .. tostring(err), 4)
        end
    end)

    -- explorer button
    local anticbyBtn = makeButton(grid, "Admin Commands FE", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(3)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))();
        end)
        if ok then
            notify("Zuka Hub", "Loaded.", 2)
        else
            notify("Zuka Hub", "Failed to Load: " .. tostring(err), 4)
        end
    end)

-- flingnu2 button
local hopBtn = makeButton(grid, "Fling V.2 Kawaii", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(5)), function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hellohellohell012321/KAWAII-FREAKY-FLING/main/kawaii_freaky_fling.lua"))();
    end)
    if ok then
        notify("Zuka Hub", "Gui Started..", 2)
    else
        notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
    end
end)

    -- FbotUI button
    local flnguiBtn = makeButton(grid, "Follow Player UI", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(7)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/flingaddon.lua"))();
        end)
        if ok then
            notify("Zuka Hub", "Follower Gui Loaded", 2)
        else
            notify("Zuka Hub", "Failed to Load" .. tostring(err), 4)
        end
    end)

    -- FlingUI button
    local flnguiBtn = makeButton(grid, "Fling V.1", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(6)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/miso517/scirpt/refs/heads/main/main.lua"))();
        end)
        if ok then
            notify("Zuka Hub", "Fling Gui Loaded", 2)
        else
            notify("Zuka Hub", "Failed to Load" .. tostring(err), 4)
        end
    end)

    -- esp button
    local espBtn = makeButton(grid, "Chams/ESP", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(8)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/esp.lua"))();
        end)
        if ok then
            notify("Zuka Hub", "Esp Loaded", 2)
        else
            notify("Zuka Hub", "Failed to Load" .. tostring(err), 4)
        end
    end)

    -- ChatBypass button
    local chatbypBtn = makeButton(grid, "Bypass Chat UI", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(4)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/shadow62x/catbypass/main/upfix"))();
        end)
        if ok then
            notify("Zuka Hub", "Bypass Activated", 2)
        else
            notify("Zuka Hub", "Failed to load ChatGui: " .. tostring(err), 4)
        end
    end)

    -- Smooth & Upright Fly System (stable, no tilt, no choppiness)
    local flyConn, flyOn = nil, false
    local flySpeed = flySpeed or 3
    local smoothness = 0.15 -- 0.1–0.2 for responsive yet smooth control

    local function setHumanoidState(h, enabled)
        if not h then return end
        if enabled then
            h:ChangeState(Enum.HumanoidStateType.Physics)
            h.PlatformStand = true
        else
            h.PlatformStand = false
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    local flyBtn = makeButton(grid, "Fly: Off", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(2)), function(self)
        flyOn = not flyOn
        self.Text = "Fly: " .. (flyOn and "On" or "Off")

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if flyOn and hrp and humanoid then
            if flyConn then pcall(function() flyConn:Disconnect() end) end
            setHumanoidState(humanoid, true)

            local cam = workspace.CurrentCamera
            local targetVel = Vector3.zero
            local currentVel = Vector3.zero

            flyConn = RunService.RenderStepped:Connect(function(dt)
                if not character or not hrp or not hrp.Parent then return end

                local move = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then move = cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move = cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move = cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move = cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move = Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = Vector3.new(0,1,0) end

                if move.Magnitude > 0 then
                    targetVel = move.Unit * flySpeed * 10
                else
                    targetVel = Vector3.zero
                end

                currentVel = currentVel:Lerp(targetVel, math.clamp(dt / smoothness, 0, 1))
                hrp.AssemblyLinearVelocity = currentVel
                hrp.AssemblyAngularVelocity = Vector3.zero

                -- keep character upright (align with world Y-axis)
                local camCF = cam.CFrame
                local lookDir = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                local uprightCF = CFrame.lookAt(hrp.Position, hrp.Position + lookDir, Vector3.yAxis)
                hrp.CFrame = hrp.CFrame:Lerp(uprightCF, 0.25) -- smooth upright correction
            end)

            notify("Zuka Hub", "Fly enabled", 2)

        else
            if flyConn then pcall(function() flyConn:Disconnect() end) end
            flyConn = nil
            setHumanoidState(humanoid, false)
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            notify("Zuka Hub", "Fly disabled", 2)
        end
    end)

    -- dexex button
    local hopBtn = makeButton(grid, "Super Sword Reach", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(3)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Paul512-max/-Universal-Sword-Script-/refs/heads/main/%F0%9F%93%8C%20Universal%20Sword%20Script%202"))();
        end)
        if ok then
            notify("Zuka Hub", "Gui Started", 2)
        else
            notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
        end
    end)


    -- Superfly button
    local hopBtn = makeButton(grid, "Fly V.2 GUI", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(3)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/FlyR15.lua"))();
        end)
        if ok then
            notify("Zuka Hub", "Gui Started", 2)
        else
            notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
        end
    end)
	
    -- Infinite Jump
    local infBtn = makeButton(grid, "InfJump: Off", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(4)), function(self)
        infJump = not infJump
        self.Text = "InfJump: "..(infJump and "On" or "Off")
        notify("Zuka Hub", "Infinite Jump "..(infJump and "enabled" or "disabled"), 2)
    end)
    UIS.JumpRequest:Connect(function()
        if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    -- Ctrl+Click Teleport (local)
    local tpBtn = makeButton(grid, "Ctrl+Click TP: Off", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(5)), function(self)
        tpCtrlOn = not tpCtrlOn
        self.Text = "Ctrl+Click TP: "..(tpCtrlOn and "On" or "Off")
        notify("Zuka Hub", "Ctrl+Click TP "..(tpCtrlOn and "enabled" or "disabled"), 2)
    end)
    local mouse = LocalPlayer:GetMouse()
    mouse.Button1Down:Connect(function()
        if tpCtrlOn and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
            if not (UIS:GetFocusedTextBox()) then
                local target = mouse.Hit
                if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
                    end)
                end
            end
        end
    end)

    -- Extender button
    local sfreachBtn = makeButton(grid, "Sword Reach", UDim2.new(0,160,0,34), UDim2.new(0, colX(1), 0, rowY(6)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Anaszaxo555/Y/refs/heads/main/Y"))();
        end)
        if ok then
            notify("Zuka Hub", "ReachSF Activated", 2)
        else
            notify("Zuka Hub", "Failed to load SwordReach: " .. tostring(err), 4)
        end
    end)

    -- privateser button
    local hopBtn = makeButton(grid, "Private Server", UDim2.new(0,160,0,34), UDim2.new(0, colX(2), 0, rowY(2)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/veil0x14/LocalScripts/refs/heads/main/pg.lua"))();
        end)
        if ok then
            notify("Zuka Hub", "Server Started", 2)
        else
            notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
        end
    end)

-- aichat button
local chadaiBtn = makeButton(grid, "AI Player Chat", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(2)), function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/Broken.lua"))();
    end)
    if ok then
        notify("Zuka Hub", "Ai will respond if spoken to from other player.", 2)
    else
        notify("Zuka Hub", "Failed to load Chat Bot: " .. tostring(err), 4)
    end
end)

    -- solara button
    local hopBtn = makeButton(grid, "Altair Hub v2", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(8)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://cdn.authguard.org/virtual-file/27d9b9180d7a430b8633c9c55db3b5bf"))();
        end)
        if ok then
            notify("Zuka Hub", "Gui Started..", 2)
        else
            notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
        end
    end)

    -- searchee button
    local hopBtn = makeButton(grid, "Script Search", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(4)), function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/ScriptSearcher"))();
        end)
        if ok then
            notify("Zuka Hub", "Gui Started..", 2)
        else
            notify("Zuka Hub", "Failed to load Addon: " .. tostring(err), 4)
        end
    end)


    -- === Anti-Fling System (refined) ===

    local antiConn
    local antiFlingOn = false
    local lastSafeCFrame = nil
    local lastSafeTime = 0
    local velocityThreshold = velocityThreshold or 150 -- defaults if missing
    local displacementThreshold = displacementThreshold or 30

    -- Utility: remove physics objects that can cause fling
    local function removeForceObjectsFromCharacter(char)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BodyMover") or v:IsA("VectorForce") or v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
                pcall(function() v:Destroy() end)
            end
        end
    end

    -- Utility: velocity check
    local function isVelocitySuspicious(vel)
        return vel.Magnitude > velocityThreshold
    end

    -- Utility: displacement check
    local function isDisplacementSuspicious(lastCFrame, currentCFrame)
        local delta = (lastCFrame.Position - currentCFrame.Position).Magnitude
        return delta > displacementThreshold
    end

    -- Restore character safely
    local function restoreCharacterToSafe(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not lastSafeCFrame then return end
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = lastSafeCFrame
        end)
    end

    -- Start / Stop connections
    local function startAntiFling()
        if antiConn then pcall(function() antiConn:Disconnect() end) end

        antiConn = RunService.Heartbeat:Connect(function()
            if not antiFlingOn then return end
            local char = LocalPlayer.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end

            removeForceObjectsFromCharacter(char)

            local vel = hrp.AssemblyLinearVelocity or Vector3.zero
            local stable = (vel.Magnitude < (velocityThreshold * 0.25)) and (not hum.PlatformStand)

            if stable then
                lastSafeCFrame = hrp.CFrame
                lastSafeTime = tick()
            end

            if isVelocitySuspicious(vel) then
                restoreCharacterToSafe(char)
                removeForceObjectsFromCharacter(char)
            elseif lastSafeCFrame and isDisplacementSuspicious(lastSafeCFrame, hrp.CFrame) then
                restoreCharacterToSafe(char)
            end
        end)
    end

    local function stopAntiFling()
        if antiConn then pcall(function() antiConn:Disconnect() end) end
        antiConn = nil
    end

    -- === Anti-Fling UI ===
    local antiBtn = makeButton(grid, "Anti-Fling: Off", UDim2.new(0,160,0,34), UDim2.new(0, colX(3), 0, rowY(1)), function(self)
        antiFlingOn = not antiFlingOn
        self.Text = "Anti-Fling: " .. (antiFlingOn and "On" or "Off")

        if antiFlingOn then
            startAntiFling()
            notify("Zuka Hub", "Anti-Fling enabled", 2)
        else
            stopAntiFling()
            notify("Zuka Hub", "Anti-Fling disabled", 2)
        end
    end)

    -- === Config Boxes ===
    local velBox = Instance.new("TextBox", grid)
    velBox.Size = UDim2.new(0,80,0,24)
    velBox.Position = UDim2.new(0, colX(4)+10, 0, rowY(1) + 8)
    velBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    velBox.TextColor3 = Color3.fromRGB(255,255,255)
    velBox.Font = Enum.Font.Code
    velBox.TextSize = 14
    velBox.Text = tostring(velocityThreshold)
    makeUICorner(velBox, 6)

    velBox.FocusLost:Connect(function()
        local v = tonumber(velBox.Text)
        if v and v > 0 then
            velocityThreshold = v
            notify("Zuka Hub", "Velocity threshold = " .. v, 2)
        else
            velBox.Text = tostring(velocityThreshold)
        end
    end)

    local disBox = Instance.new("TextBox", grid)
    disBox.Size = UDim2.new(0,80,0,24)
    disBox.Position = UDim2.new(0, colX(4)+10, 0, rowY(1) + 40)
    disBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    disBox.TextColor3 = Color3.fromRGB(255,255,255)
    disBox.Font = Enum.Font.Code
    disBox.TextSize = 14
    disBox.Text = tostring(displacementThreshold)
    makeUICorner(disBox, 6)

    disBox.FocusLost:Connect(function()
        local v = tonumber(disBox.Text)
        if v and v > 0 then
            displacementThreshold = v
            notify("Zuka Hub", "Displacement threshold = " .. v, 2)
        else
            disBox.Text = tostring(displacementThreshold)
        end
    end)

    -- Clean up connections when character spawns
    Players.LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.8)
        if noclipOn then
            -- ensure noclip re-applies for new character
            if noclipConn then pcall(function() noclipConn:Disconnect() end) end
            noclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
        if antiFlingOn then
            removeForceObjectsFromCharacter(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then lastSafeCFrame = hrp.CFrame; lastSafeTime = tick() end
        end
    end)

    -- Clean up on hub close: attempt to restore WalkSpeed and disconnect connections
    local function cleanupAll()
        if noclipConn then pcall(function() noclipConn:Disconnect() end); noclipConn = nil end
        if flyConn then pcall(function() flyConn:Disconnect() end); flyConn = nil end
        if antiConn then pcall(function() antiConn:Disconnect() end); antiConn = nil end
        -- restore walkspeed
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function()
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = defaultWalk
            end)
        end
    end

    -- Attach cleanup to CloseBtn
    CloseBtn.MouseButton1Click:Connect(function()
        cleanupAll()
        if getgenv().ZukaLuaHub then pcall(function() getgenv().ZukaLuaHub:Destroy() end); getgenv().ZukaLuaHub = nil end
    end)
end -- end Commands block

-- Minimize behavior
local minimized = false
local minimizedSize = UDim2.new(0, 320, 0, 36)
local normalSize = UDim2.new(0, 740, 0, 420)

local function animateMinimize(minimize)
    if minimize then
        PagesArea.Visible = false
        TabsColumn.Visible = false
        MinBtn.Text = "+"
        -- Animate only the size, keep position
        TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = minimizedSize
        }):Play()
    else
        PagesArea.Visible = true
        TabsColumn.Visible = true
        MinBtn.Text = "–"
        TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = normalSize
        }):Play()
        -- ensure current page is visible (default Editor)
        switchPage("Editor")
    end
end

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    animateMinimize(minimized)
end)

-- On load, ensure MinBtn is correct
MinBtn.Text = minimized and "+" or "–"


-- Final notification
notify("Zuka Hub", "Loaded — We're So Back.", 3)