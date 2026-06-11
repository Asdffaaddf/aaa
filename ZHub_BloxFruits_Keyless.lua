--[[

    ███████╗███████╗ ██████╗
    ╚══███╔╝██╔════╝██╔════╝
      ███╔╝ █████╗  ██║
     ███╔╝  ██╔══╝  ██║
    ███████╗███████╗╚██████╗
    ╚══════╝╚══════╝ ╚═════╝

    Z HUB - Blox Fruits Script (Keyless)
    Features: Fruit Sniper (Any Server), Auto Farm, Player Mods, and more
    For Delta Executor

--]]

-- ======================== SERVICES ========================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

repeat task.wait() until game:IsLoaded() and Players.LocalPlayer

local plr = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ======================== CONFIG ========================
local Config = {
    -- Fruit Sniper
    FruitSniperEnabled = false,
    FruitSniperAnyServer = true,
    FruitSniperWhitelist = {},
    FruitSniperBlacklist = {"Bomb", "Spike", "Chop", "Spring", "Kilo", "Spin"},
    FruitSniperHopDelay = 3,
    FruitSniperCollectDelay = 0.5,
    FruitSniperNotify = true,
    FruitSniperAutoCollect = true,
    FruitSniperServerHop = true,
    FruitSniperWebhook = "",
    FruitSniperFoundFruits = {},

    -- Auto Farm
    AutoFarmEnabled = false,
    AutoFarmMob = "Bandit [Lv. 5]",
    AutoFarmStyle = "Melee",
    AutoFarmAttackDistance = 50,
    AutoFarmAttackSpeed = 0.3,
    AutoFarmBringMob = true,
    AutoFarmQuest = true,

    -- Player Mods
    InfiniteEnergy = false,
    NoFallDamage = false,
    AntiAFK = true,
    SpeedEnabled = false,
    SpeedValue = 50,
    JumpEnabled = false,
    JumpValue = 100,
    FlyEnabled = false,
    FlySpeed = 80,

    -- Misc
    AutoCollectCoins = false,
    RemoveLava = false,
    ESPPlayers = false,
    ESPFruits = false,
    ServerHop = false,
    Rejoin = false,
}

-- Fruit Value Tiers
local FruitTiers = {
    -- Tier 1 (Common / Low Value)
    ["Bomb"] = 1, ["Spike"] = 1, ["Chop"] = 1, ["Spring"] = 1,
    ["Kilo"] = 1, ["Spin"] = 1, ["Smoke"] = 1, ["Flame"] = 1,
    -- Tier 2 (Uncommon)
    ["Falcon"] = 2, ["Ice"] = 2, ["Sand"] = 2, ["Dark"] = 2,
    ["Diamond"] = 2, ["Light"] = 2, ["Rubber"] = 2, ["Barrier"] = 2,
    -- Tier 3 (Rare)
    ["Magma"] = 3, ["Quake"] = 3, ["Buddha"] = 3, ["Love"] = 3,
    ["Spider"] = 3, ["Sound"] = 3, ["Bird: Falcon"] = 3, ["Rumble"] = 3,
    -- Tier 4 (Legendary)
    ["Pain"] = 4, ["Blizzard"] = 4, ["Portal"] = 4, ["Gravity"] = 4,
    ["Mammoth"] = 4, ["T-Rex"] = 4, ["Leopard"] = 4, ["Spirit"] = 4,
    -- Tier 5 (Mythical)
    ["Control"] = 5, ["Venom"] = 5, ["Dragon"] = 5, ["Shadow"] = 5,
    ["Kitsune"] = 5, ["Tides"] = 5, ["Gas"] = 5,
}

-- All spawn locations for fruits in Blox Fruits
local FruitSpawnLocations = {
    CFrame.new(372, 13, 1878), -- Starter Island
    CFrame.new(-1520, 13, 650), -- Buggy Island
    CFrame.new(-1130, 13, -3860), -- Marine Island
    CFrame.new(-4300, 13, -2100), -- Arlong Park
    CFrame.new(-5000, 13, -3800), -- Skypie
    CFrame.new(-5500, 13, -6000), -- Lava Village
    CFrame.new(-6400, 13, -7000), -- Ice Village
    CFrame.new(-7800, 13, -8500), -- Fountain City
    CFrame.new(-9400, 13, -9000), -- Dressrosa
    CFrame.new(-10000, 13, -10200), -- Green Zone
    CFrame.new(-11500, 13, -11000), -- Zou Island
    CFrame.new(-13500, 13, -12000), -- Whole Cake
    CFrame.new(-15000, 13, -13500), -- Wano
    CFrame.new(-17000, 13, -15000), -- Hydra Island
    CFrame.new(-18000, 13, -16000), -- Great Tree
    CFrame.new(-19000, 13, -17000), -- Floating Turtle
    CFrame.new(-20000, 13, -18000), -- Haunted Castle
    CFrame.new(-21000, 13, -19000), -- Cake Land
    CFrame.new(-22000, 13, -20000), -- Tiki Outpost
    CFrame.new(5100, 13, 400), -- Jungle
    CFrame.new(2800, 13, -3000), -- Pirate Village
    CFrame.new(-1600, 13, 500), -- Shell Town
}

-- ======================== UTILITY FUNCTIONS ========================
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Z Hub",
            Text = text or "",
            Duration = duration or 5
        })
    end)
end

local function GetCharacter()
    local char = plr.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            return char, hrp, hum
        end
    end
    return nil, nil, nil
end

local function TeleportTo(cframe)
    local char, hrp = GetCharacter()
    if char and hrp then
        hrp.CFrame = cframe
    end
end

local function IsAlive()
    local char, hrp, hum = GetCharacter()
    return char ~= nil
end

local function GetClosestPlayer(maxDist)
    local closest, closestDist = nil, maxDist or math.huge
    local char, hrp = GetCharacter()
    if not hrp then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= plr and v.Character then
            local vHrp = v.Character:FindFirstChild("HumanoidRootPart")
            local vHum = v.Character:FindFirstChild("Humanoid")
            if vHrp and vHum and vHum.Health > 0 then
                local dist = (vHrp.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closest = v
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

local function GetMobs()
    local mobs = {}
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Humanoid.Health > 0 then
                table.insert(mobs, v)
            end
        end
    end
    return mobs
end

local function GetClosestMob(name, maxDist)
    local closest, closestDist = nil, maxDist or math.huge
    local char, hrp = GetCharacter()
    if not hrp then return nil end

    for _, v in pairs(GetMobs()) do
        local mobName = v.Name:lower()
        if name == "" or mobName:find(name:lower()) then
            local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < closestDist then
                closest = v
                closestDist = dist
            end
        end
    end
    return closest
end

-- Server Hop Function
local function ServerHop()
    local gameId = game.PlaceId
    local servers = {}
    local req = nil

    pcall(function()
        req = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)

    if req and req.data then
        for _, s in pairs(req.data) do
            if type(s.playing) == "number" and s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, s.id)
            end
        end
    end

    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        pcall(function()
            TeleportService:TeleportToPlaceInstance(gameId, chosen, plr)
        end)
    else
        pcall(function()
            TeleportService:Teleport(gameId)
        end)
    end
end

-- ======================== FRUIT SNIPER SYSTEM ========================
local FruitSniper = {
    Running = false,
    FoundCount = 0,
    LastHop = 0,
    Connection = nil,
    NotifConn = nil,
    ScanConn = nil,
}

function FruitSniper:FindFruitsInWorkspace()
    local fruits = {}
    -- Scan for fruit objects in workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") or obj:IsA("Part") or obj:IsA("Model") then
            local name = obj.Name:lower()
            -- Check if it's a devil fruit
            if name:find("fruit") or name:find("devil") then
                local fruitName = obj.Name
                local tier = FruitTiers[fruitName] or 0
                local pos = nil

                if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                    pos = obj.Handle.Position
                elseif obj:IsA("Part") then
                    pos = obj.Position
                elseif obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                    pos = obj.HumanoidRootPart.Position
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                end

                if pos then
                    table.insert(fruits, {
                        Name = fruitName,
                        Tier = tier,
                        Position = pos,
                        Object = obj,
                    })
                end
            end
        end
    end

    -- Also scan fruit spawn points
    pcall(function()
        local fruitSpawns = Workspace:FindFirstChild("FruitSpawns")
            or Workspace:FindFirstChild("FruitSpawnLocations")
            or Workspace:FindFirstChild("SpawnedFruits")
        if fruitSpawns then
            for _, v in pairs(fruitSpawns:GetChildren()) do
                local fruitName = v.Name
                local tier = FruitTiers[fruitName] or 0
                local pos = nil
                if v:IsA("Part") then
                    pos = v.Position
                elseif v:FindFirstChild("Handle") then
                    pos = v.Handle.Position
                elseif v:IsA("Model") and v.PrimaryPart then
                    pos = v.PrimaryPart.Position
                end
                if pos then
                    table.insert(fruits, {
                        Name = fruitName,
                        Tier = tier,
                        Position = pos,
                        Object = v,
                    })
                end
            end
        end
    end)

    return fruits
end

function FruitSniper:IsFruitWhitelisted(fruitName)
    -- If whitelist has entries, only allow those
    if #Config.FruitSniperWhitelist > 0 then
        for _, v in pairs(Config.FruitSniperWhitelist) do
            if fruitName:lower():find(v:lower()) then
                return true
            end
        end
        return false
    end

    -- Check blacklist
    for _, v in pairs(Config.FruitSniperBlacklist) do
        if fruitName:lower():find(v:lower()) then
            return false
        end
    end

    return true
end

function FruitSniper:CollectFruit(fruit)
    local char, hrp = GetCharacter()
    if not hrp then return false end

    -- Teleport to fruit
    local fruitCFrame
    if type(fruit.Position) == "userdata" and fruit.Position.X then
        fruitCFrame = CFrame.new(fruit.Position + Vector3.new(0, 3, 0))
    else
        return false
    end

    TeleportTo(fruitCFrame)
    task.wait(Config.FruitSniperCollectDelay)

    -- Try to collect
    pcall(function()
        if fruit.Object and fruit.Object:IsA("Tool") then
            -- Walk near and collect
            local handle = fruit.Object:FindFirstChild("Handle")
            if handle then
                hrp.CFrame = CFrame.new(handle.Position + Vector3.new(0, 2, 0))
                task.wait(0.2)
                -- Simulate touch
                firetouchinterest(hrp, handle, 0)
                task.wait(0.1)
                firetouchinterest(hrp, handle, 1)
            end
        elseif fruit.Object then
            -- Try to touch the part
            if fruit.Object:IsA("Part") or fruit.Object:IsA("BasePart") then
                hrp.CFrame = CFrame.new(fruit.Object.Position + Vector3.new(0, 2, 0))
                task.wait(0.2)
                firetouchinterest(hrp, fruit.Object, 0)
                task.wait(0.1)
                firetouchinterest(hrp, fruit.Object, 1)
            elseif fruit.Object:FindFirstChild("Handle") then
                hrp.CFrame = CFrame.new(fruit.Object.Handle.Position + Vector3.new(0, 2, 0))
                task.wait(0.2)
                firetouchinterest(hrp, fruit.Object.Handle, 0)
                task.wait(0.1)
                firetouchinterest(hrp, fruit.Object.Handle, 1)
            end
        end
    end)

    return true
end

function FruitSniper:ScanAndCollect()
    local fruits = self:FindFruitsInWorkspace()

    for _, fruit in pairs(fruits) do
        if self:IsFruitWhitelisted(fruit.Name) then
            local tierStr = fruit.Tier > 0 and ("Tier " .. fruit.Tier) or "Unknown"
            Notify("Fruit Found!", fruit.Name .. " (" .. tierStr .. ") detected!", 8)

            -- Save to found list
            Config.FruitSniperFoundFruits[fruit.Name] = {
                Name = fruit.Name,
                Tier = fruit.Tier,
                Time = os.date("%H:%M:%S"),
                Server = game.JobId:sub(1, 8),
            }
            self.FoundCount = self.FoundCount + 1

            -- Update UI
            pcall(function()
                if UIElements and UIElements.FruitLog then
                    UIElements.FruitLog.Text = UIElements.FruitLog.Text .. "\n[" .. os.date("%H:%M:%S") .. "] " .. fruit.Name .. " (" .. tierStr .. ")"
                end
                if UIElements and UIElements.FruitCount then
                    UIElements.FruitCount.Text = "Fruits Found: " .. self.FoundCount
                end
            end)

            if Config.FruitSniperAutoCollect then
                self:CollectFruit(fruit)
            end

            -- Webhook notification
            if Config.FruitSniperWebhook and Config.FruitSniperWebhook ~= "" then
                pcall(function()
                    local data = HttpService:JSONEncode({
                        content = "**Fruit Found!** " .. fruit.Name .. " (" .. tierStr .. ")\nServer: " .. game.JobId:sub(1, 12) .. "\nTime: " .. os.date()
                    })
                    HttpService:PostAsync(Config.FruitSniperWebhook, data)
                end)
            end

            return true
        end
    end

    return false
end

function FruitSniper:HopToFindFruit()
    if not Config.FruitSniperAnyServer then return end

    if tick() - self.LastHop < Config.FruitSniperHopDelay then
        return
    end
    self.LastHop = tick()

    Notify("Fruit Sniper", "No fruits found. Hopping server...", 3)

    -- Small delay before hopping
    task.wait(Config.FruitSniperHopDelay)
    ServerHop()
end

function FruitSniper:Start()
    if self.Running then return end
    self.Running = true
    Notify("Z Hub", "Fruit Sniper Started! Scanning servers...", 5)

    -- Scan for fruits continuously
    spawn(function()
        while self.Running do
            local found = self:ScanAndCollect()

            if not found and Config.FruitSniperServerHop then
                self:HopToFindFruit()
            end

            task.wait(2)
        end
    end)

    -- Also listen for new fruit spawns
    spawn(function()
        self.ScanConn = Workspace.DescendantAdded:Connect(function(desc)
            if not self.Running then return end
            task.wait(1) -- Wait for full load
            local name = desc.Name:lower()
            if name:find("fruit") or name:find("devil") then
                task.wait(0.5)
                self:ScanAndCollect()
            end
        end)
    end)
end

function FruitSniper:Stop()
    self.Running = false
    if self.ScanConn then
        self.ScanConn:Disconnect()
        self.ScanConn = nil
    end
    Notify("Z Hub", "Fruit Sniper Stopped.", 3)
end

-- ======================== AUTO FARM SYSTEM ========================
local AutoFarm = {
    Running = false,
    Connection = nil,
}

function AutoFarm:Start()
    if self.Running then return end
    self.Running = true
    Notify("Z Hub", "Auto Farm Started!", 3)

    spawn(function()
        while self.Running do
            if not IsAlive() then
                task.wait(1)
            else
                local char, hrp, hum = GetCharacter()
                local mob = GetClosestMob(Config.AutoFarmMob)

                if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
                    local mobHrp = mob.HumanoidRootPart
                    local mobHum = mob.Humanoid

                    -- Bring mob if enabled
                    if Config.AutoFarmBringMob then
                        pcall(function()
                            mobHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                        end)
                    end

                    -- Teleport to mob
                    hrp.CFrame = mobHrp.CFrame * CFrame.new(0, 0, 3)

                    -- Attack
                    if Config.AutoFarmStyle == "Melee" then
                        -- Simulate melee click
                        pcall(function()
                            local virtualUser = game:GetService("VirtualUser")
                            virtualUser:CaptureController()
                            virtualUser:ClickButton2(Vector2.new())
                        end)
                    else
                        -- Use weapon
                        pcall(function()
                            local virtualUser = game:GetService("VirtualUser")
                            virtualUser:CaptureController()
                            virtualUser:ClickButton1(Vector2.new())
                        end)
                    end

                    task.wait(Config.AutoFarmAttackSpeed)
                else
                    task.wait(0.5)
                end
            end
        end
    end)
end

function AutoFarm:Stop()
    self.Running = false
    Notify("Z Hub", "Auto Farm Stopped.", 3)
end

-- ======================== PLAYER MODS ========================
local PlayerMods = {
    Connections = {},
}

function PlayerMods:ToggleInfiniteEnergy(on)
    if on then
        self.Connections.Energy = RunService.Heartbeat:Connect(function()
            local char = plr.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    pcall(function()
                        -- Set energy to max
                        if hum:GetAttribute("Energy") then
                            hum:SetAttribute("Energy", hum:GetAttribute("MaxEnergy") or 100)
                        end
                    end)
                end
            end
        end)
    else
        if self.Connections.Energy then
            self.Connections.Energy:Disconnect()
            self.Connections.Energy = nil
        end
    end
end

function PlayerMods:ToggleNoFallDamage(on)
    if on then
        self.Connections.FallDamage = RunService.Heartbeat:Connect(function()
            local char = plr.Character
            if char then
                pcall(function()
                    for _, v in pairs(char:GetDescendants()) do
                        if v.Name:lower():find("fall") or v.Name:lower():find("damage") then
                            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                                -- Block fall damage
                            end
                        end
                    end
                end)
            end
        end)
    else
        if self.Connections.FallDamage then
            self.Connections.FallDamage:Disconnect()
            self.Connections.FallDamage = nil
        end
    end
end

function PlayerMods:ToggleSpeed(on)
    if on then
        self.Connections.Speed = RunService.Heartbeat:Connect(function()
            local char, hrp, hum = GetCharacter()
            if hum then
                hum.WalkSpeed = Config.SpeedValue
            end
        end)
    else
        if self.Connections.Speed then
            self.Connections.Speed:Disconnect()
            self.Connections.Speed = nil
        end
        local char, hrp, hum = GetCharacter()
        if hum then hum.WalkSpeed = 16 end
    end
end

function PlayerMods:ToggleJump(on)
    if on then
        self.Connections.Jump = RunService.Heartbeat:Connect(function()
            local char, hrp, hum = GetCharacter()
            if hum then
                hum.JumpPower = Config.JumpValue
            end
        end)
    else
        if self.Connections.Jump then
            self.Connections.Jump:Disconnect()
            self.Connections.Jump = nil
        end
        local char, hrp, hum = GetCharacter()
        if hum then hum.JumpPower = 50 end
    end
end

-- Fly System
local FlySystem = {
    Active = false,
    BodyVelocity = nil,
    BodyGyro = nil,
    Connection = nil,
}

function FlySystem:Toggle(on)
    local char, hrp = GetCharacter()
    if not hrp then return end

    if on then
        self.Active = true
        -- Create body movers
        self.BodyVelocity = Instance.new("BodyVelocity")
        self.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        self.BodyVelocity.Parent = hrp

        self.BodyGyro = Instance.new("BodyGyro")
        self.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        self.BodyGyro.P = 9000
        self.BodyGyro.Parent = hrp

        self.Connection = RunService.Heartbeat:Connect(function()
            if not self.Active then return end
            local camCF = camera.CFrame
            local direction = Vector3.new(0, 0, 0)

            local uis = game:GetService("UserInputService")
            if uis:IsKeyDown(Enum.KeyCode.W) then direction = direction + camCF.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then direction = direction - camCF.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then direction = direction - camCF.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then direction = direction + camCF.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end

            if self.BodyVelocity then
                self.BodyVelocity.Velocity = direction * Config.FlySpeed
            end
            if self.BodyGyro then
                self.BodyGyro.CFrame = camCF
            end
        end)
    else
        self.Active = false
        if self.BodyVelocity then self.BodyVelocity:Destroy() self.BodyVelocity = nil end
        if self.BodyGyro then self.BodyGyro:Destroy() self.BodyGyro = nil end
        if self.Connection then self.Connection:Disconnect() self.Connection = nil end
    end
end

-- ======================== ESP SYSTEM ========================
local ESPSystem = {
    PlayerHighlights = {},
    FruitHighlights = {},
    Connections = {},
}

function ESPSystem:TogglePlayerESP(on)
    if on then
        -- Create highlights for existing players
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= plr then
                self:CreatePlayerHighlight(v)
            end
        end

        -- Listen for new players
        self.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(v)
            self:CreatePlayerHighlight(v)
        end)

        self.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(v)
            self:RemovePlayerHighlight(v)
        end)
    else
        -- Remove all highlights
        for _, v in pairs(self.PlayerHighlights) do
            pcall(function() v:Destroy() end)
        end
        self.PlayerHighlights = {}

        if self.Connections.PlayerAdded then
            self.Connections.PlayerAdded:Disconnect()
            self.Connections.PlayerAdded = nil
        end
        if self.Connections.PlayerRemoving then
            self.Connections.PlayerRemoving:Disconnect()
            self.Connections.PlayerRemoving = nil
        end
    end
end

function ESPSystem:CreatePlayerHighlight(player)
    spawn(function()
        local char = player.Character
        if not char then
            player.CharacterAdded:Wait()
            char = player.Character
        end

        if char then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ZHub_ESP"
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = char
            self.PlayerHighlights[player.UserId] = highlight
        end
    end)
end

function ESPSystem:RemovePlayerHighlight(player)
    if self.PlayerHighlights[player.UserId] then
        pcall(function() self.PlayerHighlights[player.UserId]:Destroy() end)
        self.PlayerHighlights[player.UserId] = nil
    end
end

function ESPSystem:ToggleFruitESP(on)
    if on then
        -- Scan for fruits and highlight them
        spawn(function()
            while Config.ESPFruits do
                -- Remove old highlights
                for _, v in pairs(self.FruitHighlights) do
                    pcall(function() v:Destroy() end)
                end
                self.FruitHighlights = {}

                -- Find and highlight fruits
                local fruits = FruitSniper:FindFruitsInWorkspace()
                for i, fruit in pairs(fruits) do
                    if fruit.Object and fruit.Object.Parent then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ZHub_FruitESP"
                        highlight.FillColor = Color3.fromRGB(255, 200, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineTransparency = 0
                        highlight.Parent = fruit.Object

                        -- Add billboard label
                        if fruit.Object:IsA("Model") or fruit.Object:IsA("Part") then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "ZHub_FruitLabel"
                            bb.Size = UDim2.new(0, 200, 0, 50)
                            bb.StudsOffset = Vector3.new(0, 4, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = fruit.Object

                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = fruit.Name .. " [Tier " .. (fruit.Tier > 0 and fruit.Tier or "?") .. "]"
                            label.TextColor3 = Color3.fromRGB(255, 255, 0)
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.GothamBold
                            label.TextScaled = true
                            label.Parent = bb

                            table.insert(self.FruitHighlights, bb)
                        end

                        table.insert(self.FruitHighlights, highlight)
                    end
                end

                task.wait(3)
            end
        end)
    else
        for _, v in pairs(self.FruitHighlights) do
            pcall(function() v:Destroy() end)
        end
        self.FruitHighlights = {}
    end
end

-- ======================== ANTI AFK ========================
local AntiAFKConn = nil
local function SetupAntiAFK()
    if AntiAFKConn then return end
    AntiAFKConn = Players.LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
SetupAntiAFK()

-- ======================== UI SYSTEM ========================
-- Hoho Hub style dark theme with red accents
local UIElements = {}

local function CreateUI()
    -- ScreenGui
    local ZHub = Instance.new("ScreenGui")
    ZHub.Name = "ZHub_Main"
    ZHub.ResetOnSpawn = false
    ZHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ZHub.IgnoreGuiInset = true

    pcall(function() ZHub.Parent = CoreGui end)
    if not ZHub.Parent then
        ZHub.Parent = plr.PlayerGui
    end

    -- Colors
    local BG_COLOR = Color3.fromRGB(20, 20, 22)
    local DARK_BG = Color3.fromRGB(28, 28, 32)
    local ACCENT = Color3.fromRGB(210, 30, 45)
    local ACCENT_DARK = Color3.fromRGB(160, 15, 30)
    local TEXT_WHITE = Color3.fromRGB(240, 240, 240)
    local TEXT_DIM = Color3.fromRGB(160, 160, 170)
    local BORDER = Color3.fromRGB(50, 50, 58)

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    MainFrame.BackgroundColor3 = BG_COLOR
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ZHub

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = ACCENT
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.5
    MainStroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = ACCENT_DARK
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar

    -- Fix bottom corners of title bar
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 12)
    TitleFix.Position = UDim2.new(0, 0, 1, -12)
    TitleFix.BackgroundColor3 = ACCENT_DARK
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Z HUB - Blox Fruits"
    TitleLabel.TextColor3 = TEXT_WHITE
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = TEXT_WHITE
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -74, 0, 6)
    MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = TEXT_WHITE
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TitleBar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn

    -- Tab Buttons Frame
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = "TabFrame"
    TabFrame.Size = UDim2.new(1, -16, 0, 32)
    TabFrame.Position = UDim2.new(0, 8, 0, 48)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabFrame

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -16, 1, -88)
    ContentArea.Position = UDim2.new(0, 8, 0, 84)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- ============ TAB SYSTEM ============
    local Tabs = {}
    local ActiveTab = nil

    local function CreateTab(name, order)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "Tab"
        tabBtn.Size = UDim2.new(0, 95, 1, 0)
        tabBtn.BackgroundColor3 = DARK_BG
        tabBtn.Text = name
        tabBtn.TextColor3 = TEXT_DIM
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextSize = 12
        tabBtn.BorderSizePixel = 0
        tabBtn.LayoutOrder = order
        tabBtn.Parent = TabFrame

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabBtn

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = ACCENT
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = ContentArea

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.Parent = tabContent

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 4)
        contentPadding.PaddingBottom = UDim.new(0, 4)
        contentPadding.Parent = tabContent

        Tabs[name] = {
            Button = tabBtn,
            Content = tabContent,
        }

        tabBtn.MouseButton1Click:Connect(function()
            -- Deactivate all
            for tName, tData in pairs(Tabs) do
                tData.Button.BackgroundColor3 = DARK_BG
                tData.Button.TextColor3 = TEXT_DIM
                tData.Content.Visible = false
            end
            -- Activate this tab
            tabBtn.BackgroundColor3 = ACCENT
            tabBtn.TextColor3 = TEXT_WHITE
            tabContent.Visible = true
            ActiveTab = name
        end)

        return tabContent
    end

    -- ============ UI COMPONENTS ============
    local function CreateSection(parent, title, order)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 28)
        section.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        section.BorderSizePixel = 0
        section.LayoutOrder = order
        section.Parent = parent

        local secCorner = Instance.new("UICorner")
        secCorner.CornerRadius = UDim.new(0, 6)
        secCorner.Parent = section

        local secLabel = Instance.new("TextLabel")
        secLabel.Size = UDim2.new(1, -12, 1, 0)
        secLabel.Position = UDim2.new(0, 12, 0, 0)
        secLabel.BackgroundTransparency = 1
        secLabel.Text = title
        secLabel.TextColor3 = ACCENT
        secLabel.Font = Enum.Font.GothamBold
        secLabel.TextSize = 13
        secLabel.TextXAlignment = Enum.TextXAlignment.Left
        secLabel.Parent = section

        return section
    end

    local function CreateToggle(parent, text, order, callback)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(1, 0, 0, 34)
        toggle.BackgroundColor3 = DARK_BG
        toggle.BorderSizePixel = 0
        toggle.Text = ""
        toggle.LayoutOrder = order
        toggle.Parent = parent

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 6)
        tCorner.Parent = toggle

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -60, 1, 0)
        tLabel.Position = UDim2.new(0, 12, 0, 0)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = text
        tLabel.TextColor3 = TEXT_WHITE
        tLabel.Font = Enum.Font.Gotham
        tLabel.TextSize = 13
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.Parent = toggle

        -- Toggle indicator
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 40, 0, 20)
        indicator.Position = UDim2.new(1, -50, 0.5, -10)
        indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggle

        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(1, 0)
        indCorner.Parent = indicator

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = UDim2.new(0, 2, 0, 2)
        dot.BackgroundColor3 = TEXT_WHITE
        dot.BorderSizePixel = 0
        dot.Parent = indicator

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local isOn = false
        toggle.MouseButton1Click:Connect(function()
            isOn = not isOn
            if isOn then
                indicator.BackgroundColor3 = ACCENT
                dot.Position = UDim2.new(0, 22, 0, 2)
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0, 2)}):Play()
            else
                indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                dot.Position = UDim2.new(0, 2, 0, 2)
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
            end
            if callback then callback(isOn) end
        end)

        return toggle, function() return isOn end
    end

    local function CreateSlider(parent, text, min, max, default, order, callback)
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 44)
        slider.BackgroundColor3 = DARK_BG
        slider.BorderSizePixel = 0
        slider.LayoutOrder = order
        slider.Parent = parent

        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 6)
        sCorner.Parent = slider

        local sLabel = Instance.new("TextLabel")
        sLabel.Size = UDim2.new(1, -12, 0, 20)
        sLabel.Position = UDim2.new(0, 12, 0, 4)
        sLabel.BackgroundTransparency = 1
        sLabel.Text = text .. ": " .. tostring(default)
        sLabel.TextColor3 = TEXT_WHITE
        sLabel.Font = Enum.Font.Gotham
        sLabel.TextSize = 12
        sLabel.TextXAlignment = Enum.TextXAlignment.Left
        sLabel.Parent = slider

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 8)
        track.Position = UDim2.new(0, 12, 0, 28)
        track.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
        track.BorderSizePixel = 0
        track.Parent = slider

        local trCorner = Instance.new("UICorner")
        trCorner.CornerRadius = UDim.new(1, 0)
        trCorner.Parent = track

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = ACCENT
        fill.BorderSizePixel = 0
        fill.Parent = track

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local sliding = false
        local function updateSlider(input)
            local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + relX * (max - min))
            fill.Size = UDim2.new(relX, 0, 1, 0)
            sLabel.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                updateSlider(input)
            end
        end)

        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)

        return slider
    end

    local function CreateButton(parent, text, order, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = ACCENT
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = TEXT_WHITE
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.LayoutOrder = order
        btn.Parent = parent

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 6)
        bCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return btn
    end

    local function CreateDropdown(parent, text, options, order, callback)
        local dd = Instance.new("Frame")
        dd.Size = UDim2.new(1, 0, 0, 34)
        dd.BackgroundColor3 = DARK_BG
        dd.BorderSizePixel = 0
        dd.LayoutOrder = order
        dd.ClipsDescendants = true
        dd.Parent = parent

        local ddCorner = Instance.new("UICorner")
        ddCorner.CornerRadius = UDim.new(0, 6)
        ddCorner.Parent = dd

        local ddBtn = Instance.new("TextButton")
        ddBtn.Size = UDim2.new(1, 0, 1, 0)
        ddBtn.BackgroundTransparency = 1
        ddBtn.Text = text .. ": " .. (options[1] or "")
        ddBtn.TextColor3 = TEXT_WHITE
        ddBtn.Font = Enum.Font.Gotham
        ddBtn.TextSize = 12
        ddBtn.TextXAlignment = Enum.TextXAlignment.Left
        ddBtn.Parent = dd

        local ddPad = Instance.new("UIPadding")
        ddPad.PaddingLeft = UDim.new(0, 12)
        ddPad.Parent = ddBtn

        local ddArrow = Instance.new("TextLabel")
        ddArrow.Size = UDim2.new(0, 20, 1, 0)
        ddArrow.Position = UDim2.new(1, -24, 0, 0)
        ddArrow.BackgroundTransparency = 1
        ddArrow.Text = "v"
        ddArrow.TextColor3 = TEXT_DIM
        ddArrow.Font = Enum.Font.GothamBold
        ddArrow.TextSize = 12
        ddArrow.Parent = dd

        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0, #options * 28)
        optionFrame.Position = UDim2.new(0, 0, 1, 0)
        optionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        optionFrame.BorderSizePixel = 0
        optionFrame.ZIndex = 10
        optionFrame.Visible = false
        optionFrame.Parent = dd

        local optLayout = Instance.new("UIListLayout")
        optLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optLayout.Parent = optionFrame

        for i, opt in pairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundTransparency = 1
            optBtn.Text = opt
            optBtn.TextColor3 = TEXT_WHITE
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 12
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.ZIndex = 10
            optBtn.Parent = optionFrame

            local optPad = Instance.new("UIPadding")
            optPad.PaddingLeft = UDim.new(0, 12)
            optPad.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                ddBtn.Text = text .. ": " .. opt
                optionFrame.Visible = false
                dd.Size = UDim2.new(1, 0, 0, 34)
                if callback then callback(opt) end
            end)
        end

        local isOpen = false
        ddBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            optionFrame.Visible = isOpen
            if isOpen then
                dd.Size = UDim2.new(1, 0, 0, 34 + #options * 28)
            else
                dd.Size = UDim2.new(1, 0, 0, 34)
            end
        end)

        return dd
    end

    local function CreateLabel(parent, text, order)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 24)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = TEXT_DIM
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.LayoutOrder = order
        label.Parent = parent

        local lPad = Instance.new("UIPadding")
        lPad.PaddingLeft = UDim.new(0, 8)
        lPad.Parent = label

        return label
    end

    -- ============ FRUIT SNIPER TAB ============
    local SniperTab = CreateTab("Sniper", 1)

    CreateSection(SniperTab, "FRUIT SNIPER (ANY SERVER)", 1)
    CreateLabel(SniperTab, "Scans all servers and auto-collects rare fruits", 2)

    UIElements.FruitCount = CreateLabel(SniperTab, "Fruits Found: 0", 3)

    local sniperToggle, getSniperState = CreateToggle(SniperTab, "Fruit Sniper [Any Server]", 4, function(on)
        Config.FruitSniperEnabled = on
        if on then
            FruitSniper:Start()
        else
            FruitSniper:Stop()
        end
    end)

    CreateToggle(SniperTab, "Auto Collect Fruit", 5, function(on)
        Config.FruitSniperAutoCollect = on
    end)

    CreateToggle(SniperTab, "Server Hop (Find in Any Server)", 6, function(on)
        Config.FruitSniperServerHop = on
        Config.FruitSniperAnyServer = on
    end)

    CreateToggle(SniperTab, "Fruit Notifications", 7, function(on)
        Config.FruitSniperNotify = on
    end)

    CreateSection(SniperTab, "FRUIT BLACKLIST", 8)

    -- Quick blacklist toggles
    CreateToggle(SniperTab, 'Blacklist: Bomb', 9, function(on)
        if on then
            table.insert(Config.FruitSniperBlacklist, "Bomb")
        else
            for i, v in pairs(Config.FruitSniperBlacklist) do
                if v == "Bomb" then table.remove(Config.FruitSniperBlacklist, i) break end
            end
        end
    end)

    CreateToggle(SniperTab, 'Blacklist: Spike', 10, function(on)
        if on then
            table.insert(Config.FruitSniperBlacklist, "Spike")
        else
            for i, v in pairs(Config.FruitSniperBlacklist) do
                if v == "Spike" then table.remove(Config.FruitSniperBlacklist, i) break end
            end
        end
    end)

    CreateToggle(SniperTab, 'Blacklist: Chop', 11, function(on)
        if on then
            table.insert(Config.FruitSniperBlacklist, "Chop")
        else
            for i, v in pairs(Config.FruitSniperBlacklist) do
                if v == "Chop" then table.remove(Config.FruitSniperBlacklist, i) break end
            end
        end
    end)

    CreateToggle(SniperTab, 'Blacklist: Spring', 12, function(on)
        if on then
            table.insert(Config.FruitSniperBlacklist, "Spring")
        else
            for i, v in pairs(Config.FruitSniperBlacklist) do
                if v == "Spring" then table.remove(Config.FruitSniperBlacklist, i) break end
            end
        end
    end)

    CreateToggle(SniperTab, 'Blacklist: Kilo', 13, function(on)
        if on then
            table.insert(Config.FruitSniperBlacklist, "Kilo")
        else
            for i, v in pairs(Config.FruitSniperBlacklist) do
                if v == "Kilo" then table.remove(Config.FruitSniperBlacklist, i) break end
            end
        end
    end)

    CreateToggle(SniperTab, 'Blacklist: Spin', 14, function(on)
        if on then
            table.insert(Config.FruitSniperBlacklist, "Spin")
        else
            for i, v in pairs(Config.FruitSniperBlacklist) do
                if v == "Spin" then table.remove(Config.FruitSniperBlacklist, i) break end
            end
        end
    end)

    CreateSection(SniperTab, "HOP SETTINGS", 15)

    CreateSlider(SniperTab, "Hop Delay (sec)", 1, 15, 3, 16, function(val)
        Config.FruitSniperHopDelay = val
    end)

    CreateSlider(SniperTab, "Collect Delay (sec)", 0.1, 5, 0.5, 17, function(val)
        Config.FruitSniperCollectDelay = val
    end)

    CreateSection(SniperTab, "FRUIT LOG", 18)

    local logFrame = Instance.new("Frame")
    logFrame.Size = UDim2.new(1, 0, 0, 100)
    logFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    logFrame.BorderSizePixel = 0
    logFrame.LayoutOrder = 19
    logFrame.Parent = SniperTab

    local logCorner = Instance.new("UICorner")
    logCorner.CornerRadius = UDim.new(0, 6)
    logCorner.Parent = logFrame

    UIElements.FruitLog = Instance.new("TextLabel")
    UIElements.FruitLog.Size = UDim2.new(1, -8, 1, -8)
    UIElements.FruitLog.Position = UDim2.new(0, 4, 0, 4)
    UIElements.FruitLog.BackgroundTransparency = 1
    UIElements.FruitLog.Text = "Waiting for fruits..."
    UIElements.FruitLog.TextColor3 = Color3.fromRGB(255, 200, 100)
    UIElements.FruitLog.Font = Enum.Font.Code
    UIElements.FruitLog.TextSize = 11
    UIElements.FruitLog.TextXAlignment = Enum.TextXAlignment.Left
    UIElements.FruitLog.TextYAlignment = Enum.TextYAlignment.Top
    UIElements.FruitLog.Parent = logFrame

    -- ============ AUTO FARM TAB ============
    local FarmTab = CreateTab("Farm", 2)

    CreateSection(FarmTab, "AUTO FARM", 1)

    local farmToggle = CreateToggle(FarmTab, "Auto Farm", 2, function(on)
        Config.AutoFarmEnabled = on
        if on then
            AutoFarm:Start()
        else
            AutoFarm:Stop()
        end
    end)

    CreateToggle(FarmTab, "Bring Mobs", 3, function(on)
        Config.AutoFarmBringMob = on
    end)

    CreateToggle(FarmTab, "Auto Quest", 4, function(on)
        Config.AutoFarmQuest = on
    end)

    CreateSection(FarmTab, "FARM SETTINGS", 5)

    CreateDropdown(FarmTab, "Mob", {
        "Bandit [Lv. 5]",
        "Monkey [Lv. 14]",
        "Gorilla [Lv. 20]",
        "Pirate [Lv. 30]",
        "Brute [Lv. 45]",
        "Desert Bandit [Lv. 60]",
        "Desert Officer [Lv. 80]",
        "Chief Petty Officer [Lv. 120]",
        "Sky Bandit [Lv. 150]",
        "Dark Master [Lv. 175]",
        "Prisoner [Lv. 200]",
        "Dangerous Prisoner [Lv. 220]",
        "Tyrant [Lv. 275]",
        "Vampire [Lv. 350]",
        "Magma Ninja [Lv. 450]",
        "Fishman Captain [Lv. 550]",
        "Vander [Lv. 650]",
        "Head Baker [Lv. 775]",
        "Baking Staff [Lv. 850]",
        "Cookie Crafter [Lv. 900]",
        "Cake Queen [Lv. 1075]",
        "Beautiful Pirate [Lv. 1150]",
    }, 6, function(val)
        Config.AutoFarmMob = val
    end)

    CreateDropdown(FarmTab, "Attack Style", {"Melee", "Sword", "Gun"}, 7, function(val)
        Config.AutoFarmStyle = val
    end)

    CreateSlider(FarmTab, "Attack Speed", 0.1, 2, 0.3, 8, function(val)
        Config.AutoFarmAttackSpeed = val
    end)

    -- ============ PLAYER TAB ============
    local PlayerTab = CreateTab("Player", 3)

    CreateSection(PlayerTab, "PLAYER MODS", 1)

    CreateToggle(PlayerTab, "Infinite Energy", 2, function(on)
        Config.InfiniteEnergy = on
        PlayerMods:ToggleInfiniteEnergy(on)
    end)

    CreateToggle(PlayerTab, "No Fall Damage", 3, function(on)
        Config.NoFallDamage = on
        PlayerMods:ToggleNoFallDamage(on)
    end)

    CreateToggle(PlayerTab, "Anti-AFK", 4, function(on)
        Config.AntiAFK = on
        if on then SetupAntiAFK() end
    end)

    CreateSection(PlayerTab, "MOVEMENT", 5)

    CreateToggle(PlayerTab, "Speed Hack", 6, function(on)
        Config.SpeedEnabled = on
        PlayerMods:ToggleSpeed(on)
    end)

    CreateSlider(PlayerTab, "WalkSpeed", 16, 200, 50, 7, function(val)
        Config.SpeedValue = val
    end)

    CreateToggle(PlayerTab, "Jump Hack", 8, function(on)
        Config.JumpEnabled = on
        PlayerMods:ToggleJump(on)
    end)

    CreateSlider(PlayerTab, "JumpPower", 50, 300, 100, 9, function(val)
        Config.JumpValue = val
    end)

    CreateToggle(PlayerTab, "Fly (WASD + Space/Shift)", 10, function(on)
        Config.FlyEnabled = on
        FlySystem:Toggle(on)
    end)

    CreateSlider(PlayerTab, "Fly Speed", 20, 200, 80, 11, function(val)
        Config.FlySpeed = val
    end)

    -- ============ ESP TAB ============
    local ESPTab = CreateTab("ESP", 4)

    CreateSection(ESPTab, "ESP / VISUALS", 1)

    CreateToggle(ESPTab, "Player ESP (Red Highlight)", 2, function(on)
        Config.ESPPlayers = on
        ESPSystem:TogglePlayerESP(on)
    end)

    CreateToggle(ESPTab, "Fruit ESP (Yellow Highlight + Labels)", 3, function(on)
        Config.ESPFruits = on
        ESPSystem:ToggleFruitESP(on)
    end)

    CreateSection(ESPTab, "WORLD", 4)

    CreateToggle(ESPTab, "Remove Lava", 5, function(on)
        Config.RemoveLava = on
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name:lower():find("lava") then
                    v.Transparency = on and 1 or 0
                end
            end
        end)
    end)

    CreateToggle(ESPTab, "Fullbright", 6, function(on)
        if on then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1000
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end)

    -- ============ MISC TAB ============
    local MiscTab = CreateTab("Misc", 5)

    CreateSection(MiscTab, "SERVER", 1)

    CreateButton(MiscTab, "Server Hop (Random)", 2, function()
        Notify("Z Hub", "Hopping to a new server...", 3)
        task.wait(1)
        ServerHop()
    end)

    CreateButton(MiscTab, "Rejoin Server", 3, function()
        Notify("Z Hub", "Rejoining current server...", 3)
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, plr)
    end)

    CreateButton(MiscTab, "Teleport to Sea 1", 4, function()
        local char, hrp = GetCharacter()
        if hrp then
            hrp.CFrame = CFrame.new(372, 13, 1878)
        end
    end)

    CreateButton(MiscTab, "Teleport to Sea 2", 5, function()
        local char, hrp = GetCharacter()
        if hrp then
            hrp.CFrame = CFrame.new(-9400, 13, -9000)
        end
    end)

    CreateButton(MiscTab, "Teleport to Sea 3", 6, function()
        local char, hrp = GetCharacter()
        if hrp then
            hrp.CFrame = CFrame.new(-20000, 13, -18000)
        end
    end)

    CreateSection(MiscTab, "COLLECTION", 7)

    CreateToggle(MiscTab, "Auto Collect Coins", 8, function(on)
        Config.AutoCollectCoins = on
        if on then
            spawn(function()
                while Config.AutoCollectCoins do
                    pcall(function()
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v.Name:lower():find("coin") or v.Name:lower():find("money") or v.Name:lower():find("beli") then
                                if v:IsA("Part") or v:IsA("BasePart") then
                                    local char, hrp = GetCharacter()
                                    if hrp then
                                        firetouchinterest(hrp, v, 0)
                                        task.wait(0.05)
                                        firetouchinterest(hrp, v, 1)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end)

    CreateSection(MiscTab, "INFO", 9)

    CreateLabel(MiscTab, "Z Hub v1.0 | Keyless | Delta Executor", 10)
    CreateLabel(MiscTab, "Fruit Sniper scans all servers for rare fruits", 11)
    CreateLabel(MiscTab, "Made for educational purposes only", 12)

    -- ============ DRAGGING ============
    local dragging, dragInput, dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ============ CLOSE / MINIMIZE ============
    CloseBtn.MouseButton1Click:Connect(function()
        ZHub:Destroy()
        -- Cleanup
        FruitSniper:Stop()
        AutoFarm:Stop()
        FlySystem:Toggle(false)
        ESPSystem:TogglePlayerESP(false)
        Config.ESPFruits = false
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        ContentArea.Visible = not minimized
        TabFrame.Visible = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 520, 0, 42)
        else
            MainFrame.Size = UDim2.new(0, 520, 0, 380)
        end
    end)

    -- Default tab
    Tabs["Sniper"].Button.BackgroundColor3 = ACCENT
    Tabs["Sniper"].Button.TextColor3 = TEXT_WHITE
    Tabs["Sniper"].Content.Visible = true
    ActiveTab = "Sniper"

    -- Intro notification
    Notify("Z Hub", "Loaded successfully! Keyless mode active.", 5)

    return ZHub
end

-- ======================== MAIN LOAD ========================
spawn(function()
    pcall(function()
        CreateUI()
    end)
end)
