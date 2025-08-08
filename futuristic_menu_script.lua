
local CONFIG_DIR = "AFS_Scripts"
local CONFIG_FILE = CONFIG_DIR.."/settings.json"
local HttpService = game:GetService("HttpService")

local function safeWriteFile(fname, data)
    if writefile then
        if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
        writefile(fname, HttpService:JSONEncode(data))
    end
end
local function safeReadFile(fname)
    if readfile and isfile(fname) then
        return HttpService:JSONDecode(readfile(fname))
    end
    return nil
end

local Settings = safeReadFile(CONFIG_FILE) or {
    AutoFarm = false,
    FarmMode = "Closest",
    TargetEnemy = "",
    BossOnly = false,
    AttackDelay = 0.1,
    AllAtOnce = true,
    AutoOpenStar = false,
    SelectedWorld = "",
    SelectedStar = "",
    StarsPerCycle = 1,
    UseLuck = false,
    UseShiny = false,
    AutoSell = {Common = false, Rare = false, Epic = false, Legendary = false, Mythical = false},
    AutoMaxOpen = false,
    AutoSellAfterMax = false,
    NotifySecret = true,
    NotifyDivine = true,
    NotifyShiny = true,
    WebhookURL = "",
    AutoCollect = {Yen = true, Fruits = true, Shards = true},
    AutoClaimRewards = false,
    AntiAFK = true,
    TeleportWorld = "",
}

local function saveSettings() safeWriteFile(CONFIG_FILE, Settings) end

local function notify(msg, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title="AFS", Text=msg, Duration=dur or 3})
    end)
end

local function sendWebhook(url, content)
    if url and url ~= "" and syn and syn.request then
        syn.request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(content)
        })
    end
end

--// GAME SERVICES //--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// GUI LIBRARY //--

local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = UILib.CreateLib("AFS | Universal", "Ocean")
local TabFarm = Window:NewTab("Auto Farm")
local TabStars = Window:NewTab("Stars")
local TabMisc = Window:NewTab("Misc")
local TabSettings = Window:NewTab("Settings")
local FarmSection = TabFarm:NewSection("Auto Farm")
local StarsSection = TabStars:NewSection("Star Opening")
local MaxOpenSection = TabStars:NewSection("Max Open")
local MiscSection = TabMisc:NewSection("Rewards & Drops")
local SettingsSection = TabSettings:NewSection("Configuration")
local ExtrasSection = TabSettings:NewSection("Extras")

--// WORLD/EGG DISCOVERY //--

local function getWorldsAndStars()
    local stars = {}
    local eggs = ReplicatedStorage:FindFirstChild("Eggs") or ReplicatedStorage:FindFirstChild("Stars")
    if not eggs then return stars end
    for _, v in ipairs(eggs:GetChildren()) do
        if v:IsA("Folder") then
            stars[v.Name] = {}
            for _, s in ipairs(v:GetChildren()) do
                if s:IsA("Folder") then
                    table.insert(stars[v.Name], s.Name)
                end
            end
        end
    end
    return stars
end

local WorldsStars = getWorldsAndStars()
local WorldList = {}
for w in pairs(WorldsStars) do table.insert(WorldList, w) end

local function updateStarsDropdown(world)
    return WorldsStars[world] or {}
end

--// ENEMY UTILITY //--

local function getEnemies()
    local out = {}
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return out end
    for _, v in ipairs(enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            table.insert(out, v)
        end
    end
    return out
end

local function getClosestEnemy(bossOnly)
    local minDist, closest = math.huge, nil
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, v in ipairs(getEnemies()) do
        if not bossOnly or v.Name:lower():find("boss") then
            local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < minDist then minDist, closest = dist, v end
        end
    end
    return closest
end

local function getEnemyByName(name, bossOnly)
    for _, v in ipairs(getEnemies()) do
        if v.Name == name and (not bossOnly or v.Name:lower():find("boss")) then
            return v
        end
    end
    return nil
end

--// FIGHTER UTILITY //--

local function getFighters()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("FighterList")
    if not gui then return {} end
    local fighters = {}
    for _, v in ipairs(gui:GetChildren()) do
        if v:IsA("Frame") and v:FindFirstChild("FighterId") then
            table.insert(fighters, v.FighterId.Value)
        end
    end
    return fighters
end

--// FARM LOGIC //--

local IsFarming = false
task.spawn(function()
    while true do
        if Settings.AutoFarm and not IsFarming then
            IsFarming = true
            task.spawn(function()
                local target
                if Settings.FarmMode == "Closest" then
                    target = getClosestEnemy(Settings.BossOnly)
                elseif Settings.FarmMode == "Specific" then
                    target = getEnemyByName(Settings.TargetEnemy, Settings.BossOnly)
                end
                if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    local fighters = getFighters()
                    if Settings.AllAtOnce then
                        for _, id in ipairs(fighters) do
                            ReplicatedStorage.RemoteEvents.AttackEnemy:FireServer(target, id)
                        end
                    else
                        for _, id in ipairs(fighters) do
                            ReplicatedStorage.RemoteEvents.AttackEnemy:FireServer(target, id)
                            task.wait(Settings.AttackDelay)
                        end
                    end
                end
                task.wait(Settings.AttackDelay)
                IsFarming = false
            end)
        end
        task.wait(0.2)
    end
end)

--// AUTO OPEN STAR LOGIC //--

local IsOpeningStar = false
task.spawn(function()
    while true do
        if Settings.AutoOpenStar and not IsOpeningStar then
            IsOpeningStar = true
            task.spawn(function()
                for i = 1, Settings.StarsPerCycle or 1 do
                    ReplicatedStorage.RemoteEvents.OpenEgg:FireServer(Settings.SelectedWorld, Settings.SelectedStar, Settings.UseLuck, Settings.UseShiny)
                    task.wait(0.3)
                end
                if Settings.AutoSell then
                    for rarity, enabled in pairs(Settings.AutoSell) do
                        if enabled then
                            ReplicatedStorage.RemoteEvents.SellRarity:FireServer(rarity)
                        end
                    end
                end
                IsOpeningStar = false
            end)
        end
        task.wait(0.5)
    end
end)

--// AUTO MAX OPEN //--

local IsMaxOpening = false
task.spawn(function()
    while true do
        if Settings.AutoMaxOpen and not IsMaxOpening then
            IsMaxOpening = true
            task.spawn(function()
                local gui = LocalPlayer.PlayerGui:FindFirstChild("MaxOpenCooldown")
                if gui and gui.Text == "Ready" then
                    ReplicatedStorage.RemoteEvents.MaxOpen:FireServer(Settings.SelectedWorld, Settings.SelectedStar)
                    if Settings.AutoSellAfterMax then
                        for rarity, enabled in pairs(Settings.AutoSell) do
                            if enabled then
                                ReplicatedStorage.RemoteEvents.SellRarity:FireServer(rarity)
                            end
                        end
                    end
                    -- Notify on special units (simulate, adapt as needed)
                    for _, v in ipairs(getFighters()) do
                        local fighter = v
                        -- check rarity/shiny (simulate)
                        -- Replace by actual fighter data as needed
                        if Settings.NotifySecret or Settings.NotifyDivine or Settings.NotifyShiny then
                            notify("Special Fighter obtained!")
                            if Settings.WebhookURL and Settings.WebhookURL ~= "" then
                                sendWebhook(Settings.WebhookURL, {content = "Special Fighter obtained!"})
                            end
                        end
                    end
                end
                IsMaxOpening = false
            end)
        end
        task.wait(1)
    end
end)

--// AUTO COLLECT DROPS //--

local function collectDrops(folderName)
    local dropFolders = {
        Yen = "Drops",
        Fruits = "FruitDrops",
        Shards = "ShardDrops"
    }
    local folder = Workspace:FindFirstChild(dropFolders[folderName])
    if folder then
        for _, drop in ipairs(folder:GetChildren()) do
            if drop:IsA("BasePart") then
                drop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end

task.spawn(function()
    while true do
        for k, v in pairs(Settings.AutoCollect) do
            if v then collectDrops(k) end
        end
        task.wait(0.3)
    end
end)

--// AUTO CLAIM REWARDS //--

task.spawn(function()
    while true do
        if Settings.AutoClaimRewards then
            ReplicatedStorage.RemoteEvents.ClaimLoginReward:FireServer()
            ReplicatedStorage.RemoteEvents.ClaimQuestReward:FireServer()
            ReplicatedStorage.RemoteEvents.ClaimChest:FireServer()
        end
        task.wait(8)
    end
end)

--// ANTI AFK //--

if Settings.AntiAFK then
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0),Workspace.CurrentCamera.CFrame)
    end)
end

--// GUI CONFIGURATION //--

FarmSection:NewToggle("Auto Farm", "Automatically farm enemies", function(v)
    Settings.AutoFarm = v saveSettings()
end):Set(Settings.AutoFarm)
FarmSection:NewDropdown("Farm Mode", "Closest or Specific", {"Closest","Specific"}, function(opt)
    Settings.FarmMode = opt saveSettings()
end):Set(Settings.FarmMode)
FarmSection:NewTextBox("Enemy Name", "For Specific mode", function(txt)
    Settings.TargetEnemy = txt saveSettings()
end):Set(Settings.TargetEnemy)
FarmSection:NewToggle("Boss Only", "Farm only Boss enemies", function(v)
    Settings.BossOnly = v saveSettings()
end):Set(Settings.BossOnly)
FarmSection:NewSlider("Attack Delay", "Delay between attacks", 0, 1, Settings.AttackDelay, function(val)
    Settings.AttackDelay = val saveSettings()
end)
FarmSection:NewToggle("All Fighters At Once", "Attack all fighters simultaneously", function(v)
    Settings.AllAtOnce = v saveSettings()
end):Set(Settings.AllAtOnce)

StarsSection:NewToggle("Auto Open Star", "Auto open eggs in world", function(v)
    Settings.AutoOpenStar = v saveSettings()
end):Set(Settings.AutoOpenStar)
StarsSection:NewDropdown("World", "Choose World", WorldList, function(opt)
    Settings.SelectedWorld = opt
    Settings.SelectedStar = ""
    saveSettings()
end):Set(Settings.SelectedWorld)
StarsSection:NewDropdown("Star", "Choose Star", updateStarsDropdown(Settings.SelectedWorld), function(opt)
    Settings.SelectedStar = opt saveSettings()
end):Set(Settings.SelectedStar)
StarsSection:NewSlider("Stars per Cycle", "How many stars to open", 1, 10, Settings.StarsPerCycle, function(val)
    Settings.StarsPerCycle = val saveSettings()
end)
StarsSection:NewToggle("Luck Boost", "Use Luck Boost", function(v)
    Settings.UseLuck = v saveSettings()
end):Set(Settings.UseLuck)
StarsSection:NewToggle("Shiny Boost", "Use Shiny Boost", function(v)
    Settings.UseShiny = v saveSettings()
end):Set(Settings.UseShiny)
StarsSection:NewToggle("Auto Sell Common", "Auto sell Common", function(v)
    Settings.AutoSell.Common = v saveSettings()
end):Set(Settings.AutoSell.Common)
StarsSection:NewToggle("Auto Sell Rare", "Auto sell Rare", function(v)
    Settings.AutoSell.Rare = v saveSettings()
end):Set(Settings.AutoSell.Rare)
StarsSection:NewToggle("Auto Sell Epic", "Auto sell Epic", function(v)
    Settings.AutoSell.Epic = v saveSettings()
end):Set(Settings.AutoSell.Epic)
StarsSection:NewToggle("Auto Sell Legendary", "Auto sell Legendary", function(v)
    Settings.AutoSell.Legendary = v saveSettings()
end):Set(Settings.AutoSell.Legendary)
StarsSection:NewToggle("Auto Sell Mythical", "Auto sell Mythical", function(v)
    Settings.AutoSell.Mythical = v saveSettings()
end):Set(Settings.AutoSell.Mythical)

MaxOpenSection:NewToggle("Auto Max Open", "Auto Max Open eggs", function(v)
    Settings.AutoMaxOpen = v saveSettings()
end):Set(Settings.AutoMaxOpen)
MaxOpenSection:NewToggle("Auto Sell After Max", "Auto sell after max open", function(v)
    Settings.AutoSellAfterMax = v saveSettings()
end):Set(Settings.AutoSellAfterMax)
MaxOpenSection:NewToggle("Notify Secret", "Notify on secret fighter", function(v)
    Settings.NotifySecret = v saveSettings()
end):Set(Settings.NotifySecret)
MaxOpenSection:NewToggle("Notify Divine", "Notify on divine fighter", function(v)
    Settings.NotifyDivine = v saveSettings()
end):Set(Settings.NotifyDivine)
MaxOpenSection:NewToggle("Notify Shiny", "Notify on shiny fighter", function(v)
    Settings.NotifyShiny = v saveSettings()
end):Set(Settings.NotifyShiny)
MaxOpenSection:NewTextBox("Webhook URL", "Discord webhook for logging", function(txt)
    Settings.WebhookURL = txt saveSettings()
end):Set(Settings.WebhookURL)

MiscSection:NewToggle("Auto Collect Yen", "Auto collect Yen drops", function(v)
    Settings.AutoCollect.Yen = v saveSettings()
end):Set(Settings.AutoCollect.Yen)
MiscSection:NewToggle("Auto Collect Fruits", "Auto collect Fruits", function(v)
    Settings.AutoCollect.Fruits = v saveSettings()
end):Set(Settings.AutoCollect.Fruits)
MiscSection:NewToggle("Auto Collect Shards", "Auto collect Shards", function(v)
    Settings.AutoCollect.Shards = v saveSettings()
end):Set(Settings.AutoCollect.Shards)
MiscSection:NewToggle("Auto Claim Rewards", "Auto claim daily rewards/quests", function(v)
    Settings.AutoClaimRewards = v saveSettings()
end):Set(Settings.AutoClaimRewards)

ExtrasSection:NewButton("Save Settings", "Manually save your settings", function() saveSettings() notify("Settings saved!") end)
ExtrasSection:NewToggle("Anti-AFK", "Prevent idle kick", function(v)
    Settings.AntiAFK = v saveSettings()
end):Set(Settings.AntiAFK)

--// GUI KEYBIND (N) TOGGLE //--
local UIS = game:GetService("UserInputService")
local Visible = true
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.N then
        Visible = not Visible
        for _,v in pairs(game.CoreGui:GetChildren()) do
            if v.Name:find("Kavo") then
                v.Enabled = Visible
            end
        end
    end
end)

--// END OF SCRIPT //--
notify("AFS Script Loaded. Press N to toggle GUI.")
