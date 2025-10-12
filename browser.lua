--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Full Source Credit: Catboyy (https://scriptblox.com/u/CatBoyy)
-- This was swifty, and lazily made with AI


local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Function to validate and format URL
local function formatUrl(input)
    input = input:match("^%s*(.-)%s*$")
    if input == "" then
        return nil, "Please enter a URL or search query."
    end
    if input:match("^https?://") then
        return input, nil
    end
    local searchQuery = input:gsub(" ", "+")
    return "https://www.google.com/search?q=" .. searchQuery, nil
end

-- Function to open browser
local function open_browser(url, asJson)
    local info = { presentationStyle = 2, url = tostring(url or ""), title = "Web Browser", visible = true }
    local msg = asJson and HttpService:JSONEncode(info) or (info.title .. "\n" .. info.url)
    GuiService:BroadcastNotification(msg, 20)
end

-- Create GUI
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrowserGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Create Main Frame with Gradient
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 60)  -- Slimmer frame for cleaner look
frame.Position = UDim2.new(0.5, -250, 1, 60)  -- Start off-screen bottom
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
}
uiGradient.Parent = frame

local uiCornerFrame = Instance.new("UICorner")
uiCornerFrame.CornerRadius = UDim.new(0, 12)
uiCornerFrame.Parent = frame

local uiStrokeFrame = Instance.new("UIStroke")
uiStrokeFrame.Thickness = 1
uiStrokeFrame.Color = Color3.fromRGB(40, 40, 40)
uiStrokeFrame.Transparency = 0.7
uiStrokeFrame.Parent = frame

-- Create Subtle Drag Handle (integrated into top edge)
local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(1, 0, 0, 4)  -- Thin handle integrated into frame
dragHandle.Position = UDim2.new(0, 0, 0, 0)
dragHandle.BackgroundTransparency = 1  -- Make it invisible but functional
dragHandle.Parent = frame

-- Add faint grip dots for subtle cue
for i = 1, 5 do
    local gripDot = Instance.new("Frame")
    gripDot.Size = UDim2.new(0, 3, 0, 3)
    gripDot.Position = UDim2.new(0.5, -30 + (i * 12), 0, 1)
    gripDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    gripDot.BorderSizePixel = 0
    gripDot.Parent = dragHandle
end

-- Create TextBox for URL/Search input
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.85, -50, 0, 35)  -- Adjusted height for vertical centering
textBox.Position = UDim2.new(0.05, 0, 0.5, -17.5)  -- Centered vertically
textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)  -- Darker for cleaner look
textBox.BackgroundTransparency = 0.5
textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
textBox.PlaceholderText = "e.g, google.com"
textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 14
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.Text = ""  -- Start empty
textBox.Parent = frame

local uiCornerTextBox = Instance.new("UICorner")
uiCornerTextBox.CornerRadius = UDim.new(0, 8)
uiCornerTextBox.Parent = textBox

local uiStrokeTextBox = Instance.new("UIStroke")
uiStrokeTextBox.Thickness = 1
uiStrokeTextBox.Color = Color3.fromRGB(50, 50, 50)
uiStrokeTextBox.Transparency = 0.3
uiStrokeTextBox.Parent = textBox

-- Hover effect for textbox
local function addHoverEffect(element)
    local originalTransparency = element.BackgroundTransparency
    local originalStrokeColor = uiStrokeTextBox.Color
    
    element.MouseEnter:Connect(function()
        TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.4}):Play()
        uiStrokeTextBox.Color = Color3.fromRGB(70, 70, 70)
    end)
    
    element.MouseLeave:Connect(function()
        TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
        uiStrokeTextBox.Color = originalStrokeColor
    end)
end

addHoverEffect(textBox)

-- Create Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0, 35, 0, 35)
sendButton.Position = UDim2.new(0.9, -10, 0.5, -17.5)  -- Centered vertically
sendButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sendButton.BackgroundTransparency = 0.7
sendButton.Text = "↑"
sendButton.TextColor3 = Color3.fromRGB(200, 200, 200)
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 16
sendButton.Parent = frame

local uiCornerButton = Instance.new("UICorner")
uiCornerButton.CornerRadius = UDim.new(0, 17.5)
uiCornerButton.Parent = sendButton

local uiStrokeButton = Instance.new("UIStroke")
uiStrokeButton.Thickness = 1
uiStrokeButton.Color = Color3.fromRGB(100, 100, 100)
uiStrokeButton.Transparency = 0.4
uiStrokeButton.Parent = sendButton

-- Hover effect for button
local function addButtonHover(element)
    local originalTransparency = element.BackgroundTransparency
    local originalStrokeColor = uiStrokeButton.Color
    
    element.MouseEnter:Connect(function()
        TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6}):Play()
        uiStrokeButton.Color = Color3.fromRGB(150, 150, 150)
    end)
    
    element.MouseLeave:Connect(function()
        TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7}):Play()
        uiStrokeButton.Color = originalStrokeColor
    end)
end

addButtonHover(sendButton)

-- Create Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Text = ""
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-- Opening Animation
local function animateOpen()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local goal = {Position = UDim2.new(0.5, -250, 0.9, -30)}
    TweenService:Create(frame, tweenInfo, goal):Play()
end

animateOpen()

-- Dragging Functionality
local dragging = false
local dragInput
local dragStart
local startPos

dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

dragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Button click event
sendButton.MouseButton1Click:Connect(function()
    local input = textBox.Text
    local url, errorMsg = formatUrl(input)
    
    if errorMsg then
        statusLabel.Text = errorMsg
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(3)
        statusLabel.Text = ""
        return
    end
    
    statusLabel.Text = "Opening " .. input .. "..."
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    open_browser(url, true)
    
    wait(3)
    statusLabel.Text = ""
end)

-- Allow Enter key to submit
textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendButton.MouseButton1Click:Fire()
    end
end)