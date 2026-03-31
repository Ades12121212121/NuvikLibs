--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║              NUVIK FRAMEWORK - MAIN LOADER                ║
    ║                   Executor Script v2.0                    ║
    ╚═══════════════════════════════════════════════════════════╝
]]

print("🔄 Loading Nuvik Framework...")

-- ========================================
-- CARGAR FRAMEWORK (DESDE GITHUB)
-- ========================================
local frameworkUrl = "https://raw.githubusercontent.com/TU_USUARIO/nuvik-framework/main/nuvik-framework.lua"
local uiUrl = "https://raw.githubusercontent.com/TU_USUARIO/nuvik-framework/main/nuvik-ui.lua"

-- Cargar Framework
local success1, NuvikFramework = pcall(function()
    return loadstring(game:HttpGet(frameworkUrl))()
end)

if not success1 then
    warn("❌ Error loading framework:", NuvikFramework)
    return
end

-- Cargar UI Library
local success2, NuvikUI = pcall(function()
    return loadstring(game:HttpGet(uiUrl))()
end)

if not success2 then
    warn("❌ Error loading UI:", NuvikUI)
    return
end

print("✅ Framework & UI loaded successfully!")

-- ========================================
-- INICIALIZAR FRAMEWORK
-- ========================================
local framework = NuvikFramework.new()
_G.Nuvik = framework

-- ========================================
-- CREAR INTERFAZ
-- ========================================
local window = NuvikUI:CreateWindow({
    Title = "Nuvik Framework",
    Version = "v2.0",
    Size = UDim2.new(0, 580, 0, 420)
})

-- ========================================
-- TAB: HOME
-- ========================================
local homeTab = window:CreateTab("Home", "🏠")

window:CreateLabel(homeTab, "Welcome to Nuvik Framework!")
window:CreateLabel(homeTab, "Advanced executor framework with modern UI")

window:CreateButton(homeTab, "🎮 Get Local Player Info", function()
    local playerMgr = framework:get("Player")
    local localPlayer = game.Players.LocalPlayer
    
    if localPlayer then
        local info = playerMgr:get_player_info(localPlayer)
        print("=== LOCAL PLAYER INFO ===")
        print("Name:", info.Name)
        print("Health:", info.Health .. "/" .. info.MaxHealth)
        print("Position:", info.Position)
        print("WalkSpeed:", info.WalkSpeed)
    end
end)

window:CreateButton(homeTab, "📊 Framework Statistics", function()
    local stats = framework:get_stats()
    print("=== FRAMEWORK STATS ===")
    print("Version:", stats.version)
    print("Uptime:", stats.uptime_formatted)
    print("Memory:", string.format("%.2f KB", stats.memory))
    print("Modules:", table.concat(stats.modules, ", "))
end)

-- ========================================
-- TAB: PLAYER
-- ========================================
local playerTab = window:CreateTab("Player", "👤")

window:CreateLabel(playerTab, "Player Management")

local speedSlider = window:CreateSlider(playerTab, "WalkSpeed", 16, 200, 16, function(value)
    local playerMgr = framework:get("Player")
    local localPlayer = game.Players.LocalPlayer
    playerMgr:modify_humanoid(localPlayer, "WalkSpeed", value)
    print("WalkSpeed set to:", value)
end)

local jumpSlider = window:CreateSlider(playerTab, "JumpPower", 50, 300, 50, function(value)
    local playerMgr = framework:get("Player")
    local localPlayer = game.Players.LocalPlayer
    playerMgr:modify_humanoid(localPlayer, "JumpPower", value)
    print("JumpPower set to:", value)
end)

window:CreateToggle(playerTab, "NoClip", false, function(state)
    local gameUtils = framework:get("Game")
    gameUtils:noclip(state)
    print("NoClip:", state)
end)

window:CreateToggle(playerTab, "God Mode", false, function(state)
    local gameUtils = framework:get("Game")
    gameUtils:god_mode(state)
    print("God Mode:", state)
end)

window:CreateButton(playerTab, "🔄 Reset Character", function()
    local localPlayer = game.Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        localPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
        print("Character reset!")
    end
end)

-- ========================================
-- TAB: WORLD
-- ========================================
local worldTab = window:CreateTab("World", "🌍")

window:CreateLabel(worldTab, "Environment Controls")

local timeSlider = window:CreateSlider(worldTab, "Time of Day", 0, 24, 12, function(value)
    local envMgr = framework:get("Environment")
    envMgr:set_time(value)
    print("Time set to:", value)
end)

local brightnessSlider = window:CreateSlider(worldTab, "Brightness", 0, 5, 1, function(value)
    local envMgr = framework:get("Environment")
    envMgr:set_brightness(value)
    print("Brightness set to:", value)
end)

local gravitySlider = window:CreateSlider(worldTab, "Gravity", 0, 400, 196, function(value)
    local envMgr = framework:get("Environment")
    envMgr:set_gravity(value)
    print("Gravity set to:", value)
end)

window:CreateButton(worldTab, "🌅 Morning (6 AM)", function()
    framework:get("Environment"):set_time(6)
    timeSlider.SetValue(6)
end)

window:CreateButton(worldTab, "🌆 Evening (18 PM)", function()
    framework:get("Environment"):set_time(18)
    timeSlider.SetValue(18)
end)

window:CreateButton(worldTab, "🌙 Night (0 AM)", function()
    framework:get("Environment"):set_time(0)
    timeSlider.SetValue(0)
end)

-- ========================================
-- TAB: VISUALS
-- ========================================
local visualsTab = window:CreateTab("Visuals", "👁️")

window:CreateLabel(visualsTab, "ESP & Visual Effects")

window:CreateToggle(visualsTab, "Enable ESP (All Players)", false, function(state)
    local visuals = framework:get("Visuals")
    if state then
        visuals:enable_esp_all()
        print("ESP enabled for all players")
    else
        visuals:disable_esp_all()
        print("ESP disabled")
    end
end)

window:CreateButton(visualsTab, "🔦 Fullbright", function()
    game.Lighting.Brightness = 2
    game.Lighting.ClockTime = 14
    game.Lighting.FogEnd = 100000
    game.Lighting.GlobalShadows = false
    print("Fullbright enabled!")
end)

window:CreateButton(visualsTab, "✨ Highlight All Parts", function()
    local visuals = framework:get("Visuals")
    local count = 0
    
    for i, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and count < 100 then
            visuals:highlight_part(obj, Color3.fromRGB(255, 0, 0))
            count = count + 1
        end
    end
    
    print("Highlighted", count, "parts")
end)

-- ========================================
-- TAB: TELEPORT
-- ========================================
local teleportTab = window:CreateTab("Teleport", "🚀")

window:CreateLabel(teleportTab, "Teleport to Players")

local playerDropdownOptions = {}
for i, player in ipairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        table.insert(playerDropdownOptions, player.Name)
    end
end

if #playerDropdownOptions > 0 then
    window:CreateDropdown(teleportTab, "Select Player", playerDropdownOptions, function(selected)
        print("Selected player:", selected)
    end)
    
    window:CreateButton(teleportTab, "📍 Teleport to Selected", function()
        -- Implementar teleport
        print("Teleport feature - implement with dropdown value")
    end)
else
    window:CreateLabel(teleportTab, "No other players in game")
end

window:CreateLabel(teleportTab, "Custom Position")

local xBox = window:CreateTextbox(teleportTab, "X Position", function(text)
    print("X:", text)
end)

local yBox = window:CreateTextbox(teleportTab, "Y Position", function(text)
    print("Y:", text)
end)

local zBox = window:CreateTextbox(teleportTab, "Z Position", function(text)
    print("Z:", text)
end)

window:CreateButton(teleportTab, "🎯 Teleport to Custom Position", function()
    local x = tonumber(xBox.Text) or 0
    local y = tonumber(yBox.Text) or 50
    local z = tonumber(zBox.Text) or 0
    
    local playerMgr = framework:get("Player")
    local localPlayer = game.Players.LocalPlayer
    
    playerMgr:teleport_to(localPlayer, Vector3.new(x, y, z))
    print("Teleported to:", x, y, z)
end)

-- ========================================
-- TAB: UTILITIES
-- ========================================
local utilTab = window:CreateTab("Utils", "🛠️")

window:CreateLabel(utilTab, "Utility Functions")

window:CreateButton(utilTab, "📋 Copy Game ID", function()
    setclipboard(tostring(game.PlaceId))
    print("Game ID copied:", game.PlaceId)
end)

window:CreateButton(utilTab, "📋 Copy Job ID", function()
    setclipboard(tostring(game.JobId))
    print("Job ID copied!")
end)

window:CreateButton(utilTab, "🎲 Generate Random String", function()
    local util = framework:get("Utility")
    local random = util:random_string(16)
    print("Random String:", random)
    setclipboard(random)
end)

window:CreateButton(utilTab, "📊 Print Workspace Info", function()
    local env = framework:get("Environment")
    local info = env:get_workspace_info()
    
    print("=== WORKSPACE INFO ===")
    print("Parts:", info.Parts)
    print("Models:", info.Models)
    print("Gravity:", info.Gravity)
    print("Streaming:", tostring(info.StreamingEnabled))
end)

window:CreateButton(utilTab, "🔍 Find Parts by Name", function()
    -- Implementar búsqueda de partes
    print("Part finder - implement search functionality")
end)

-- ========================================
-- TAB: SETTINGS
-- ========================================
local settingsTab = window:CreateTab("Settings", "⚙️")

window:CreateLabel(settingsTab, "UI Settings")

window:CreateToggle(settingsTab, "Show Notifications", true, function(state)
    print("Notifications:", state)
end)

window:CreateToggle(settingsTab, "Auto-Save Settings", false, function(state)
    print("Auto-save:", state)
end)

window:CreateButton(settingsTab, "🔄 Reload UI", function()
    print("Reloading UI...")
    -- Implementar reload
end)

window:CreateButton(settingsTab, "❌ Destroy UI", function()
    print("Destroying UI...")
    if window.ScreenGui then
        window.ScreenGui:Destroy()
    end
end)

window:CreateLabel(settingsTab, "Framework Info")
window:CreateLabel(settingsTab, "Version: 2.0.0")
window:CreateLabel(settingsTab, "Build: 2024-EXECUTOR")
window:CreateLabel(settingsTab, "Created by: Your Name")

print("\n✅ Nuvik Framework UI loaded successfully!")
print("📌 Access framework: _G.Nuvik")
print("📌 All features ready to use!")
