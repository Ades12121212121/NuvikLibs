--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          NUVIK FRAMEWORK V2.0 - COMPLETE EDITION          ║
    ║              All-in-One Framework for Executors           ║
    ╚═══════════════════════════════════════════════════════════╝
    GitHub: github.com/TU_USUARIO/nuvik-framework
]]

local Nuvik = {}
Nuvik.__index = Nuvik
Nuvik.Version = "2.0.0"

-- ========================================
-- SERVICES
-- ========================================
local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService"),
    StarterGui = game:GetService("StarterGui")
}

-- ========================================
-- LOGGER
-- ========================================
local Logger = {}
function Logger.new()
    local self = {logs = {}, max = 500}
    
    function self:log(level, msg, data)
        table.insert(self.logs, {level=level, msg=msg, data=data, time=tick()})
        if #self.logs > self.max then table.remove(self.logs, 1) end
        
        local prefix = ({INFO="[ℹ️]", WARN="[⚠️]", ERROR="[❌]", DEBUG="[🔍]"})[level]
        print(prefix, msg, data and Services.HttpService:JSONEncode(data) or "")
    end
    
    function self:info(m, d) self:log("INFO", m, d) end
    function self:warn(m, d) self:log("WARN", m, d) end
    function self:error(m, d) self:log("ERROR", m, d) end
    function self:debug(m, d) self:log("DEBUG", m, d) end
    
    return self
end

-- ========================================
-- PLAYER MODULE
-- ========================================
local PlayerModule = {}
function PlayerModule.new(logger)
    local self = {logger = logger}
    
    function self:get_all()
        local result = {}
        for _, p in ipairs(Services.Players:GetPlayers()) do
            result[p.Name] = self:get_info(p)
        end
        return result
    end
    
    function self:get_info(player)
        local c = player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        
        return {
            Name = player.Name,
            Display = player.DisplayName,
            Id = player.UserId,
            Team = player.Team and player.Team.Name or "None",
            Health = h and {Current=h.Health, Max=h.MaxHealth} or nil,
            Pos = r and r.Position or nil,
            Speed = h and h.WalkSpeed or 0,
            Jump = h and h.JumpPower or 0
        }
    end
    
    function self:find(query)
        query = string.lower(tostring(query))
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if string.find(string.lower(p.Name), query) or 
               string.find(string.lower(p.DisplayName), query) or
               tostring(p.UserId) == query then
                return p
            end
        end
        return nil
    end
    
    function self:teleport(player, pos)
        if not player or not player.Character then return false end
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(pos) return true end
        return false
    end
    
    function self:teleport_to_player(from, to)
        if not to or not to.Character then return false end
        local root = to.Character:FindFirstChild("HumanoidRootPart")
        if root then return self:teleport(from, root.Position) end
        return false
    end
    
    function self:modify(player, prop, value)
        if not player or not player.Character then return false end
        local h = player.Character:FindFirstChildOfClass("Humanoid")
        if h and h[prop] ~= nil then h[prop] = value return true end
        return false
    end
    
    function self:get_distance(p1, p2)
        if not p1 or not p1.Character or not p2 or not p2.Character then return nil end
        local r1 = p1.Character:FindFirstChild("HumanoidRootPart")
        local r2 = p2.Character:FindFirstChild("HumanoidRootPart")
        if r1 and r2 then return (r1.Position - r2.Position).Magnitude end
        return nil
    end
    
    function self:kill(player)
        if player and player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.Health = 0 return true end
        end
        return false
    end
    
    function self:respawn(player)
        if player then player:LoadCharacter() return true end
        return false
    end
    
    function self:get_tools(player)
        local tools = {}
        if player.Character then
            for _, t in ipairs(player.Character:GetChildren()) do
                if t:IsA("Tool") then table.insert(tools, t.Name) end
            end
        end
        if player:FindFirstChild("Backpack") then
            for _, t in ipairs(player.Backpack:GetChildren()) do
                if t:IsA("Tool") then table.insert(tools, t.Name) end
            end
        end
        return tools
    end
    
    return self
end

-- ========================================
-- ENVIRONMENT MODULE
-- ========================================
local EnvironmentModule = {}
function EnvironmentModule.new(logger)
    local self = {logger = logger, backup = {}}
    
    function self:get_lighting()
        return {
            Time = Services.Lighting.ClockTime,
            TimeStr = Services.Lighting.TimeOfDay,
            Brightness = Services.Lighting.Brightness,
            Ambient = Services.Lighting.Ambient,
            OutdoorAmbient = Services.Lighting.OutdoorAmbient,
            FogEnd = Services.Lighting.FogEnd,
            FogStart = Services.Lighting.FogStart,
            FogColor = Services.Lighting.FogColor
        }
    end
    
    function self:set_time(value)
        if type(value) == "number" then
            Services.Lighting.ClockTime = value
        else
            Services.Lighting.TimeOfDay = tostring(value)
        end
    end
    
    function self:set_brightness(v) Services.Lighting.Brightness = v end
    function self:set_fog(start, finish)
        Services.Lighting.FogStart = start or 0
        Services.Lighting.FogEnd = finish or 100000
    end
    
    function self:fullbright()
        Services.Lighting.Brightness = 2
        Services.Lighting.ClockTime = 14
        Services.Lighting.FogEnd = 100000
        Services.Lighting.GlobalShadows = false
        Services.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    
    function self:backup_lighting()
        self.backup.lighting = self:get_lighting()
        self.logger:info("Lighting backed up")
    end
    
    function self:restore_lighting()
        if not self.backup.lighting then return false end
        for k, v in pairs(self.backup.lighting) do
            pcall(function() Services.Lighting[k] = v end)
        end
        return true
    end
    
    function self:get_workspace()
        local parts, models = 0, 0
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then parts = parts + 1
            elseif obj:IsA("Model") then models = models + 1 end
        end
        return {
            Gravity = Services.Workspace.Gravity,
            Parts = parts,
            Models = models,
            Streaming = Services.Workspace.StreamingEnabled
        }
    end
    
    function self:set_gravity(v) Services.Workspace.Gravity = v or 196.2 end
    
    function self:find_parts(filter)
        local results, count = {}, 0
        local max = filter.max or 100
        
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and count < max then
                local match = true
                if filter.name and not string.find(string.lower(obj.Name), string.lower(filter.name)) then
                    match = false
                end
                if filter.material and obj.Material.Name ~= filter.material then match = false end
                if filter.color and obj.Color ~= filter.color then match = false end
                
                if match then
                    table.insert(results, {
                        Name = obj.Name,
                        Type = obj.ClassName,
                        Pos = obj.Position,
                        Size = obj.Size,
                        Material = obj.Material.Name,
                        Path = obj:GetFullName()
                    })
                    count = count + 1
                end
            end
        end
        return results
    end
    
    function self:clear_terrain()
        if Services.Workspace:FindFirstChild("Terrain") then
            Services.Workspace.Terrain:Clear()
            return true
        end
        return false
    end
    
    return self
end

-- ========================================
-- VISUAL MODULE
-- ========================================
local VisualModule = {}
function VisualModule.new(logger)
    local self = {logger = logger, esp_objects = {}, highlights = {}}
    
    function self:create_esp(player)
        if not player or not player.Character then return end
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_" .. player.Name
        bb.Adornee = root
        bb.Size = UDim2.new(0, 100, 0, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = root
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = player.Name
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0.5
        text.TextScaled = true
        text.Font = Enum.Font.SourceSansBold
        text.Parent = bb
        
        self.esp_objects[player.Name] = bb
    end
    
    function self:remove_esp(player)
        if self.esp_objects[player.Name] then
            self.esp_objects[player.Name]:Destroy()
            self.esp_objects[player.Name] = nil
        end
    end
    
    function self:enable_esp_all()
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Services.Players.LocalPlayer then
                self:create_esp(p)
            end
        end
    end
    
    function self:disable_esp_all()
        for _, obj in pairs(self.esp_objects) do obj:Destroy() end
        self.esp_objects = {}
    end
    
    function self:highlight_part(part, color)
        if not part or not part:IsA("BasePart") then return end
        
        local box = Instance.new("SelectionBox")
        box.Adornee = part
        box.Color3 = color or Color3.fromRGB(255, 0, 0)
        box.LineThickness = 0.05
        box.Parent = part
        
        table.insert(self.highlights, box)
        return box
    end
    
    function self:clear_highlights()
        for _, h in ipairs(self.highlights) do h:Destroy() end
        self.highlights = {}
    end
    
    function self:create_beam(from, to, color)
        local attach0 = Instance.new("Attachment", from)
        local attach1 = Instance.new("Attachment", to)
        
        local beam = Instance.new("Beam")
        beam.Attachment0 = attach0
        beam.Attachment1 = attach1
        beam.Color = ColorSequence.new(color or Color3.fromRGB(255, 255, 0))
        beam.Width0 = 0.5
        beam.Width1 = 0.5
        beam.Parent = from
        
        return {beam = beam, a0 = attach0, a1 = attach1}
    end
    
    return self
end

-- ========================================
-- GAME UTILITIES MODULE
-- ========================================
local GameModule = {}
function GameModule.new(logger)
    local self = {logger = logger, connections = {}}
    
    function self:get_local() return Services.Players.LocalPlayer end
    function self:get_char() local p = self:get_local() return p and p.Character end
    function self:get_humanoid() local c = self:get_char() return c and c:FindFirstChildOfClass("Humanoid") end
    function self:get_root() local c = self:get_char() return c and c:FindFirstChild("HumanoidRootPart") end
    function self:is_alive() local h = self:get_humanoid() return h and h.Health > 0 end
    
    function self:noclip(enabled)
        if self.connections.noclip then
            self.connections.noclip:Disconnect()
            self.connections.noclip = nil
        end
        
        if enabled then
            self.connections.noclip = Services.RunService.Stepped:Connect(function()
                local c = self:get_char()
                if c then
                    for _, p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    end
    
    function self:god_mode(enabled)
        local h = self:get_humanoid()
        if h then
            if enabled then
                h.MaxHealth = math.huge
                h.Health = math.huge
            else
                h.MaxHealth = 100
                h.Health = 100
            end
        end
    end
    
    function self:infinite_jump(enabled)
        if self.connections.inf_jump then
            self.connections.inf_jump:Disconnect()
            self.connections.inf_jump = nil
        end
        
        if enabled then
            self.connections.inf_jump = Services.UserInputService.JumpRequest:Connect(function()
                local h = self:get_humanoid()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end
    
    function self:fly(enabled, speed)
        if self.connections.fly then
            for _, c in pairs(self.connections.fly) do c:Disconnect() end
            self.connections.fly = nil
        end
        
        if enabled then
            speed = speed or 50
            local root = self:get_root()
            if not root then return end
            
            local bg = Instance.new("BodyGyro", root)
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 9e4
            
            local bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            self.connections.fly = {}
            
            table.insert(self.connections.fly, Services.RunService.RenderStepped:Connect(function()
                local cam = Services.Workspace.CurrentCamera
                if cam and root then
                    bg.CFrame = cam.CFrame
                    
                    local velocity = Vector3.new(0, 0, 0)
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + cam.CFrame.LookVector * speed end
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - cam.CFrame.LookVector * speed end
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - cam.CFrame.RightVector * speed end
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + cam.CFrame.RightVector * speed end
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, speed, 0) end
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then velocity = velocity - Vector3.new(0, speed, 0) end
                    
                    bv.Velocity = velocity
                end
            end))
        end
    end
    
    function self:anti_afk()
        local vu = game:GetService("VirtualUser")
        Services.Players.LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        self.logger:info("Anti-AFK enabled")
    end
    
    return self
end

-- ========================================
-- UTILITY MODULE
-- ========================================
local UtilityModule = {}
function UtilityModule.new(logger)
    local self = {logger = logger}
    
    function self:format_time(s)
        local h = math.floor(s / 3600)
        local m = math.floor((s % 3600) / 60)
        local sec = math.floor(s % 60)
        return string.format("%02d:%02d:%02d", h, m, sec)
    end
    
    function self:format_number(n)
        local f = tostring(n)
        while true do
            f, k = string.gsub(f, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return f
    end
    
    function self:random_string(len)
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        local result = ""
        for i = 1, len do
            local r = math.random(1, #chars)
            result = result .. string.sub(chars, r, r)
        end
        return result
    end
    
    function self:uuid()
        return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)
    end
    
    function self:distance(p1, p2) return (p1 - p2).Magnitude end
    function self:lerp(a, b, t) return a + (b - a) * t end
    function self:clamp(v, min, max) return math.max(min, math.min(max, v)) end
    function self:round(n, d)
        d = d or 0
        local m = 10 ^ d
        return math.floor(n * m + 0.5) / m
    end
    
    function self:vec_to_str(v) return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z) end
    function self:color_to_rgb(c)
        return {R = math.floor(c.R * 255), G = math.floor(c.G * 255), B = math.floor(c.B * 255)}
    end
    function self:color_to_hex(c)
        local rgb = self:color_to_rgb(c)
        return string.format("#%02X%02X%02X", rgb.R, rgb.G, rgb.B)
    end
    
    function self:copy_table(t)
        local c = {}
        for k, v in pairs(t) do
            c[k] = type(v) == "table" and self:copy_table(v) or v
        end
        return c
    end
    
    function self:merge_tables(...)
        local r = {}
        for _, t in ipairs({...}) do
            for k, v in pairs(t) do r[k] = v end
        end
        return r
    end
    
    function self:count_table(t)
        local c = 0
        for _ in pairs(t) do c = c + 1 end
        return c
    end
    
    return self
end

-- ========================================
-- NOTIFICATION MODULE
-- ========================================
local NotificationModule = {}
function NotificationModule.new()
    local self = {}
    
    function self:send(title, text, duration)
        Services.StarterGui:SetCore("SendNotification", {
            Title = title or "Nuvik",
            Text = text or "",
            Duration = duration or 3
        })
    end
    
    function self:success(text) self:send("✅ Success", text, 2) end
    function self:error(text) self:send("❌ Error", text, 3) end
    function self:warning(text) self:send("⚠️ Warning", text, 2) end
    function self:info(text) self:send("ℹ️ Info", text, 2) end
    
    return self
end

-- ========================================
-- MAIN FRAMEWORK
-- ========================================
function Nuvik.new()
    local self = setmetatable({}, Nuvik)
    
    self.logger = Logger.new()
    self.modules = {
        Player = PlayerModule.new(self.logger),
        Environment = EnvironmentModule.new(self.logger),
        Visual = VisualModule.new(self.logger),
        Game = GameModule.new(self.logger),
        Utility = UtilityModule.new(self.logger),
        Notification = NotificationModule.new()
    }
    
    self.info = {
        version = Nuvik.Version,
        start = tick(),
        environment = Services.RunService:IsClient() and "Client" or "Server"
    }
    
    self.logger:info("Nuvik Framework initialized", {version = Nuvik.Version})
    
    function self:get(name) return self.modules[name] end
    
    function self:get_stats()
        return {
            version = self.info.version,
            uptime = tick() - self.info.start,
            uptime_str = self.modules.Utility:format_time(tick() - self.info.start),
            memory = collectgarbage("count"),
            modules = {"Player", "Environment", "Visual", "Game", "Utility", "Notification"}
        }
    end
    
    return self
end

_G.Nuvik = Nuvik.new()
return Nuvik
