--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          NUVIK UI LIBRARY V1.0 - GITHUB VERSION           ║
    ║                  Modern UI for Executors                  ║
    ╚═══════════════════════════════════════════════════════════╝
    
    GitHub: TU_USUARIO/nuvik-framework
    File: nuvik-ui.lua
]]

local NuvikUI = {}
NuvikUI.__index = NuvikUI

-- ========================================
-- SERVICIOS
-- ========================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ========================================
-- UTILIDADES
-- ========================================
local function tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function createRipple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

-- ========================================
-- COLORES TEMA
-- ========================================
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 35),
    Primary = Color3.fromRGB(88, 101, 242),
    Secondary = Color3.fromRGB(114, 137, 218),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(240, 71, 71),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    Border = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(255, 73, 130)
}

-- ========================================
-- CREAR VENTANA PRINCIPAL
-- ========================================
function NuvikUI:CreateWindow(config)
    local self = setmetatable({}, NuvikUI)
    
    config = config or {}
    self.title = config.Title or "Nuvik Framework"
    self.version = config.Version or "v2.0"
    self.size = config.Size or UDim2.new(0, 550, 0, 400)
    
    -- Contenedor principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NuvikUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    
    -- Intentar poner en CoreGui, si falla usar PlayerGui
    local success = pcall(function()
        self.ScreenGui.Parent = CoreGui
    end)
    if not success then
        self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Frame principal
    self.Main = Instance.new("Frame")
    self.Main.Name = "Main"
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.Size = self.size
    self.Main.BackgroundColor3 = Theme.Background
    self.Main.BorderSizePixel = 0
    self.Main.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = self.Main
    
    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    shadow.Parent = self.Main
    
    -- Barra superior
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, 45)
    self.TopBar.BackgroundColor3 = Theme.Surface
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.Main
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = self.TopBar
    
    -- Fix para esquinas inferiores
    local topBarFix = Instance.new("Frame")
    topBarFix.Size = UDim2.new(1, 0, 0, 12)
    topBarFix.Position = UDim2.new(0, 0, 1, -12)
    topBarFix.BackgroundColor3 = Theme.Surface
    topBarFix.BorderSizePixel = 0
    topBarFix.Parent = self.TopBar
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Size = UDim2.new(0, 300, 1, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = self.title
    title.TextColor3 = Theme.Text
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.TopBar
    
    -- Versión
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "Version"
    versionLabel.Position = UDim2.new(0, 15, 0, 20)
    versionLabel.Size = UDim2.new(0, 100, 0, 20)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Text = self.version
    versionLabel.TextColor3 = Theme.TextSecondary
    versionLabel.TextSize = 11
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = self.TopBar
    
    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.Position = UDim2.new(1, -10, 0, 10)
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.BackgroundColor3 = Theme.Error
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextColor3 = Theme.Text
    closeButton.TextSize = 18
    closeButton.Parent = self.TopBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        tween(self.Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Botón minimizar
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.AnchorPoint = Vector2.new(1, 0)
    minimizeButton.Position = UDim2.new(1, -40, 0, 10)
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.BackgroundColor3 = Theme.Warning
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Theme.Text
    minimizeButton.TextSize = 18
    minimizeButton.Parent = self.TopBar
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeButton
    
    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(self.Main, {
            Size = minimized and UDim2.new(0, 550, 0, 45) or self.size
        }, 0.3)
    end)
    
    -- Contenedor de pestañas
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Position = UDim2.new(0, 10, 0, 55)
    self.TabContainer.Size = UDim2.new(0, 120, 1, -65)
    self.TabContainer.BackgroundColor3 = Theme.Surface
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.Main
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = self.TabContainer
    
    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 5)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = self.TabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.Parent = self.TabContainer
    
    -- Contenedor de contenido
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Position = UDim2.new(0, 140, 0, 55)
    self.ContentContainer.Size = UDim2.new(1, -150, 1, -65)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.Main
    
    -- Hacer draggable
    makeDraggable(self.Main, self.TopBar)
    
    -- Animación de entrada
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    tween(self.Main, {Size = self.size}, 0.5, Enum.EasingStyle.Back)
    
    self.tabs = {}
    self.currentTab = nil
    
    return self
end

-- ========================================
-- CREAR PESTAÑA
-- ========================================
function NuvikUI:CreateTab(name, icon)
    local tab = {}
    tab.name = name
    tab.icon = icon or "📁"
    
    -- Botón de pestaña
    tab.button = Instance.new("TextButton")
    tab.button.Name = name
    tab.button.Size = UDim2.new(1, 0, 0, 35)
    tab.button.BackgroundColor3 = Theme.Background
    tab.button.BorderSizePixel = 0
    tab.button.Font = Enum.Font.GothamSemibold
    tab.button.Text = "  " .. tab.icon .. "  " .. name
    tab.button.TextColor3 = Theme.TextSecondary
    tab.button.TextSize = 13
    tab.button.TextXAlignment = Enum.TextXAlignment.Left
    tab.button.Parent = self.TabContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = tab.button
    
    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingLeft = UDim.new(0, 10)
    buttonPadding.Parent = tab.button
    
    -- Contenedor de contenido de la pestaña
    tab.container = Instance.new("ScrollingFrame")
    tab.container.Name = name .. "Content"
    tab.container.Size = UDim2.new(1, 0, 1, 0)
    tab.container.BackgroundTransparency = 1
    tab.container.BorderSizePixel = 0
    tab.container.ScrollBarThickness = 4
    tab.container.ScrollBarImageColor3 = Theme.Primary
    tab.container.Visible = false
    tab.container.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.container.Parent = self.ContentContainer
    
    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 8)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = tab.container
    
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.container.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
    end)
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 5)
    contentPadding.PaddingBottom = UDim.new(0, 5)
    contentPadding.PaddingLeft = UDim.new(0, 5)
    contentPadding.PaddingRight = UDim.new(0, 5)
    contentPadding.Parent = tab.container
    
    -- Click handler
    tab.button.MouseButton1Click:Connect(function()
        -- Ocultar todas las pestañas
        for _, t in pairs(self.tabs) do
            t.container.Visible = false
            tween(t.button, {
                BackgroundColor3 = Theme.Background,
                TextColor3 = Theme.TextSecondary
            }, 0.2)
        end
        
        -- Mostrar pestaña actual
        tab.container.Visible = true
        tween(tab.button, {
            BackgroundColor3 = Theme.Primary,
            TextColor3 = Theme.Text
        }, 0.2)
        
        self.currentTab = tab
    end)
    
    -- Hover effects
    tab.button.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            tween(tab.button, {BackgroundColor3 = Theme.Border}, 0.2)
        end
    end)
    
    tab.button.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            tween(tab.button, {BackgroundColor3 = Theme.Background}, 0.2)
        end
    end)
    
    table.insert(self.tabs, tab)
    
    -- Si es la primera pestaña, activarla
    if #self.tabs == 1 then
        tab.button.MouseButton1Click:Fire()
    end
    
    tab.elements = {}
    return tab
end

-- ========================================
-- ELEMENTOS DE UI
-- ========================================

-- BOTÓN
function NuvikUI:CreateButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(1, -10, 0, 35)
    button.BackgroundColor3 = Theme.Primary
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Theme.Text
    button.TextSize = 13
    button.ClipsDescendants = true
    button.Parent = tab.container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = mousePos.X - pos.X
        local relativeY = mousePos.Y - pos.Y
        
        createRipple(button, relativeX, relativeY)
        
        if callback then
            callback()
        end
    end)
    
    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = Theme.Secondary}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = Theme.Primary}, 0.2)
    end)
    
    return button
end

-- TOGGLE
function NuvikUI:CreateToggle(tab, text, default, callback)
    local toggled = default or false
    
    local container = Instance.new("Frame")
    container.Name = text
    container.Size = UDim2.new(1, -10, 0, 35)
    container.BackgroundColor3 = Theme.Surface
    container.BorderSizePixel = 0
    container.Parent = tab.container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.AnchorPoint = Vector2.new(1, 0.5)
    toggleButton.Position = UDim2.new(1, -10, 0.5, 0)
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.BackgroundColor3 = toggled and Theme.Success or Theme.Border
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local circle = Instance.new("Frame")
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.BackgroundColor3 = Theme.Text
    circle.BorderSizePixel = 0
    circle.Parent = toggleButton
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        
        tween(toggleButton, {
            BackgroundColor3 = toggled and Theme.Success or Theme.Border
        }, 0.2)
        
        tween(circle, {
            Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.2)
        
        if callback then
            callback(toggled)
        end
    end)
    
    return {
        container = container,
        SetValue = function(value)
            toggled = value
            toggleButton.BackgroundColor3 = toggled and Theme.Success or Theme.Border
            circle.Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        end,
        GetValue = function()
            return toggled
        end
    }
end

-- SLIDER
function NuvikUI:CreateSlider(tab, text, min, max, default, callback)
    local value = default or min
    
    local container = Instance.new("Frame")
    container.Name = text
    container.Size = UDim2.new(1, -10, 0, 50)
    container.BackgroundColor3 = Theme.Surface
    container.BorderSizePixel = 0
    container.Parent = tab.container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 12, 0, 5)
    label.Size = UDim2.new(1, -24, 0, 15)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.Size = UDim2.new(0, 50, 0, 15)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = Theme.Primary
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Position = UDim2.new(0, 12, 0, 30)
    sliderBack.Size = UDim2.new(1, -24, 0, 6)
    sliderBack.BackgroundColor3 = Theme.Border
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = container
    
    local sliderBackCorner = Instance.new("UICorner")
    sliderBackCorner.CornerRadius = UDim.new(1, 0)
    sliderBackCorner.Parent = sliderBack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBack
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local dragging = false
    
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = (input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            value = math.floor(min + (max - min) * pos)
            
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            
            if callback then
                callback(value)
            end
        end
    end)
    
    return {
        container = container,
        SetValue = function(val)
            value = math.clamp(val, min, max)
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        end,
        GetValue = function()
            return value
        end
    }
end

-- TEXTBOX
function NuvikUI:CreateTextbox(tab, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 35)
    container.BackgroundColor3 = Theme.Surface
    container.BorderSizePixel = 0
    container.Parent = tab.container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, -20, 1, 0)
    textbox.Position = UDim2.new(0, 10, 0, 0)
    textbox.BackgroundTransparency = 1
    textbox.Font = Enum.Font.Gotham
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = Theme.TextSecondary
    textbox.Text = ""
    textbox.TextColor3 = Theme.Text
    textbox.TextSize = 12
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.ClearTextOnFocus = false
    textbox.Parent = container
    
    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(textbox.Text)
        end
    end)
    
    return textbox
end

-- LABEL
function NuvikUI:CreateLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.Parent = label
    
    return label
end

-- DROPDOWN
function NuvikUI:CreateDropdown(tab, text, options, callback)
    local opened = false
    local selected = options[1] or "None"
    
    local container = Instance.new("Frame")
    container.Name = text
    container.Size = UDim2.new(1, -10, 0, 35)
    container.BackgroundColor3 = Theme.Surface
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = tab.container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Font = Enum.Font.Gotham
    button.Text = text .. ": " .. selected
    button.TextColor3 = Theme.Text
    button.TextSize = 12
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = container
    
    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingLeft = UDim.new(0, 12)
    buttonPadding.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -10, 0.5, 0)
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.Primary
    arrow.TextSize = 10
    arrow.Parent = button
    
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Position = UDim2.new(0, 0, 1, 5)
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.BackgroundColor3 = Theme.Background
    optionsContainer.BorderSizePixel = 0
    optionsContainer.ClipsDescendants = true
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 10
    optionsContainer.Parent = container
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = optionsContainer
    
    local optionsList = Instance.new("UIListLayout")
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Parent = optionsContainer
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = Theme.Background
        optionButton.BorderSizePixel = 0
        optionButton.Font = Enum.Font.Gotham
        optionButton.Text = option
        optionButton.TextColor3 = Theme.Text
        optionButton.TextSize = 11
        optionButton.Parent = optionsContainer
        
        optionButton.MouseButton1Click:Connect(function()
            selected = option
            button.Text = text .. ": " .. selected
            opened = false
            optionsContainer.Visible = false
            tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            tween(arrow, {Rotation = 0}, 0.2)
            
            if callback then
                callback(selected)
            end
        end)
        
        optionButton.MouseEnter:Connect(function()
            tween(optionButton, {BackgroundColor3 = Theme.Surface}, 0.2)
        end)
        
        optionButton.MouseLeave:Connect(function()
            tween(optionButton, {BackgroundColor3 = Theme.Background}, 0.2)
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        opened = not opened
        optionsContainer.Visible = opened
        
        if opened then
            tween(optionsContainer, {Size = UDim2.new(1, 0, 0, #options * 30)}, 0.3)
            tween(arrow, {Rotation = 180}, 0.2)
        else
            tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            tween(arrow, {Rotation = 0}, 0.2)
        end
    end)
    
    return {
        container = container,
        SetValue = function(value)
            selected = value
            button.Text = text .. ": " .. selected
        end,
        GetValue = function()
            return selected
        end
    }
end

return NuvikUI
