-- AUTOPILOT LocalScript (Studio / personal test game)
-- Place in StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Toggle autopilot: RightControl + P
-- Record/Replay: RightControl + R (record toggle), RightControl + O (replay toggle)
-- Toggle Curious Mode: RightControl + C  (also works with plain 'C' for convenience)

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===== Config =====
local TOGGLE_MOD = Enum.KeyCode.RightControl
local TOGGLE_KEY = Enum.KeyCode.P

local RECORD_KEY = Enum.KeyCode.R
local REPLAY_KEY = Enum.KeyCode.O
local CURIOUS_KEY = Enum.KeyCode.C

local WANDER_RADIUS = 30              -- how far from start point it will wander
local MOVE_COOLDOWN = 0.3            -- small wait between MoveTo waypoints (s)
local IDLE_JUMP_CHANCE = 0.18        -- chance to do a jump/idle each stop
local IDLE_ANIM_CHANCE = 0.15        -- if you add animations, trigger them sometimes
local PATH_AGENT_PARAMS = {
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true,
    AgentMaxSlope = 45
}

-- Curious AI params
local CURIOUS_MODE = false
local CURIOUS_PLAYER_CHANCE = 0.45     -- when picking a target while curious, chance to choose a player
local PLAYER_FOCUS_RADIUS = 40         -- radius to search for nearby players
local LOOK_AROUND_TIME_MIN = 0.6
local LOOK_AROUND_TIME_MAX = 2.0
local PAUSE_BEFORE_MOVE_CHANCE = 0.25   -- chance to pause & "think" before moving
local PLAYER_APPROACH_DISTANCE = 4     -- how close to get to a player when focusing
-- ====================

local active = false
local recording = false
local replaying = false
local disableBindings = {}
local autopilotCo
local recordData = {} -- { {pos = Vector3, t = os.clock()} ... }
local replayIndex = 1

-- ========== UI (simple status) ==========
local function makeGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AUTOPILOT_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 50

    local frame = Instance.new("Frame")
    frame.Name = "Root"
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -8, 0, 8)
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Name = "Status"
    label.Size = UDim2.new(1, -8, 1, -8)
    label.Position = UDim2.new(0, 4, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Text = "AUTOPILOT: OFF"
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.Parent = frame

    screenGui.Parent = player:WaitForChild("PlayerGui")
    return label
end

local statusLabel = makeGui()

-- ========== Anti-AFK (VirtualUser trick) ==========
local function enableAntiAfk()
    player.Idled:Connect(function()
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0,0))
        end)
        -- fallback no-op; keep it quiet
    end)
end

-- ========== Input blocking ==========
local function blockInput(actionName, inputState, inputObject)
    return Enum.ContextActionResult.Sink
end

local function disableMovementKeys()
    local keys = {
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift,
        Enum.UserInputType.Gamepad1 -- extra safety
    }
    for _, k in ipairs(keys) do
        local name = "AUTOPILOT_Block_" .. tostring(k)
        ContextActionService:BindAction(name, blockInput, false, k)
        table.insert(disableBindings, name)
    end
end

local function enableMovementKeys()
    for _, name in ipairs(disableBindings) do
        pcall(function() ContextActionService:UnbindAction(name) end)
    end
    disableBindings = {}
end

-- ========== Pathing & Movement ==========
local function computeAndFollowPath(humanoid, hrp, targetPos)
    local path = PathfindingService:CreatePath(PATH_AGENT_PARAMS)
    path:ComputeAsync(hrp.Position, targetPos)
    if path.Status ~= Enum.PathStatus.Success then
        return false
    end
    local waypoints = path:GetWaypoints()
    for _, wp in ipairs(waypoints) do
        if not active or humanoid.Health <= 0 then return false end
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(wp.Position)
        humanoid.MoveToFinished:Wait()
        wait(MOVE_COOLDOWN)
    end
    return true
end

local function chooseWanderTarget(origin)
    local radius = WANDER_RADIUS
    local x = (math.random() - 0.5) * 2 * radius
    local z = (math.random() - 0.5) * 2 * radius
    local offset = Vector3.new(x, 0, z)
    return origin + offset
end

-- find nearby player (not the local player) within PLAYER_FOCUS_RADIUS, returns character or nil
local function findNearbyPlayerCharacter(origin)
    local best, bestDist = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character and pl.Character.Parent then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - origin).Magnitude
                if d <= PLAYER_FOCUS_RADIUS and d < bestDist then
                    best = pl.Character
                    bestDist = d
                end
            end
        end
    end
    return best
end

local function lookAtTarget(hrp, targetPos)
    if not hrp or not targetPos then return end
    pcall(function()
        local current = hrp.CFrame
        local look = CFrame.lookAt(current.Position, Vector3.new(targetPos.X, current.Position.Y, targetPos.Z))
        hrp.CFrame = look
    end)
end

-- ========== Recording ==========
local function startRecording(character)
    recordData = {}
    recording = true
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local startTime = os.clock()
    local recordConn
    recordConn = RunService.Heartbeat:Connect(function(dt)
        if not recording or not hrp.Parent then
            recordConn:Disconnect()
            return
        end
        table.insert(recordData, {pos = hrp.Position, t = os.clock() - startTime})
    end)
end

local function stopRecording()
    recording = false
end

local function startReplay(character)
    if #recordData < 2 then return end
    replaying = true
    replayIndex = 1
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then replaying = false return end

    local startClock = os.clock()
    while replaying and replayIndex <= #recordData and character.Parent do
        local entry = recordData[replayIndex]
        local nextTime = entry.t
        local toWait = nextTime - (os.clock() - startClock)
        if toWait > 0 then
            wait(toWait)
        end
        humanoid:MoveTo(entry.pos)
        humanoid.MoveToFinished:Wait()
        replayIndex = replayIndex + 1
    end
    replaying = false
end

local function stopReplay()
    replaying = false
end

-- ========== AUTOPILOT Main Loop (with Curious AI) ==========
local function pickCuriousTarget(origin, character)
    -- Decide whether to pursue a player or wander a point
    if math.random() < CURIOUS_PLAYER_CHANCE then
        local nearbyChar = findNearbyPlayerCharacter(origin)
        if nearbyChar then
            local targetHRP = nearbyChar:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                -- approach to a comfortable distance
                local direction = (targetHRP.Position - origin)
                local dist = direction.Magnitude
                local approachPos = targetHRP.Position
                if dist > PLAYER_APPROACH_DISTANCE then
                    local dirUnit = direction.Unit
                    approachPos = targetHRP.Position - dirUnit * PLAYER_APPROACH_DISTANCE
                end
                return approachPos, "player"
            end
        end
    end
    -- fallback to random wander target
    return chooseWanderTarget(origin), "point"
end

local function autopilotLoop(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    local origin = hrp.Position

    while active and character.Parent do
        local target, ttype
        if CURIOUS_MODE then
            target, ttype = pickCuriousTarget(hrp.Position, character)
        else
            target = chooseWanderTarget(origin)
            ttype = "point"
        end

        -- occasional "pause & look" before committing
        if math.random() < PAUSE_BEFORE_MOVE_CHANCE then
            local lookTime = LOOK_AROUND_TIME_MIN + math.random() * (LOOK_AROUND_TIME_MAX - LOOK_AROUND_TIME_MIN)
            -- rotate a bit to look around
            local yaw = (math.random() - 0.5) * math.pi/2
            local success, _ = pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, yaw, 0)
            end)
            wait(lookTime)
        end

        -- make the character look toward the target slightly before moving
        lookAtTarget(hrp, target)

        local success = pcall(computeAndFollowPath, humanoid, hrp, target)
        if not success then
            humanoid:MoveTo(target)
            humanoid.MoveToFinished:Wait()
        end

        -- extra curious behavior: if we just approached a player, pause and "gawk"
        if CURIOUS_MODE and ttype == "player" then
            -- look directly at the player for a short time
            local lookTime = 0.8 + math.random() * 1.6
            -- ensure the player still exists and point at their HRP if so
            local nearby = findNearbyPlayerCharacter(hrp.Position)
            if nearby then
                local otherHRP = nearby:FindFirstChild("HumanoidRootPart")
                if otherHRP then
                    lookAtTarget(hrp, otherHRP.Position)
                end
            end
            -- small chance to emote/jump
            if math.random() < 0.25 then humanoid.Jump = true end
            wait(lookTime)
        else
            -- general idle jump chance
            if math.random() < IDLE_JUMP_CHANCE then
                humanoid.Jump = true
            end
            wait(0.6 + math.random() * 1.8)
        end
    end
end

-- ========== Toggle Handling ==========
local function setStatusText(text)
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = "AUTOPILOT: " .. text
    end
end

local function updateStatus()
    if active then
        if CURIOUS_MODE then
            setStatusText("ON (CURIOUS)")
        else
            setStatusText("ON")
        end
    else
        setStatusText("OFF" .. (CURIOUS_MODE and " (CURIOUS)" or ""))
    end
end

local function startAutopilot()
    if active then return end
    local char = player.Character or player.CharacterAdded:Wait()
    active = true
    disableMovementKeys()
    enableAntiAfk()
    updateStatus()
    autopilotCo = coroutine.create(function()
        autopilotLoop(char)
    end)
    coroutine.resume(autopilotCo)
end

local function stopAutopilot()
    if not active then return end
    active = false
    enableMovementKeys()
    updateStatus()
    -- autopilotLoop will exit naturally
end

local function toggleAutopilot()
    if active then stopAutopilot() else startAutopilot() end
end

local function toggleCuriousMode()
    CURIOUS_MODE = not CURIOUS_MODE
    updateStatus()
end

-- ========== Keybinds ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    -- Keep modifier-based hotkeys for backward compatibility, but allow single-key as well
    local modDown = UserInputService:IsKeyDown(TOGGLE_MOD)

    -- Toggle autopilot
    if (key == TOGGLE_KEY and modDown) or key == TOGGLE_KEY then
        -- prefer RightControl+P if provided, but allow plain P for convenience
        toggleAutopilot()
    elseif (key == RECORD_KEY and modDown) or key == RECORD_KEY then
        if recording then
            stopRecording()
            setStatusText(active and "ON (REC STOPPED)" or "OFF (REC STOPPED)")
        else
            local char = player.Character or player.CharacterAdded:Wait()
            startRecording(char)
            setStatusText(active and "ON (RECORDING)" or "OFF (RECORDING)")
        end
    elseif (key == REPLAY_KEY and modDown) or key == REPLAY_KEY then
        if replaying then
            stopReplay()
            updateStatus()
        else
            local char = player.Character or player.CharacterAdded:Wait()
            if recording then stopRecording() end
            disableMovementKeys()
            setStatusText("REPLAYING")
            coroutine.wrap(function()
                startReplay(char)
                enableMovementKeys()
                updateStatus()
            end)()
        end
    elseif (key == CURIOUS_KEY and modDown) or key == CURIOUS_KEY then
        toggleCuriousMode()
    end
end)

-- ========== Cleanup / respawn handling ==========
player.CharacterAdded:Connect(function(char)
    if active then
        wait(0.8)
        if active then
            autopilotCo = coroutine.create(function() autopilotLoop(char) end)
            coroutine.resume(autopilotCo)
        end
    end
end)

-- initial status
updateStatus()

warn("AUTOPILOT loaded. Toggle with RightControl+P (or plain P). Record: RightControl+R. Replay: RightControl+O. Curious toggle: RightControl+C (or plain C).")
