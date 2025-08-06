--[[
    Futuristic Roblox Menu Script
    Features:
    - Lightweight, modern, and visually appealing UI
    - FPS Boost (performance optimization)
    - ESP (see players through walls)
    - Teleport to selected player
    - Player list selection for ESP/Teleport
    - Press "M" to play Elder animation
    - Auto rejoin Voice Chat if microphone is suspended

    Usage:
    Place this script in LocalScript (StarterPlayerScripts or StarterGui).
    Requires: Roblox LuaU
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VoiceChatService = game:GetService("VoiceChatService")

local LocalPlayer = Players.LocalPlayer

-- UI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FuturisticMenu"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Visual Styles
local accentColor = Color3.fromRGB(0, 255, 255)
local bgColor = Color3.fromRGB(20, 22, 26)
local borderColor = Color3.fromRGB(40, 255, 255)
local textColor = Color3.fromRGB(255, 255, 255)
local highlightColor = Color3.fromRGB(0, 180, 255)

-- Menu Frame
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 380, 0, 340)
MenuFrame.Position = UDim2.new(0.5, -190, 0.5, -170)
MenuFrame.BackgroundColor3 = bgColor
MenuFrame.BorderColor3 = borderColor
MenuFrame.BorderSizePixel = 2
MenuFrame.BackgroundTransparency = 0.25
MenuFrame.Visible = true
MenuFrame.Parent = ScreenGui

-- Fancy border glow
local UIStroke = Instance.new("UIStroke", MenuFrame)
UIStroke.Thickness = 2
UIStroke.Color = accentColor
UIStroke.Transparency = 0.3

local UICorner = Instance.new("UICorner", MenuFrame)
UICorner.CornerRadius = UDim.new(0, 18)

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundTransparency = 0.15
TopBar.BackgroundColor3 = accentColor
TopBar.Parent = MenuFrame

local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 18)

local Title = Instance.new("TextLabel")
Title.Text = "FUTURISTIC MENU"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = textColor
Title.TextSize = 22
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Parent = TopBar

-- FPS BOOST TOGGLE
local FPSBoostBtn = Instance.new("TextButton")
FPSBoostBtn.Size = UDim2.new(1, -40, 0, 36)
FPSBoostBtn.Position = UDim2.new(0, 20, 0, 58)
FPSBoostBtn.BackgroundColor3 = bgColor
FPSBoostBtn.Text = "FPS Boost: OFF"
FPSBoostBtn.Font = Enum.Font.Gotham
FPSBoostBtn.TextColor3 = accentColor
FPSBoostBtn.TextSize = 20
FPSBoostBtn.AutoButtonColor = false
FPSBoostBtn.Parent = MenuFrame

local FPSBoostActive = false

-- ESP TOGGLE
local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(1, -40, 0, 36)
ESPBtn.Position = UDim2.new(0, 20, 0, 104)
ESPBtn.BackgroundColor3 = bgColor
ESPBtn.Text = "ESP: OFF"
ESPBtn.Font = Enum.Font.Gotham
ESPBtn.TextColor3 = accentColor
ESPBtn.TextSize = 20
ESPBtn.AutoButtonColor = false
ESPBtn.Parent = MenuFrame

local ESPActive = false

-- PLAYER LIST
local PlayerListLabel = Instance.new("TextLabel")
PlayerListLabel.Text = "Players:"
PlayerListLabel.Font = Enum.Font.GothamBold
PlayerListLabel.TextColor3 = highlightColor
PlayerListLabel.TextSize = 17
PlayerListLabel.BackgroundTransparency = 1
PlayerListLabel.Size = UDim2.new(1, -40, 0, 26)
PlayerListLabel.Position = UDim2.new(0, 20, 0, 150)
PlayerListLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerListLabel.Parent = MenuFrame

local PlayerListBox = Instance.new("ScrollingFrame")
PlayerListBox.Size = UDim2.new(1, -40, 0, 110)
PlayerListBox.Position = UDim2.new(0, 20, 0, 180)
PlayerListBox.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListBox.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
PlayerListBox.BackgroundTransparency = 0.2
PlayerListBox.BorderSizePixel = 0
PlayerListBox.ScrollBarThickness = 7
PlayerListBox.Parent = MenuFrame

local PlayerListLayout = Instance.new("UIListLayout", PlayerListBox)
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- SELECTED PLAYER
local SelectedPlayer = nil

-- Teleport & ESP buttons
local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Size = UDim2.new(0.5, -24, 0, 36)
TeleportBtn.Position = UDim2.new(0, 20, 1, -46)
TeleportBtn.BackgroundColor3 = bgColor
TeleportBtn.Text = "Teleport"
TeleportBtn.Font = Enum.Font.GothamBold
TeleportBtn.TextColor3 = accentColor
TeleportBtn.TextSize = 18
TeleportBtn.AutoButtonColor = false
TeleportBtn.Parent = MenuFrame

local ESPPlayerBtn = Instance.new("TextButton")
ESPPlayerBtn.Size = UDim2.new(0.5, -24, 0, 36)
ESPPlayerBtn.Position = UDim2.new(0.5, 4, 1, -46)
ESPPlayerBtn.BackgroundColor3 = bgColor
ESPPlayerBtn.Text = "ESP Player"
ESPPlayerBtn.Font = Enum.Font.GothamBold
ESPPlayerBtn.TextColor3 = accentColor
ESPPlayerBtn.TextSize = 18
ESPPlayerBtn.AutoButtonColor = false
ESPPlayerBtn.Parent = MenuFrame

-- Utility: Button effect
local function ButtonEffect(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.23), {BackgroundColor3 = accentColor, TextColor3 = bgColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.23), {BackgroundColor3 = bgColor, TextColor3 = accentColor}):Play()
    end)
end

ButtonEffect(FPSBoostBtn)
ButtonEffect(ESPBtn)
ButtonEffect(TeleportBtn)
ButtonEffect(ESPPlayerBtn)

-- FPS BOOST FUNCTIONALITY
local function ToggleFPSBoost()
    FPSBoostActive = not FPSBoostActive
    if FPSBoostActive then
        -- Lower graphics settings for FPS boost
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
        FPSBoostBtn.Text = "FPS Boost: ON"
        FPSBoostBtn.TextColor3 = highlightColor
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Automatic
        FPSBoostBtn.Text = "FPS Boost: OFF"
        FPSBoostBtn.TextColor3 = accentColor
    end
end

FPSBoostBtn.MouseButton1Click:Connect(ToggleFPSBoost)

-- ESP FUNCTIONALITY
local espBoxes = {}

local function RemoveESP()
    for _, box in ipairs(espBoxes) do
        if box then
            box:Destroy()
        end
    end
    espBoxes = {}
end

local function DrawESP()
    RemoveESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Name = "ESPBox"
            adorn.Adornee = plr.Character.HumanoidRootPart
            adorn.AlwaysOnTop = true
            adorn.ZIndex = 10
            adorn.Size = Vector3.new(4, 7, 2)
            adorn.Color3 = accentColor
            adorn.Transparency = 0.7
            adorn.Parent = plr.Character
            table.insert(espBoxes, adorn)
        end
    end
end

local function ToggleESP()
    ESPActive = not ESPActive
    if ESPActive then
        ESPBtn.Text = "ESP: ON"
        ESPBtn.TextColor3 = highlightColor
        DrawESP()
    else
        ESPBtn.Text = "ESP: OFF"
        ESPBtn.TextColor3 = accentColor
        RemoveESP()
    end
end

ESPBtn.MouseButton1Click:Connect(ToggleESP)

-- Update ESP on players joining/leaving
Players.PlayerAdded:Connect(function()
    if ESPActive then
        DrawESP()
    end
end)
Players.PlayerRemoving:Connect(function()
    if ESPActive then
        DrawESP()
    end
end)

-- PLAYER LIST FUNCTIONALITY
local playerButtons = {}

local function RefreshPlayerList()
    for _, btn in ipairs(playerButtons) do
        btn:Destroy()
    end
    playerButtons = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = bgColor
            btn.Text = plr.Name
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = textColor
            btn.TextSize = 16
            btn.AutoButtonColor = false
            btn.Parent = PlayerListBox

            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = plr
                -- Highlight selection
                for _, b in ipairs(playerButtons) do
                    b.BackgroundColor3 = bgColor
                    b.TextColor3 = textColor
                end
                btn.BackgroundColor3 = accentColor
                btn.TextColor3 = bgColor
            end)

            table.insert(playerButtons, btn)
        end
    end
    PlayerListBox.CanvasSize = UDim2.new(0, 0, 0, #playerButtons * 32)
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
RefreshPlayerList()

-- TELEPORT FUNCTIONALITY
TeleportBtn.MouseButton1Click:Connect(function()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = SelectedPlayer.Character.HumanoidRootPart
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- ESP PLAYER FUNCTIONALITY
local singleESP = nil
local function RemoveSingleESP()
    if singleESP then
        singleESP:Destroy()
        singleESP = nil
    end
end

ESPPlayerBtn.MouseButton1Click:Connect(function()
    RemoveSingleESP()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local adorn = Instance.new("BoxHandleAdornment")
        adorn.Name = "ESPBox"
        adorn.Adornee = SelectedPlayer.Character.HumanoidRootPart
        adorn.AlwaysOnTop = true
        adorn.ZIndex = 20
        adorn.Size = Vector3.new(4, 7, 2)
        adorn.Color3 = highlightColor
        adorn.Transparency = 0.3
        adorn.Parent = SelectedPlayer.Character
        singleESP = adorn
    end
end)

Players.PlayerRemoving:Connect(RemoveSingleESP)

-- ELDER ANIMATION ON "M" KEY
local function playElderAnim()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        -- Replace with Elder animation ID, using a sample public one here
        local elderAnim = Instance.new("Animation")
        elderAnim.AnimationId = "rbxassetid://845396048" -- Example: "Elder" animation
        local track = hum:LoadAnimation(elderAnim)
        track:Play()
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        playElderAnim()
    end
end)

-- VOICE CHAT SUSPENDED HANDLER
local lastSuspended = 0
local function onVoiceStateChanged(state)
    if state == Enum.VoiceChatConnectionState.Suspended then
        -- Avoid spamming
        if tick() - lastSuspended > 2 then
            lastSuspended = tick()
            -- Try to rejoin voice chat
            pcall(function()
                VoiceChatService:JoinVoice()
            end)
        end
    end
end

VoiceChatService.StateChanged:Connect(onVoiceStateChanged)

-- [Optional] Menu Draggable
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MenuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Show/hide menu on B
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.B and not processed then
        MenuFrame.Visible = not MenuFrame.Visible
    end
end)

-- End of script.
