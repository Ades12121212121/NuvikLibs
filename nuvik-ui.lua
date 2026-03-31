--[[
    NUVIK UI LIBRARY - COMPACT VERSION
    Uses framework functions to minimize code
]]

local UI = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Theme
local T = {
    BG = Color3.fromRGB(20,20,25),
    SF = Color3.fromRGB(30,30,35),
    PR = Color3.fromRGB(88,101,242),
    TX = Color3.fromRGB(255,255,255),
    ER = Color3.fromRGB(240,71,71),
    WN = Color3.fromRGB(250,166,26),
    SC = Color3.fromRGB(67,181,129)
}

local function tw(o,p,d) TweenService:Create(o,TweenInfo.new(d or 0.2),p):Play() end
local function drag(f,h)
    local d,m,fp
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            d,m,fp = true,i.Position,f.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - m
            tw(f,{Position=UDim2.new(fp.X.Scale,fp.X.Offset+delta.X,fp.Y.Scale,fp.Y.Offset+delta.Y)},0.1)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end
    end)
end

function UI:Window(cfg)
    local s = {tabs={}}
    
    s.sg = Instance.new("ScreenGui",game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui"))
    s.sg.Name = "NuvikUI"
    
    s.m = Instance.new("Frame",s.sg)
    s.m.Size = cfg.Size or UDim2.new(0,550,0,400)
    s.m.Position = UDim2.new(0.5,0,0.5,0)
    s.m.AnchorPoint = Vector2.new(0.5,0.5)
    s.m.BackgroundColor3 = T.BG
    s.m.BorderSizePixel = 0
    Instance.new("UICorner",s.m).CornerRadius = UDim.new(0,10)
    
    s.tb = Instance.new("Frame",s.m)
    s.tb.Size = UDim2.new(1,0,0,40)
    s.tb.BackgroundColor3 = T.SF
    s.tb.BorderSizePixel = 0
    Instance.new("UICorner",s.tb).CornerRadius = UDim.new(0,10)
    
    local fix = Instance.new("Frame",s.tb)
    fix.Size = UDim2.new(1,0,0,10)
    fix.Position = UDim2.new(0,0,1,-10)
    fix.BackgroundColor3 = T.SF
    fix.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel",s.tb)
    title.Size = UDim2.new(0,300,1,0)
    title.Position = UDim2.new(0,15,0,0)
    title.BackgroundTransparency = 1
    title.Text = cfg.Title or "Nuvik"
    title.TextColor3 = T.TX
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local close = Instance.new("TextButton",s.tb)
    close.Size = UDim2.new(0,25,0,25)
    close.Position = UDim2.new(1,-35,0,7.5)
    close.BackgroundColor3 = T.ER
    close.Text = "×"
    close.TextSize = 16
    close.TextColor3 = T.TX
    close.Font = Enum.Font.GothamBold
    close.BorderSizePixel = 0
    Instance.new("UICorner",close).CornerRadius = UDim.new(0,5)
    close.MouseButton1Click:Connect(function() s.sg:Destroy() end)
    
    s.tc = Instance.new("Frame",s.m)
    s.tc.Size = UDim2.new(0,120,1,-50)
    s.tc.Position = UDim2.new(0,10,0,45)
    s.tc.BackgroundColor3 = T.SF
    s.tc.BorderSizePixel = 0
    Instance.new("UICorner",s.tc).CornerRadius = UDim.new(0,8)
    local tl = Instance.new("UIListLayout",s.tc)
    tl.Padding = UDim.new(0,5)
    local tp = Instance.new("UIPadding",s.tc)
    tp.PaddingTop = UDim.new(0,10)
    tp.PaddingLeft = UDim.new(0,5)
    tp.PaddingRight = UDim.new(0,5)
    
    s.cc = Instance.new("Frame",s.m)
    s.cc.Size = UDim2.new(1,-140,1,-50)
    s.cc.Position = UDim2.new(0,135,0,45)
    s.cc.BackgroundTransparency = 1
    s.cc.BorderSizePixel = 0
    
    drag(s.m,s.tb)
    s.m.Size = UDim2.new(0,0,0,0)
    tw(s.m,{Size=cfg.Size or UDim2.new(0,550,0,400)},0.5)
    
    function s:Tab(n,i)
        local t = {}
        
        t.b = Instance.new("TextButton",s.tc)
        t.b.Size = UDim2.new(1,0,0,32)
        t.b.BackgroundColor3 = T.BG
        t.b.Text = " "..i.." "..n
        t.b.TextColor3 = T.TX
        t.b.Font = Enum.Font.GothamSemibold
        t.b.TextSize = 12
        t.b.TextXAlignment = Enum.TextXAlignment.Left
        t.b.BorderSizePixel = 0
        Instance.new("UICorner",t.b).CornerRadius = UDim.new(0,6)
        local pad = Instance.new("UIPadding",t.b)
        pad.PaddingLeft = UDim.new(0,10)
        
        t.c = Instance.new("ScrollingFrame",s.cc)
        t.c.Size = UDim2.new(1,0,1,0)
        t.c.BackgroundTransparency = 1
        t.c.BorderSizePixel = 0
        t.c.ScrollBarThickness = 4
        t.c.Visible = false
        t.c.CanvasSize = UDim2.new(0,0,0,0)
        local cl = Instance.new("UIListLayout",t.c)
        cl.Padding = UDim.new(0,6)
        cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            t.c.CanvasSize = UDim2.new(0,0,0,cl.AbsoluteContentSize.Y+10)
        end)
        local cp = Instance.new("UIPadding",t.c)
        cp.PaddingTop = UDim.new(0,5)
        cp.PaddingLeft = UDim.new(0,5)
        cp.PaddingRight = UDim.new(0,5)
        
        t.b.MouseButton1Click:Connect(function()
            for _,tab in pairs(s.tabs) do
                tab.c.Visible = false
                tw(tab.b,{BackgroundColor3=T.BG})
            end
            t.c.Visible = true
            tw(t.b,{BackgroundColor3=T.PR})
        end)
        
        function t:Button(tx,cb)
            local b = Instance.new("TextButton",t.c)
            b.Size = UDim2.new(1,-10,0,32)
            b.BackgroundColor3 = T.PR
            b.Text = tx
            b.TextColor3 = T.TX
            b.Font = Enum.Font.GothamSemibold
            b.TextSize = 12
            b.BorderSizePixel = 0
            Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
            b.MouseButton1Click:Connect(cb or function()end)
            b.MouseEnter:Connect(function()tw(b,{BackgroundColor3=Color3.fromRGB(100,113,255)})end)
            b.MouseLeave:Connect(function()tw(b,{BackgroundColor3=T.PR})end)
            return b
        end
        
        function t:Toggle(tx,d,cb)
            local tog = d or false
            local f = Instance.new("Frame",t.c)
            f.Size = UDim2.new(1,-10,0,32)
            f.BackgroundColor3 = T.SF
            f.BorderSizePixel = 0
            Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
            
            local l = Instance.new("TextLabel",f)
            l.Size = UDim2.new(1,-50,1,0)
            l.Position = UDim2.new(0,10,0,0)
            l.BackgroundTransparency = 1
            l.Text = tx
            l.TextColor3 = T.TX
            l.Font = Enum.Font.Gotham
            l.TextSize = 11
            l.TextXAlignment = Enum.TextXAlignment.Left
            
            local b = Instance.new("TextButton",f)
            b.Size = UDim2.new(0,38,0,18)
            b.Position = UDim2.new(1,-43,0.5,-9)
            b.BackgroundColor3 = tog and T.SC or Color3.fromRGB(60,60,65)
            b.Text = ""
            b.BorderSizePixel = 0
            Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
            
            local c = Instance.new("Frame",b)
            c.Size = UDim2.new(0,14,0,14)
            c.Position = tog and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            c.BackgroundColor3 = T.TX
            c.BorderSizePixel = 0
            Instance.new("UICorner",c).CornerRadius = UDim.new(1,0)
            
            b.MouseButton1Click:Connect(function()
                tog = not tog
                tw(b,{BackgroundColor3=tog and T.SC or Color3.fromRGB(60,60,65)})
                tw(c,{Position=tog and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
                if cb then cb(tog) end
            end)
            
            return {Set=function(v)tog=v b.BackgroundColor3=v and T.SC or Color3.fromRGB(60,60,65) c.Position=v and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)end,Get=function()return tog end}
        end
        
        function t:Slider(tx,mn,mx,d,cb)
            local v = d or mn
            local f = Instance.new("Frame",t.c)
            f.Size = UDim2.new(1,-10,0,45)
            f.BackgroundColor3 = T.SF
            f.BorderSizePixel = 0
            Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
            
            local l = Instance.new("TextLabel",f)
            l.Size = UDim2.new(1,-60,0,15)
            l.Position = UDim2.new(0,10,0,5)
            l.BackgroundTransparency = 1
            l.Text = tx
            l.TextColor3 = T.TX
            l.Font = Enum.Font.Gotham
            l.TextSize = 11
            l.TextXAlignment = Enum.TextXAlignment.Left
            
            local vl = Instance.new("TextLabel",f)
            vl.Size = UDim2.new(0,50,0,15)
            vl.Position = UDim2.new(1,-55,0,5)
            vl.BackgroundTransparency = 1
            vl.Text = tostring(v)
            vl.TextColor3 = T.PR
            vl.Font = Enum.Font.GothamBold
            vl.TextSize = 11
            vl.TextXAlignment = Enum.TextXAlignment.Right
            
            local sb = Instance.new("Frame",f)
            sb.Size = UDim2.new(1,-20,0,4)
            sb.Position = UDim2.new(0,10,0,28)
            sb.BackgroundColor3 = Color3.fromRGB(50,50,55)
            sb.BorderSizePixel = 0
            Instance.new("UICorner",sb).CornerRadius = UDim.new(1,0)
            
            local sf = Instance.new("Frame",sb)
            sf.Size = UDim2.new((v-mn)/(mx-mn),0,1,0)
            sf.BackgroundColor3 = T.PR
            sf.BorderSizePixel = 0
            Instance.new("UICorner",sf).CornerRadius = UDim.new(1,0)
            
            local dr = false
            sb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true end end)
            sb.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
            UIS.InputChanged:Connect(function(i)
                if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
                    local p=(i.Position.X-sb.AbsolutePosition.X)/sb.AbsoluteSize.X
                    p=math.clamp(p,0,1)
                    v=math.floor(mn+(mx-mn)*p)
                    vl.Text=tostring(v)
                    sf.Size=UDim2.new(p,0,1,0)
                    if cb then cb(v)end
                end
            end)
            
            return {Set=function(val)v=math.clamp(val,mn,mx)vl.Text=tostring(v)sf.Size=UDim2.new((v-mn)/(mx-mn),0,1,0)end,Get=function()return v end}
        end
        
        function t:Textbox(ph,cb)
            local f = Instance.new("Frame",t.c)
            f.Size = UDim2.new(1,-10,0,32)
            f.BackgroundColor3 = T.SF
            f.BorderSizePixel = 0
            Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
            
            local tb = Instance.new("TextBox",f)
            tb.Size = UDim2.new(1,-20,1,0)
            tb.Position = UDim2.new(0,10,0,0)
            tb.BackgroundTransparency = 1
            tb.PlaceholderText = ph
            tb.Text = ""
            tb.TextColor3 = T.TX
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 11
            tb.TextXAlignment = Enum.TextXAlignment.Left
            tb.FocusLost:Connect(function(e)if e and cb then cb(tb.Text)end end)
            return tb
        end
        
        function t:Label(tx)
            local l = Instance.new("TextLabel",t.c)
            l.Size = UDim2.new(1,-10,0,20)
            l.BackgroundTransparency = 1
            l.Text = tx
            l.TextColor3 = Color3.fromRGB(180,180,190)
            l.Font = Enum.Font.Gotham
            l.TextSize = 11
            l.TextXAlignment = Enum.TextXAlignment.Left
            return l
        end
        
        table.insert(s.tabs,t)
        if #s.tabs==1 then t.b.MouseButton1Click:Fire() end
        return t
    end
    
    return s
end

return UI
