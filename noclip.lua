
return function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    
    local player = Players.LocalPlayer
    local noclip = false
    local connection
    
    -- GUI Creation
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local ToggleBtn = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local Credit = Instance.new("TextLabel")
    
    ScreenGui.Parent = game:GetService("CoreGui")
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(68, 0, 102)
    Title.Size = UDim2.new(0, 300, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Noclip GUI v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    
    ToggleBtn.Parent = MainFrame
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(68, 0, 102)
    ToggleBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
    ToggleBtn.Size = UDim2.new(0, 240, 0, 50)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "TOGGLE NOCLIP (N)"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 18
    
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
    StatusLabel.Size = UDim2.new(0, 240, 0, 30)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "Status: OFF"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    StatusLabel.TextSize = 16
    
    Credit.Name = "Credit"
    Credit.Parent = MainFrame
    Credit.Position = UDim2.new(0.1, 0, 0.8, 0)
    Credit.Size = UDim2.new(0, 240, 0, 20)
    Credit.Font = Enum.Font.Gotham
    Credit.Text = "By BR3XALITY | Key: wentr1xy"
    Credit.TextColor3 = Color3.fromRGB(200, 200, 200)
    Credit.TextSize = 12
    
    local function toggleNoclip()
        if noclip then
            noclip = false
            if connection then
                connection:Disconnect()
            end
            StatusLabel.Text = "Status: OFF"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(68, 0, 102)
        else
            noclip = true
            StatusLabel.Text = "Status: ON"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            
            connection = RunService.Stepped:Connect(function()
                if noclip and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
    
    ToggleBtn.MouseButton1Click:Connect(toggleNoclip)
    
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.N then
            toggleNoclip()
        end
    end)
    
    print("✅ Noclip GUI Loaded! Press N to toggle")
end
