--[[
    NUVIK FRAMEWORK LOADER
    One-click setup with UI
]]

print("🔄 Loading Nuvik...")

-- Load Framework
local fw = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ades12121212121/NuvikLibs/refs/heads/main/nuvik-framework.lua"))()
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ades12121212121/NuvikLibs/refs/heads/main/nuvik-ui.lua"))()

print("✅ Loaded!")

-- Create UI
local w = ui:Window({Title="Nuvik Framework",Size=UDim2.new(0,550,0,380)})

-- HOME TAB
local h = w:Tab("Home","🏠")
h:Label("Welcome to Nuvik Framework v2.0")
h:Button("📊 Framework Stats",function()
    local s = _G.Nuvik:get_stats()
    print("=== STATS ===")
    print("Uptime:",s.uptime_str)
    print("Memory:",string.format("%.2fKB",s.memory))
    _G.Nuvik:get("Notification"):success("Stats printed to console!")
end)

-- PLAYER TAB
local p = w:Tab("Player","👤")
p:Slider("WalkSpeed",16,200,16,function(v)_G.Nuvik:get("Player"):modify(game.Players.LocalPlayer,"WalkSpeed",v)end)
p:Slider("JumpPower",50,300,50,function(v)_G.Nuvik:get("Player"):modify(game.Players.LocalPlayer,"JumpPower",v)end)
p:Toggle("NoClip",false,function(v)_G.Nuvik:get("Game"):noclip(v)end)
p:Toggle("God Mode",false,function(v)_G.Nuvik:get("Game"):god_mode(v)end)
p:Toggle("Infinite Jump",false,function(v)_G.Nuvik:get("Game"):infinite_jump(v)end)
p:Button("💀 Kill Character",function()_G.Nuvik:get("Player"):kill(game.Players.LocalPlayer)end)
p:Button("🔄 Respawn",function()_G.Nuvik:get("Player"):respawn(game.Players.LocalPlayer)end)

-- WORLD TAB
local world = w:Tab("World","🌍")
world:Slider("Time",0,24,12,function(v)_G.Nuvik:get("Environment"):set_time(v)end)
world:Slider("Brightness",0,5,1,function(v)_G.Nuvik:get("Environment"):set_brightness(v)end)
world:Slider("Gravity",0,400,196,function(v)_G.Nuvik:get("Environment"):set_gravity(v)end)
world:Button("🔦 Fullbright",function()_G.Nuvik:get("Environment"):fullbright()end)
world:Button("🌊 Clear Terrain",function()_G.Nuvik:get("Environment"):clear_terrain()end)

-- VISUAL TAB
local vis = w:Tab("Visual","👁️")
vis:Toggle("ESP All Players",false,function(v)
    if v then _G.Nuvik:get("Visual"):enable_esp_all()
    else _G.Nuvik:get("Visual"):disable_esp_all()end
end)
vis:Button("✨ Highlight Parts (100)",function()
    local c=0
    for _,o in ipairs(workspace:GetDescendants())do
        if o:IsA("BasePart")and c<100 then
            _G.Nuvik:get("Visual"):highlight_part(o,Color3.fromRGB(255,0,0))
            c=c+1
        end
    end
    _G.Nuvik:get("Notification"):success("Highlighted "..c.." parts")
end)
vis:Button("🧹 Clear Highlights",function()_G.Nuvik:get("Visual"):clear_highlights()end)

-- TELEPORT TAB
local tp = w:Tab("Teleport","🚀")
tp:Label("Teleport to Players")
local players = {}
for _,pl in ipairs(game.Players:GetPlayers())do
    if pl~=game.Players.LocalPlayer then table.insert(players,pl.Name)end
end
if #players>0 then
    local selected = players[1]
    tp:Button("TP to "..selected,function()
        local target = _G.Nuvik:get("Player"):find(selected)
        if target then
            _G.Nuvik:get("Player"):teleport_to_player(game.Players.LocalPlayer,target)
            _G.Nuvik:get("Notification"):success("Teleported to "..selected)
        end
    end)
end
tp:Label("Custom Position")
local x,y,z = 0,50,0
tp:Textbox("X",function(t)x=tonumber(t)or 0 end)
tp:Textbox("Y",function(t)y=tonumber(t)or 50 end)
tp:Textbox("Z",function(t)z=tonumber(t)or 0 end)
tp:Button("🎯 Go!",function()
    _G.Nuvik:get("Player"):teleport(game.Players.LocalPlayer,Vector3.new(x,y,z))
    _G.Nuvik:get("Notification"):success("Teleported!")
end)

-- MISC TAB
local misc = w:Tab("Misc","⚙️")
misc:Toggle("Anti-AFK",false,function(v)if v then _G.Nuvik:get("Game"):anti_afk()end end)
misc:Button("📋 Copy Game ID",function()setclipboard(tostring(game.PlaceId))_G.Nuvik:get("Notification"):info("Copied!")end)
misc:Button("🎲 Random String",function()
    local s = _G.Nuvik:get("Utility"):random_string(16)
    print("Random:",s)
    setclipboard(s)
    _G.Nuvik:get("Notification"):info("Copied to clipboard!")
end)

print("✅ UI Ready!")
_G.Nuvik:get("Notification"):success("Nuvik Framework Loaded!")
