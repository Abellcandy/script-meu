-- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VoiceChatService = game:GetService("VoiceChatService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ANIMAÇÕES ELDER
local ElderAnims = {
    Idle = "rbxassetid://845397899",
    Walk = "rbxassetid://845403856",
    Run = "rbxassetid://845386501",
    Fall = "rbxassetid://845396048",
    Jump = "rbxassetid://845398858",
    Swim = "rbxassetid://845401742",
}

-- VISUAIS
local accentColor = Color3.fromRGB(0, 255, 255)
local bgColor = Color3.fromRGB(20, 22, 26)
local borderColor = Color3.fromRGB(40, 255, 255)
local textColor = Color3.fromRGB(255, 255, 255)
local highlightColor = Color3.fromRGB(0, 180, 255)

-- UI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FuturisticMenu"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 420, 0, 430)
MenuFrame.Position = UDim2.new(0.5, -210, 0.5, -215)
MenuFrame.BackgroundColor3 = bgColor
MenuFrame.BorderColor3 = borderColor
MenuFrame.BorderSizePixel = 2
MenuFrame.BackgroundTransparency = 0.18
MenuFrame.Visible = true
MenuFrame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke", MenuFrame)
UIStroke.Thickness = 2
UIStroke.Color = accentColor
UIStroke.Transparency = 0.3

local UICorner = Instance.new("UICorner", MenuFrame)
UICorner.CornerRadius = UDim.new(0, 18)

-- TopBar (Arrastável)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundTransparency = 0.13
TopBar.BackgroundColor3 = accentColor
TopBar.Parent = MenuFrame
TopBar.Active = true -- Necessário para drag

local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 18)

local Title = Instance.new("TextLabel")
Title.Text = "FUTURISTIC UNIVERSAL MENU"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = textColor
Title.TextSize = 22
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Parent = TopBar

-- Botão de fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -48, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(230, 80, 80)
CloseBtn.TextSize = 26
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    MenuFrame.Visible = false
end)

-- INSTRUÇÕES
local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, -24, 0, 22)
Hint.Position = UDim2.new(0, 12, 0, 46)
Hint.BackgroundTransparency = 1
Hint.Text = "Pressione [B] para abrir/fechar o menu. Menu pode ser arrastado."
Hint.Font = Enum.Font.Gotham
Hint.TextColor3 = highlightColor
Hint.TextSize = 16
Hint.TextXAlignment = Enum.TextXAlignment.Left
Hint.Parent = MenuFrame

-- LAYOUT DE BOTÕES
local MainButtonFrame = Instance.new("Frame")
MainButtonFrame.Size = UDim2.new(0.48, -14, 1, -84)
MainButtonFrame.Position = UDim2.new(0, 12, 0, 76)
MainButtonFrame.BackgroundTransparency = 1
MainButtonFrame.Parent = MenuFrame

local PlayerButtonFrame = Instance.new("Frame")
PlayerButtonFrame.Size = UDim2.new(0.48, -14, 1, -84)
PlayerButtonFrame.Position = UDim2.new(0.52, 0, 0, 76)
PlayerButtonFrame.BackgroundTransparency = 1
PlayerButtonFrame.Parent = MenuFrame

--------------------------
-- BOTÕES DAS FUNÇÕES ----
--------------------------
local function MakeButton(text, parent, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = bgColor
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = accentColor
    btn.TextSize = 18
    btn.AutoButtonColor = false
    btn.Parent = parent

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = accentColor, TextColor3 = bgColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = bgColor, TextColor3 = accentColor}):Play()
    end)

    return btn
end

local FPSBtn     = MakeButton("FPS Boost: OFF", MainButtonFrame, 0)
local ESPBtn     = MakeButton("ESP: OFF [E]", MainButtonFrame, 44)
local NoclipBtn  = MakeButton("NoClip: OFF", MainButtonFrame, 88)
local SpeedBtn   = MakeButton("Speed: OFF", MainButtonFrame, 132)
local ResetBtn   = MakeButton("Reset Character", MainButtonFrame, 176)
local AnimBtn    = MakeButton("Aplicar Animações Elder", MainButtonFrame, 220)

------------------------
-- PLAYER LIST & FUNÇÕES
------------------------
local PlayerListLabel = Instance.new("TextLabel")
PlayerListLabel.Text = "Jogadores:"
PlayerListLabel.Font = Enum.Font.GothamBold
PlayerListLabel.TextColor3 = highlightColor
PlayerListLabel.TextSize = 17
PlayerListLabel.BackgroundTransparency = 1
PlayerListLabel.Size = UDim2.new(1, 0, 0, 26)
PlayerListLabel.Position = UDim2.new(0, 0, 0, 0)
PlayerListLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerListLabel.Parent = PlayerButtonFrame

local PlayerListBox = Instance.new("ScrollingFrame")
PlayerListBox.Size = UDim2.new(1, 0, 1, -50)
PlayerListBox.Position = UDim2.new(0, 0, 0, 30)
PlayerListBox.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListBox.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
PlayerListBox.BackgroundTransparency = 0.2
PlayerListBox.BorderSizePixel = 0
PlayerListBox.ScrollBarThickness = 6
PlayerListBox.Parent = PlayerButtonFrame

local PlayerListLayout = Instance.new("UIListLayout", PlayerListBox)
PlayerListLayout.Padding = UDim.new(0, 3)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local TeleportBtn = MakeButton("Teleportar [T]", PlayerButtonFrame, PlayerButtonFrame.AbsoluteSize.Y - 52)
TeleportBtn.Position = UDim2.new(0, 0, 1, -48)
TeleportBtn.Size = UDim2.new(0.5, -2, 0, 36)
TeleportBtn.TextSize = 17

local ESPPlayerBtn = MakeButton("ESP Player", PlayerButtonFrame, PlayerButtonFrame.AbsoluteSize.Y - 52)
ESPPlayerBtn.Position = UDim2.new(0.5, 2, 1, -48)
ESPPlayerBtn.Size = UDim2.new(0.5, -2, 0, 36)
ESPPlayerBtn.TextSize = 17

------------------------
-- LÓGICA DAS FUNÇÕES ---
------------------------

-- FPS BOOST
local FPSBoostActive = false
FPSBtn.MouseButton1Click:Connect(function()
    FPSBoostActive = not FPSBoostActive
    if FPSBoostActive then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
        FPSBtn.Text = "FPS Boost: ON"
        FPSBtn.TextColor3 = highlightColor
        StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Qualidade gráfica reduzida para máximo FPS!", Duration=2})
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Automatic
        FPSBtn.Text = "FPS Boost: OFF"
        FPSBtn.TextColor3 = accentColor
        StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Qualidade gráfica restaurada.", Duration=2})
    end
end)

-- ESP UNIVERSAL
local ESPActive = false
local espBoxes = {}
function RemoveESP()
    for _, box in ipairs(espBoxes) do
        if box then box:Destroy() end
    end
    espBoxes = {}
end
function DrawESP()
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
ESPBtn.MouseButton1Click:Connect(function()
    ESPActive = not ESPActive
    ESPBtn.Text = ESPActive and "ESP: ON [E]" or "ESP: OFF [E]"
    ESPBtn.TextColor3 = ESPActive and highlightColor or accentColor
    if ESPActive then DrawESP() else RemoveESP() end
end)
Players.PlayerAdded:Connect(function() if ESPActive then DrawESP() end end)
Players.PlayerRemoving:Connect(function() if ESPActive then DrawESP() end end)

-- NOCLIP (atravessa paredes)
local NoclipActive = false
NoclipBtn.MouseButton1Click:Connect(function()
    NoclipActive = not NoclipActive
    NoclipBtn.Text = NoclipActive and "NoClip: ON" or "NoClip: OFF"
    NoclipBtn.TextColor3 = NoclipActive and highlightColor or accentColor
end)
RunService.Stepped:Connect(function()
    if NoclipActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- SPEED
local SpeedActive = false
local NormalWalkSpeed = 16
local FastWalkSpeed = 60
SpeedBtn.MouseButton1Click:Connect(function()
    SpeedActive = not SpeedActive
    SpeedBtn.Text = SpeedActive and "Speed: ON" or "Speed: OFF"
    SpeedBtn.TextColor3 = SpeedActive and highlightColor or accentColor
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = SpeedActive and FastWalkSpeed or NormalWalkSpeed
    end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = SpeedActive and FastWalkSpeed or NormalWalkSpeed
end)

-- RESET CHARACTER
ResetBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
    end
end)

-- ANIMAÇÕES ELDER
local appliedElder = false
local humanoidDescendantAddedConn
AnimBtn.MouseButton1Click:Connect(function()
    appliedElder = not appliedElder
    if appliedElder then
        local function applyElderAnim(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            hum:LoadAnimation(Instance.new("Animation", hum) {AnimationId = ElderAnims.Idle}).Name = "Idle"
            hum:LoadAnimation(Instance.new("Animation", hum) {AnimationId = ElderAnims.Walk}).Name = "Walk"
            hum:LoadAnimation(Instance.new("Animation", hum) {AnimationId = ElderAnims.Run}).Name = "Run"
            hum:LoadAnimation(Instance.new("Animation", hum) {AnimationId = ElderAnims.Fall}).Name = "Fall"
            hum:LoadAnimation(Instance.new("Animation", hum) {AnimationId = ElderAnims.Jump}).Name = "Jump"
            hum:LoadAnimation(Instance.new("Animation", hum) {AnimationId = ElderAnims.Swim}).Name = "Swim"
            StarterGui:SetCore("SendNotification", {Title="Animações", Text="Animações Elder aplicadas!", Duration=2})
        end
        if LocalPlayer.Character then applyElderAnim(LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(applyElderAnim)
    else
        StarterGui:SetCore("SendNotification", {Title="Animações", Text="(Reinicie personagem para remover anims)", Duration=2})
    end
end)

-- PLAYER LIST
local playerButtons = {}
local SelectedPlayer = nil
local function RefreshPlayerList()
    for _, btn in ipairs(playerButtons) do btn:Destroy() end
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

-- TELEPORT & ESP PLAYER
TeleportBtn.MouseButton1Click:Connect(function()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            StarterGui:SetCore("SendNotification", {Title="Teleport", Text="Teleportado para "..SelectedPlayer.Name, Duration=2})
        end
    end
end)
local singleESP = nil
local function RemoveSingleESP()
    if singleESP then singleESP:Destroy() singleESP = nil end
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
        StarterGui:SetCore("SendNotification", {Title="ESP", Text="ESP aplicado em "..SelectedPlayer.Name, Duration=2})
    end
end)
Players.PlayerRemoving:Connect(RemoveSingleESP)

-- ATALHOS DE TECLADO
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.B then
            MenuFrame.Visible = not MenuFrame.Visible
        elseif input.KeyCode == Enum.KeyCode.E then
            ESPBtn:Activate()
        elseif input.KeyCode == Enum.KeyCode.T then
            TeleportBtn:Activate()
        end
    end
end)

-- VOICECHAT AUTOREJOIN
local lastSuspended = 0
VoiceChatService.StateChanged:Connect(function(state)
    if state == Enum.VoiceChatConnectionState.Suspended and tick() - lastSuspended > 2 then
        lastSuspended = tick()
        pcall(function() VoiceChatService:JoinVoice() end)
    end
end)

-- MENU MÓVEL (drag)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MenuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MenuFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Garante que o menu fique sempre na tela ao mover
MenuFrame:GetPropertyChangedSignal("Position"):Connect(function()
    local abs = MenuFrame.AbsolutePosition
    local size = MenuFrame.AbsoluteSize
    local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local minX = 0
    local minY = 0
    local maxX = screenSize.X - size.X
    local maxY = screenSize.Y - size.Y
    if abs.X < minX then
        MenuFrame.Position = UDim2.new(0, minX, MenuFrame.Position.Y.Scale, MenuFrame.Position.Y.Offset)
    elseif abs.X > maxX then
        MenuFrame.Position = UDim2.new(0, maxX, MenuFrame.Position.Y.Scale, MenuFrame.Position.Y.Offset)
    end
    if abs.Y < minY then
        MenuFrame.Position = UDim2.new(MenuFrame.Position.X.Scale, MenuFrame.Position.X.Offset, 0, minY)
    elseif abs.Y > maxY then
        MenuFrame.Position = UDim2.new(MenuFrame.Position.X.Scale, MenuFrame.Position.X.Offset, 0, maxY)
    end
end)

-- Sugestão extra: botão para minimizar o menu (ícone no topo)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -96, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "━"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
MinBtn.TextSize = 26
MinBtn.Parent = TopBar

MinBtn.MouseButton1Click:Connect(function()
    MenuFrame.Visible = false
end)

-- Dica extra: notificação ao abrir/fechar com B
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.B then
        MenuFrame.Visible = not MenuFrame.Visible
        if MenuFrame.Visible then
            StarterGui:SetCore("SendNotification", {Title = "Menu", Text = "Menu aberto (pressione B para fechar)", Duration = 2})
        else
            StarterGui:SetCore("SendNotification", {Title = "Menu", Text = "Menu fechado (pressione B para reabrir)", Duration = 2})
        end
    end
end)
