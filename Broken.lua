local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local LastMsg = nil

-- CONFIG (will be updated by GUI)
_G.GEMINI_API_KEY = "Place Here" -- get your api key here: https://aistudio.google.com/app/api-keys
_G.GEMINI_MAX_DISTANCE = 15 -- Maximum distance to respond to a player
_G.GEMINI_PERSONALITY = "You are a friendly, helpful, and witty assistant for Roblox players." -- Default personality
_G.GEMINI_ENABLED = true

--== Gemini Bot GUI ==--
local gui = Instance.new("ScreenGui")
gui.Name = "GeminiBotGui"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Position = UDim2.new(0.5, -160, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true -- Prevent children from overflowing
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "Gemini Bot Settings"
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(209, 209, 255)
title.TextSize = 18
title.Parent = frame

local onOff = Instance.new("TextButton")
onOff.Text = "Bot ON"
onOff.Size = UDim2.new(0, 120, 0, 36)
onOff.Position = UDim2.new(0, 10, 0, 46)
onOff.BackgroundColor3 = Color3.fromRGB(70, 180, 90)
onOff.Font = Enum.Font.GothamBold
onOff.TextColor3 = Color3.new(1,1,1)
onOff.TextSize = 16
onOff.Parent = frame

local apiLabel = Instance.new("TextLabel")
apiLabel.Text = "API Key:"
apiLabel.Size = UDim2.new(0, 90, 0, 24)
apiLabel.Position = UDim2.new(0, 10, 0, 92)
apiLabel.BackgroundTransparency = 1
apiLabel.TextColor3 = Color3.fromRGB(220,220,220)
apiLabel.Font = Enum.Font.Gotham
apiLabel.TextSize = 14
apiLabel.Parent = frame

local apiBox = Instance.new("TextBox")
apiBox.Text = _G.GEMINI_API_KEY
apiBox.Size = UDim2.new(0, 200, 0, 24)
apiBox.Position = UDim2.new(0, 100, 0, 92)
apiBox.BackgroundColor3 = Color3.fromRGB(60,60,80)
apiBox.TextColor3 = Color3.new(1,1,1)
apiBox.ClearTextOnFocus = false
apiBox.Font = Enum.Font.Code
apiBox.TextSize = 14
apiBox.TextWrapped = true -- Prevent clipping
apiBox.Parent = frame

local distLabel = Instance.new("TextLabel")
distLabel.Text = "Max Distance:"
distLabel.Size = UDim2.new(0, 90, 0, 24)
distLabel.Position = UDim2.new(0, 10, 0, 124)
distLabel.BackgroundTransparency = 1
distLabel.TextColor3 = Color3.fromRGB(220,220,220)
distLabel.Font = Enum.Font.Gotham
distLabel.TextSize = 14
distLabel.Parent = frame

local distBox = Instance.new("TextBox")
distBox.Text = tostring(_G.GEMINI_MAX_DISTANCE)
distBox.Size = UDim2.new(0, 60, 0, 24)
distBox.Position = UDim2.new(0, 100, 0, 124)
distBox.BackgroundColor3 = Color3.fromRGB(60,60,80)
distBox.TextColor3 = Color3.new(1,1,1)
distBox.ClearTextOnFocus = false
distBox.Font = Enum.Font.Code
distBox.TextSize = 14
distBox.TextWrapped = true -- Prevent clipping
distBox.Parent = frame

local persLabel = Instance.new("TextLabel")
persLabel.Text = "Personality:"
persLabel.Size = UDim2.new(0, 90, 0, 24)
persLabel.Position = UDim2.new(0, 10, 0, 156)
persLabel.BackgroundTransparency = 1
persLabel.TextColor3 = Color3.fromRGB(220,220,220)
persLabel.Font = Enum.Font.Gotham
persLabel.TextSize = 14
persLabel.Parent = frame

local persBox = Instance.new("TextBox")
persBox.Text = _G.GEMINI_PERSONALITY
persBox.Size = UDim2.new(0, 260, 0, 48)
persBox.Position = UDim2.new(0, 10, 0, 182)
persBox.BackgroundColor3 = Color3.fromRGB(60,60,80)
persBox.TextColor3 = Color3.new(1,1,1)
persBox.ClearTextOnFocus = false
persBox.Font = Enum.Font.Code
persBox.TextSize = 13
persBox.TextWrapped = true -- Prevent clipping
persBox.MultiLine = true   -- Allow multiline input
persBox.Parent = frame

local info = Instance.new("TextLabel")
info.Text = "Press [F9] to see console errors."
info.Size = UDim2.new(1, 0, 0, 22)
info.Position = UDim2.new(0, 0, 1, -22)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(140,140,255)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.Parent = frame

-- GUI Functionality
onOff.MouseButton1Click:Connect(function()
	_G.GEMINI_ENABLED = not _G.GEMINI_ENABLED
	onOff.Text = _G.GEMINI_ENABLED and "Bot ON" or "Bot OFF"
	onOff.BackgroundColor3 = _G.GEMINI_ENABLED and Color3.fromRGB(70,180,90) or Color3.fromRGB(180,60,60)
end)

apiBox.FocusLost:Connect(function()
	_G.GEMINI_API_KEY = apiBox.Text
end)

distBox.FocusLost:Connect(function()
	local v = tonumber(distBox.Text)
	if v then
		_G.GEMINI_MAX_DISTANCE = v
	else
		distBox.Text = tostring(_G.GEMINI_MAX_DISTANCE)
	end
end)

persBox.FocusLost:Connect(function()
	_G.GEMINI_PERSONALITY = persBox.Text
end)

-- Optional: Keybind to toggle GUI visibility
local uis = game:GetService("UserInputService")
local guiVisible = true
uis.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F4 then
		guiVisible = not guiVisible
		frame.Visible = guiVisible
	end
end)

--== Gemini Bot Core ==--
function Say(text)
	text = text:sub(1, 190)
	coroutine.wrap(function()
		pcall(function()
			TextChatService.TextChannels.RBXGeneral:SendAsync(text)
		end)
	end)()
end

function Gemini(player, message)
	local prompt = _G.GEMINI_PERSONALITY .. "\nPlayer says: " .. message
	local body = HttpService:JSONEncode({
		contents = {{ parts = {{ text = prompt }} }}
	})
	local ok, res = pcall(function()
		return request({
			Url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["X-goog-api-key"] = _G.GEMINI_API_KEY
			},
			Body = body
		})
	end)
	if not ok or not res or not res.Body then return end
	local success, data = pcall(function()
		return HttpService:JSONDecode(res.Body)
	end)
	if success and data and data.candidates and data.candidates[1] and data.candidates[1].content and data.candidates[1].content.parts then
		local text = data.candidates[1].content.parts[1].text
		if text then
			Say("[" .. player.DisplayName .. "]: " .. text:gsub("[\r\n]", " "))
		end
	end
end

TextChatService.OnBubbleAdded = function(msg)
	if not _G.GEMINI_ENABLED then return end

	local src = msg.TextSource
	if not src or not src.UserId then return end

	local plr = Players:GetPlayerByUserId(src.UserId)
	if not plr or plr == LP then return end

	local c1, c2 = LP.Character, plr.Character
	if not c1 or not c2 then return end

	local h1, h2 = c1:FindFirstChild("HumanoidRootPart"), c2:FindFirstChild("HumanoidRootPart")
	if not h1 or not h2 or (h1.Position - h2.Position).Magnitude > _G.GEMINI_MAX_DISTANCE then return end

	local t = msg.Text
	if t:gsub("%s+", "") == "" or t == "#" then return end

	-- Personality change command, e.g. "#personality You are sarcastic and mysterious."
	if t:sub(1,12):lower() == "#personality" then
		local newPersonality = t:sub(14)
		if newPersonality ~= "" then
			_G.GEMINI_PERSONALITY = newPersonality
			Say("Personality updated!")
		end
		return
	end

	local id = plr.UserId .. "|" .. t
	if id == LastMsg then return end
	LastMsg = id

	task.spawn(function()
		Gemini(plr, t)
	end)
end
