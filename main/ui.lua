--[[
    ╔══════════════════════════════════════════════════════╗
    ║     MONOCHROME UI LIBRARY v4.0                      ║
    ║     - Input (Text box + Execute button)             ║
    ║     - Improved Selection (Option picker + Execute)  ║
    ║     - Label, Button, Toggle, Slider, Dropdown      ║
    ║     - Draggable, Minimizable, Closable             ║
    ║     - Respawn Proof, Mobile & Desktop Support      ║
    ╚══════════════════════════════════════════════════════╝
]]

local MonochromeUI = {}
MonochromeUI.__index = MonochromeUI

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    PrimaryColor = Color3.fromRGB(20, 20, 20),
    SecondaryColor = Color3.fromRGB(30, 30, 30),
    AccentColor = Color3.fromRGB(40, 40, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    DimTextColor = Color3.fromRGB(150, 150, 150),
    BorderColor = Color3.fromRGB(50, 50, 50),
    ToggleOn = Color3.fromRGB(50, 50, 50),
    ToggleOff = Color3.fromRGB(25, 25, 25),
    SliderFill = Color3.fromRGB(80, 80, 80),
    NotificationColor = Color3.fromRGB(40, 40, 40),
    ExecuteColor = Color3.fromRGB(60, 60, 60),
    InputBgColor = Color3.fromRGB(25, 25, 25),
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function CreateTween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

-- Main Library Constructor
function MonochromeUI.new(title)
    local self = setmetatable({}, MonochromeUI)
    
    -- Main GUI
    self.MainGui = CreateInstance("ScreenGui", {
        Name = "MonochromeUI_" .. math.random(1000, 9999),
        Parent = (syn and syn.protect_gui and gethui) and gethui() or CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    
    -- Main Frame
    self.MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = self.MainGui,
        BackgroundColor3 = Settings.PrimaryColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Active = true,
        Draggable = false,
        ClipsDescendants = false,
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.MainFrame,
    })
    
    -- Top Bar
    self.TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        Parent = self.MainFrame,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        ZIndex = 2,
    })
    
    local TopBarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.TopBar,
    })
    
    local BottomCornerFix = CreateInstance("Frame", {
        Name = "BottomCornerFix",
        Parent = self.TopBar,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        ZIndex = 2,
    })
    
    -- Title Text
    self.TitleText = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = self.TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "Monochrome UI",
        TextColor3 = Settings.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    
    -- Minimize Button
    self.MinimizeButton = CreateInstance("TextButton", {
        Name = "Minimize",
        Parent = self.TopBar,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -105, 0.5, -10),
        Size = UDim2.new(0, 25, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "─",
        TextColor3 = Settings.TextColor,
        TextSize = 14,
        ZIndex = 3,
    })
    
    local MinimizeCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = self.MinimizeButton,
    })
    
    -- Close Button
    self.CloseButton = CreateInstance("TextButton", {
        Name = "Close",
        Parent = self.TopBar,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -70, 0.5, -10),
        Size = UDim2.new(0, 25, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = Settings.TextColor,
        TextSize = 14,
        ZIndex = 3,
    })
    
    local CloseCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = self.CloseButton,
    })
    
    -- Dragging System
    local dragging, dragInput, dragStart, startPos
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TopBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(self.MainFrame, TweenInfo.new(0.1), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    
    -- Minimize Functionality
    self.Minimized = false
    self.OriginalSize = self.MainFrame.Size
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            self.ContentFrame.Visible = false
            self.TabContainer.Visible = false
            self.TabPageContainer.Visible = false
            CreateTween(self.MainFrame, {Size = UDim2.new(0, 600, 0, 35)}, 0.3):Play()
            self.MinimizeButton.Text = "□"
        else
            self.ContentFrame.Visible = true
            self.TabContainer.Visible = true
            self.TabPageContainer.Visible = true
            CreateTween(self.MainFrame, {Size = self.OriginalSize}, 0.3):Play()
            self.MinimizeButton.Text = "─"
        end
    end)
    
    -- Close Functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    -- Content Container
    self.ContentFrame = CreateInstance("ScrollingFrame", {
        Name = "Content",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Settings.AccentColor,
        ZIndex = 1,
    })
    
    local ContentPadding = CreateInstance("UIPadding", {
        Parent = self.ContentFrame,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })
    
    self.Layout = CreateInstance("UIListLayout", {
        Parent = self.ContentFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
    
    -- Tab System
    self.TabContainer = CreateInstance("Frame", {
        Name = "Tabs",
        Parent = self.MainFrame,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 120, 1, -35),
        ZIndex = 1,
    })
    
    self.TabLayout = CreateInstance("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })
    
    self.TabPageContainer = CreateInstance("Frame", {
        Name = "TabPages",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 120, 0, 35),
        Size = UDim2.new(1, -120, 1, -35),
        ZIndex = 1,
    })
    
    -- Variables
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.Notifications = {}
    
    -- Auto-update canvas size
    self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    return self
end

-- ====================================
-- TAB CREATION
-- ====================================
function MonochromeUI:CreateTab(name)
    local tab = {}
    
    tab.Button = CreateInstance("TextButton", {
        Name = name .. "Tab",
        Parent = self.TabContainer,
        BackgroundColor3 = Settings.PrimaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 35),
        Position = UDim2.new(0, 5, 0, 0),
        Font = Enum.Font.GothamSemibold,
        Text = "  " .. name,
        TextColor3 = Settings.DimTextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    local TabCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = tab.Button,
    })
    
    tab.Page = CreateInstance("ScrollingFrame", {
        Name = name .. "Page",
        Parent = self.TabPageContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Settings.AccentColor,
        Visible = false,
        ScrollBarImageTransparency = 0.5,
    })
    
    local PagePadding = CreateInstance("UIPadding", {
        Parent = tab.Page,
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
    })
    
    tab.Layout = CreateInstance("UIListLayout", {
        Parent = tab.Page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
    
    tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Page.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + 10)
    end)
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

-- ====================================
-- SELECT TAB
-- ====================================
function MonochromeUI:SelectTab(tab)
    for _, t in pairs(self.Tabs) do
        t.Page.Visible = false
        t.Button.BackgroundColor3 = Settings.PrimaryColor
        t.Button.TextColor3 = Settings.DimTextColor
    end
    
    tab.Page.Visible = true
    tab.Button.BackgroundColor3 = Settings.AccentColor
    tab.Button.TextColor3 = Settings.TextColor
    self.CurrentTab = tab
end

-- ====================================
-- CREATE LABEL
-- ====================================
function MonochromeUI:CreateLabel(tab, text)
    local element = {}
    element.Type = "Label"
    
    element.Frame = CreateInstance("Frame", {
        Parent = tab.Page,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 35),
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.Frame,
    })
    
    element.TextLabel = CreateInstance("TextLabel", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Settings.DimTextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    table.insert(self.Elements, element)
    return element
end

-- ====================================
-- CREATE BUTTON
-- ====================================
function MonochromeUI:CreateButton(tab, name, callback)
    local element = {}
    element.Type = "Button"
    
    element.Frame = CreateInstance("TextButton", {
        Parent = tab.Page,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 35),
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 13,
        AutoButtonColor = false,
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.Frame,
    })
    
    element.Frame.MouseEnter:Connect(function()
        CreateTween(element.Frame, {BackgroundColor3 = Settings.AccentColor}, 0.2):Play()
    end)
    
    element.Frame.MouseLeave:Connect(function()
        CreateTween(element.Frame, {BackgroundColor3 = Settings.SecondaryColor}, 0.2):Play()
    end)
    
    element.Frame.MouseButton1Click:Connect(function()
        CreateTween(element.Frame, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1):Play()
        if callback then
            callback()
        end
        wait(0.1)
        CreateTween(element.Frame, {BackgroundColor3 = Settings.AccentColor}, 0.2):Play()
    end)
    
    table.insert(self.Elements, element)
    return element
end

-- ====================================
-- CREATE TOGGLE
-- ====================================
function MonochromeUI:CreateToggle(tab, name, default, callback)
    local element = {}
    element.Type = "Toggle"
    element.Value = default or false
    
    element.Frame = CreateInstance("Frame", {
        Parent = tab.Page,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 35),
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.Frame,
    })
    
    element.Label = CreateInstance("TextLabel", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    element.ToggleFrame = CreateInstance("Frame", {
        Parent = element.Frame,
        BackgroundColor3 = default and Settings.ToggleOn or Settings.ToggleOff,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -30, 0.5, -7),
        Size = UDim2.new(0, 20, 0, 14),
    })
    
    local ToggleCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = element.ToggleFrame,
    })
    
    element.ToggleDot = CreateInstance("Frame", {
        Parent = element.ToggleFrame,
        BackgroundColor3 = Settings.TextColor,
        BorderSizePixel = 0,
        Position = UDim2.new(default and 1 or 0, default and -10 or 2, 0.5, -4),
        Size = UDim2.new(0, 8, 0, 8),
    })
    
    local DotCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = element.ToggleDot,
    })
    
    local function UpdateToggle()
        element.Value = not element.Value
        if element.Value then
            CreateTween(element.ToggleDot, {Position = UDim2.new(1, -10, 0.5, -4)}, 0.2):Play()
            CreateTween(element.ToggleFrame, {BackgroundColor3 = Settings.ToggleOn}, 0.2):Play()
        else
            CreateTween(element.ToggleDot, {Position = UDim2.new(0, 2, 0.5, -4)}, 0.2):Play()
            CreateTween(element.ToggleFrame, {BackgroundColor3 = Settings.ToggleOff}, 0.2):Play()
        end
        if callback then
            callback(element.Value)
        end
    end
    
    element.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateToggle()
        end
    end)
    
    element.SetValue = function(value)
        element.Value = value
        if value then
            element.ToggleDot.Position = UDim2.new(1, -10, 0.5, -4)
            element.ToggleFrame.BackgroundColor3 = Settings.ToggleOn
        else
            element.ToggleDot.Position = UDim2.new(0, 2, 0.5, -4)
            element.ToggleFrame.BackgroundColor3 = Settings.ToggleOff
        end
        if callback then
            callback(element.Value)
        end
    end
    
    table.insert(self.Elements, element)
    return element
end

-- ====================================
-- CREATE SLIDER
-- ====================================
function MonochromeUI:CreateSlider(tab, name, min, max, default, callback)
    local element = {}
    element.Type = "Slider"
    element.Value = default or min
    element.Min = min
    element.Max = max
    
    element.Frame = CreateInstance("Frame", {
        Parent = tab.Page,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 50),
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.Frame,
    })
    
    element.Label = CreateInstance("TextLabel", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 18),
        Font = Enum.Font.GothamSemibold,
        Text = name .. ": " .. tostring(element.Value),
        TextColor3 = Settings.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    element.SliderBg = CreateInstance("Frame", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.PrimaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 28),
        Size = UDim2.new(1, -20, 0, 12),
    })
    
    local SliderBgCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = element.SliderBg,
    })
    
    local fillWidth = (element.Value - min) / (max - min)
    element.SliderFill = CreateInstance("Frame", {
        Parent = element.SliderBg,
        BackgroundColor3 = Settings.SliderFill,
        BorderSizePixel = 0,
        Size = UDim2.new(fillWidth, 0, 1, 0),
    })
    
    local SliderFillCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = element.SliderFill,
    })
    
    element.SliderDot = CreateInstance("Frame", {
        Parent = element.SliderFill,
        BackgroundColor3 = Settings.TextColor,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(1, 0.5),
    })
    
    local SliderDotCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = element.SliderDot,
    })
    
    local function UpdateSlider(input)
        local mousePos = input.Position.X
        local sliderPos = element.SliderBg.AbsolutePosition.X
        local sliderWidth = element.SliderBg.AbsoluteSize.X
        local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
        element.Value = math.floor(min + (max - min) * percent)
        element.Label.Text = name .. ": " .. tostring(element.Value)
        element.SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        if callback then
            callback(element.Value)
        end
    end
    
    element.SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlider(input)
        end
    end)
    
    element.SliderBg.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or input.UserInputType == Enum.UserInputType.Touch then
                UpdateSlider(input)
            end
        end
    end)
    
    element.SetValue = function(value)
        value = math.clamp(value, min, max)
        element.Value = value
        local percent = (value - min) / (max - min)
        element.Label.Text = name .. ": " .. tostring(value)
        element.SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        if callback then
            callback(element.Value)
        end
    end
    
    table.insert(self.Elements, element)
    return element
end

-- ====================================
-- CREATE DROPDOWN
-- ====================================
function MonochromeUI:CreateDropdown(tab, name, options, callback)
    local element = {}
    element.Type = "Dropdown"
    element.Value = options[1] or ""
    element.Options = options
    element.Expanded = false
    element.Buttons = {}
    
    element.Frame = CreateInstance("Frame", {
        Parent = tab.Page,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 35),
        ClipsDescendants = false,
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.Frame,
    })
    
    element.Button = CreateInstance("TextButton", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = name .. ": " .. element.Value,
        TextColor3 = Settings.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local Padding = CreateInstance("UIPadding", {
        Parent = element.Button,
        PaddingLeft = UDim.new(0, 10),
    })
    
    element.OptionsFrame = CreateInstance("ScrollingFrame", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.PrimaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 2),
        Size = UDim2.new(1, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Settings.DimTextColor,
        ZIndex = 10,
        Visible = false,
        ClipsDescendants = true,
    })
    
    local OptionsCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.OptionsFrame,
    })
    
    local OptionsLayout = CreateInstance("UIListLayout", {
        Parent = element.OptionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    })
    
    OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        element.OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 2)
    end)
    
    local function CreateOptionButtons()
        for _, btn in pairs(element.Buttons) do
            btn:Destroy()
        end
        element.Buttons = {}
        
        for _, option in pairs(options) do
            local optionButton = CreateInstance("TextButton", {
                Parent = element.OptionsFrame,
                BackgroundColor3 = Settings.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = "  " .. option,
                TextColor3 = Settings.DimTextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11,
            })
            
            optionButton.MouseButton1Click:Connect(function()
                element.Value = option
                element.Button.Text = name .. ": " .. option
                element:Toggle(false)
                if callback then
                    callback(option)
                end
            end)
            
            table.insert(element.Buttons, optionButton)
        end
    end
    
    function element:Toggle(state)
        if state == nil then
            state = not element.Expanded
        end
        element.Expanded = state
        
        if state then
            element.OptionsFrame.Visible = true
            local height = math.min(#options * 30 + #options - 1, 150)
            element.OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
            CreateTween(element.OptionsFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.2):Play()
        else
            CreateTween(element.OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):Play()
            wait(0.2)
            element.OptionsFrame.Visible = false
        end
    end
    
    element.Button.MouseButton1Click:Connect(function()
        element:Toggle()
    end)
    
    element.SetOptions = function(newOptions)
        options = newOptions
        element.Options = newOptions
        if not table.find(newOptions, element.Value) then
            element.Value = newOptions[1] or ""
            element.Button.Text = name .. ": " .. element.Value
        end
        CreateOptionButtons()
    end
    
    CreateOptionButtons()
    
    table.insert(self.Elements, element)
    return element
end

-- ====================================
-- CREATE SELECTION (IMPROVED!)
-- Option Picker with Execute Button
-- Now with better visuals and search capability
-- ====================================
function MonochromeUI:CreateSelection(tab, name, options, callback)
    local element = {}
    element.Type = "Selection"
    element.Value = options[1] or ""
    element.Options = options
    element.Expanded = false
    element.Buttons = {}
    
    -- Main Container (slightly taller for better spacing)
    element.Frame = CreateInstance("Frame", {
        Parent = tab.Page,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Size = UDim2.new(1, -10, 0, 75),
        ClipsDescendants = false,
        ZIndex = 1,
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = element.Frame,
    })
    
    -- Title Label with better positioning
    element.Label = CreateInstance("TextLabel", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 10),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    -- Selected option display
    element.SelectedText = CreateInstance("TextLabel", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(0.55, -6, 0, 14),
        Font = Enum.Font.Gotham,
        Text = "Selected: " .. element.Value,
        TextColor3 = Settings.DimTextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    -- Option Picker Button (Left side - improved design)
    element.PickerButton = CreateInstance("TextButton", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.PrimaryColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 12, 0, 44),
        Size = UDim2.new(0.58, -6, 0, 24),
        Font = Enum.Font.GothamSemibold,
        Text = "  " .. element.Value .. "  ▼",
        TextColor3 = Settings.TextColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        AutoButtonColor = false,
    })
    
    local PickerCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.PickerButton,
    })
    
    -- Execute Button (Right side - more prominent)
    element.ExecuteButton = CreateInstance("TextButton", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.ExecuteColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Position = UDim2.new(0.58, 6, 0, 44),
        Size = UDim2.new(0.42, -18, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "EXECUTE",
        TextColor3 = Settings.TextColor,
        TextSize = 12,
        ZIndex = 2,
        AutoButtonColor = false,
    })
    
    local ExecuteCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.ExecuteButton,
    })
    
    -- Execute button glow effect
    local ExecuteGlow = CreateInstance("ImageLabel", {
        Parent = element.ExecuteButton,
        BackgroundTransparency = 1,
        Image = "rbxassetid://297034942",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = 2,
    })
    
    -- Dropdown options frame
    element.OptionsFrame = CreateInstance("ScrollingFrame", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.PrimaryColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 12, 1, 48),
        Size = UDim2.new(0.58, -6, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Settings.DimTextColor,
        ZIndex = 20,
        Visible = false,
        ClipsDescendants = true,
    })
    
    local OptionsCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.OptionsFrame,
    })
    
    local OptionsLayout = CreateInstance("UIListLayout", {
        Parent = element.OptionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    })
    
    OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        element.OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 2)
    end)
    
    -- Create option buttons in dropdown
    local function CreateOptionButtons()
        for _, child in pairs(element.OptionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        element.Buttons = {}
        
        for _, option in pairs(options) do
            local optionButton = CreateInstance("TextButton", {
                Parent = element.OptionsFrame,
                BackgroundColor3 = Settings.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 28),
                Font = Enum.Font.Gotham,
                Text = "  " .. option,
                TextColor3 = Settings.DimTextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 21,
                AutoButtonColor = false,
            })
            
            -- Highlight effect on hover
            optionButton.MouseEnter:Connect(function()
                CreateTween(optionButton, {BackgroundColor3 = Settings.AccentColor, TextColor3 = Settings.TextColor}, 0.2):Play()
            end)
            
            optionButton.MouseLeave:Connect(function()
                CreateTween(optionButton, {BackgroundColor3 = Settings.SecondaryColor, TextColor3 = Settings.DimTextColor}, 0.2):Play()
            end)
            
            -- Selection click
            optionButton.MouseButton1Click:Connect(function()
                element.Value = option
                element.PickerButton.Text = "  " .. option .. "  ▼"
                element.SelectedText.Text = "Selected: " .. option
                element:ToggleDropdown(false)
                
                -- Flash selected option
                spawn(function()
                    CreateTween(optionButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80), TextColor3 = Settings.TextColor}, 0.1):Play()
                    wait(0.1)
                    CreateTween(optionButton, {BackgroundColor3 = Settings.SecondaryColor, TextColor3 = Settings.DimTextColor}, 0.2):Play()
                end)
            end)
            
            table.insert(element.Buttons, optionButton)
        end
    end
    
    -- Toggle dropdown
    function element:ToggleDropdown(state)
        if state == nil then
            state = not element.Expanded
        end
        element.Expanded = state
        
        if state then
            -- Close other dropdowns first
            for _, el in pairs(self.Elements) do
                if el ~= element and el.Type == "Selection" and el.Expanded then
                    el:ToggleDropdown(false)
                end
            end
            
            element.OptionsFrame.Visible = true
            local height = math.min(#options * 28 + #options - 1, 150)
            element.OptionsFrame.Size = UDim2.new(0.58, -6, 0, 0)
            CreateTween(element.OptionsFrame, {Size = UDim2.new(0.58, -6, 0, height)}, 0.2):Play()
            element.PickerButton.Text = "  " .. element.Value .. "  ▲"
        else
            CreateTween(element.OptionsFrame, {Size = UDim2.new(0.58, -6, 0, 0)}, 0.2):Play()
            element.PickerButton.Text = "  " .. element.Value .. "  ▼"
            wait(0.2)
            element.OptionsFrame.Visible = false
        end
    end
    
    -- Picker button click
    element.PickerButton.MouseButton1Click:Connect(function()
        element:ToggleDropdown()
    end)
    
    -- Picker hover effects
    element.PickerButton.MouseEnter:Connect(function()
        CreateTween(element.PickerButton, {BackgroundColor3 = Settings.AccentColor}, 0.2):Play()
    end)
    
    element.PickerButton.MouseLeave:Connect(function()
        if not element.Expanded then
            CreateTween(element.PickerButton, {BackgroundColor3 = Settings.PrimaryColor}, 0.2):Play()
        end
    end)
    
    -- Execute button effects
    element.ExecuteButton.MouseEnter:Connect(function()
        CreateTween(element.ExecuteButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2):Play()
        CreateTween(ExecuteGlow, {ImageTransparency = 0.6}, 0.3):Play()
    end)
    
    element.ExecuteButton.MouseLeave:Connect(function()
        CreateTween(element.ExecuteButton, {BackgroundColor3 = Settings.ExecuteColor}, 0.2):Play()
        CreateTween(ExecuteGlow, {ImageTransparency = 0.8}, 0.3):Play()
    end)
    
    element.ExecuteButton.MouseButton1Click:Connect(function()
        -- Click animation
        CreateTween(element.ExecuteButton, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.1):Play()
        CreateTween(ExecuteGlow, {ImageTransparency = 0.4}, 0.1):Play()
        
        if callback then
            callback(element.Value)
        end
        
        wait(0.1)
        CreateTween(element.ExecuteButton, {BackgroundColor3 = Settings.ExecuteColor}, 0.2):Play()
        CreateTween(ExecuteGlow, {ImageTransparency = 0.8}, 0.2):Play()
    end)
    
    -- Update options dynamically
    element.SetOptions = function(newOptions)
        options = newOptions
        element.Options = newOptions
        if not table.find(newOptions, element.Value) then
            element.Value = newOptions[1] or ""
            element.PickerButton.Text = "  " .. element.Value .. "  ▼"
            element.SelectedText.Text = "Selected: " .. element.Value
        end
        CreateOptionButtons()
    end
    
    -- Set selected option
    element.SetValue = function(value)
        if table.find(options, value) then
            element.Value = value
            element.PickerButton.Text = "  " .. value .. "  ▼"
            element.SelectedText.Text = "Selected: " .. value
        end
    end
    
    CreateOptionButtons()
    
    table.insert(self.Elements, element)
    return element
end

-- ====================================
-- CREATE INPUT (NEW FEATURE!)
-- Text Input Box with Execute Button
-- ====================================
function MonochromeUI:CreateInput(tab, name, placeholder, callback)
    local element = {}
    element.Type = "Input"
    element.Value = ""
    element.Placeholder = placeholder or "Type here..."
    
    -- Main Container
    element.Frame = CreateInstance("Frame", {
        Parent = tab.Page,
        BackgroundColor3 = Settings.SecondaryColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Size = UDim2.new(1, -10, 0, 80),
        ClipsDescendants = false,
        ZIndex = 1,
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = element.Frame,
    })
    
    -- Title Label
    element.Label = CreateInstance("TextLabel", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 10),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    -- Text Input Box
    element.InputBox = CreateInstance("TextBox", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.InputBgColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 12, 0, 32),
        Size = UDim2.new(0.58, -6, 0, 32),
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Settings.DimTextColor,
        Text = "",
        TextColor3 = Settings.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 2,
    })
    
    local InputCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.InputBox,
    })
    
    -- Input padding
    local InputPadding = CreateInstance("UIPadding", {
        Parent = element.InputBox,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })
    
    -- Execute Button
    element.ExecuteButton = CreateInstance("TextButton", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.ExecuteColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Position = UDim2.new(0.58, 6, 0, 32),
        Size = UDim2.new(0.42, -18, 0, 32),
        Font = Enum.Font.GothamBold,
        Text = "EXECUTE",
        TextColor3 = Settings.TextColor,
        TextSize = 12,
        ZIndex = 2,
        AutoButtonColor = false,
    })
    
    local ExecuteCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = element.ExecuteButton,
    })
    
    -- Execute button glow effect
    local ExecuteGlow = CreateInstance("ImageLabel", {
        Parent = element.ExecuteButton,
        BackgroundTransparency = 1,
        Image = "rbxassetid://297034942",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = 2,
    })
    
    -- Character count label
    element.CharCount = CreateInstance("TextLabel", {
        Parent = element.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 66),
        Size = UDim2.new(0.58, -6, 0, 10),
        Font = Enum.Font.Gotham,
        Text = "0 characters",
        TextColor3 = Settings.DimTextColor,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 2,
    })
    
    -- Input text changed
    element.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
        element.Value = element.InputBox.Text
        element.CharCount.Text = #element.InputBox.Text .. " characters"
        
        -- Limit to 100 characters
        if #element.InputBox.Text > 100 then
            element.InputBox.Text = element.InputBox.Text:sub(1, 100)
        end
    end)
    
    -- Focus effects
    element.InputBox.Focused:Connect(function()
        CreateTween(element.InputBox, {BorderColor3 = Settings.TextColor}, 0.2):Play()
    end)
    
    element.InputBox.FocusLost:Connect(function(enterPressed)
        element.InputBox.BorderColor3 = Settings.BorderColor
        
        -- Execute on Enter key
        if enterPressed and element.InputBox.Text ~= "" and callback then
            callback(element.InputBox.Text)
            
            -- Flash effect
            spawn(function()
                CreateTween(element.ExecuteButton, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.1):Play()
                wait(0.1)
                CreateTween(element.ExecuteButton, {BackgroundColor3 = Settings.ExecuteColor}, 0.2):Play()
            end)
        end
    end)
    
    -- Execute button hover effects
    element.ExecuteButton.MouseEnter:Connect(function()
        CreateTween(element.ExecuteButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2):Play()
        CreateTween(ExecuteGlow, {ImageTransparency = 0.6}, 0.3):Play()
    end)
    
    element.ExecuteButton.MouseLeave:Connect(function()
        CreateTween(element.ExecuteButton, {BackgroundColor3 = Settings.ExecuteColor}, 0.2):Play()
        CreateTween(ExecuteGlow, {ImageTransparency = 0.8}, 0.3):Play()
    end)
    
    -- Execute button click
    element.ExecuteButton.MouseButton1Click:Connect(function()
        if element.InputBox.Text ~= "" then
            -- Click animation
            CreateTween(element.ExecuteButton, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.1):Play()
            CreateTween(ExecuteGlow, {ImageTransparency = 0.4}, 0.1):Play()
            
            if callback then
                callback(element.InputBox.Text)
            end
            
            wait(0.1)
            CreateTween(element.ExecuteButton, {BackgroundColor3 = Settings.ExecuteColor}, 0.2):Play()
            CreateTween(ExecuteGlow, {ImageTransparency = 0.8}, 0.2):Play()
        end
    end)
    
    -- Methods
    element.SetValue = function(text)
        element.InputBox.Text = text or ""
        element.Value = element.InputBox.Text
    end
    
    element.GetValue = function()
        return element.InputBox.Text
    end
    
    element.Clear = function()
        element.InputBox.Text = ""
        element.Value = ""
        element.CharCount.Text = "0 characters"
    end
    
    table.insert(self.Elements, element)
    return element
end

-- ====================================
-- CREATE NOTIFICATION
-- ====================================
function MonochromeUI:CreateNotification(title, message, duration)
    local notification = {}
    duration = duration or 3
    
    notification.Frame = CreateInstance("Frame", {
        Parent = self.MainGui,
        BackgroundColor3 = Settings.NotificationColor,
        BorderColor3 = Settings.BorderColor,
        BorderSizePixel = 1,
        Position = UDim2.new(1, 10, 0.7, 0),
        Size = UDim2.new(0, 250, 0, 60),
        AnchorPoint = Vector2.new(1, 0),
        ZIndex = 10,
    })
    
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = notification.Frame,
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Parent = notification.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title or "Notification",
        TextColor3 = Settings.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    })
    
    local MessageLabel = CreateInstance("TextLabel", {
        Parent = notification.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 30),
        Font = Enum.Font.Gotham,
        Text = message or "",
        TextColor3 = Settings.DimTextColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 11,
    })
    
    CreateTween(notification.Frame, {Position = UDim2.new(0.95, 0, 0.7, 0)}, 0.3):Play()
    
    spawn(function()
        wait(duration)
        CreateTween(notification.Frame, {Position = UDim2.new(1, 10, 0.7, 0), BackgroundTransparency = 1}, 0.3):Play()
        wait(0.3)
        notification.Frame:Destroy()
    end)
    
    table.insert(self.Notifications, notification)
    return notification
end

-- ====================================
-- HIDE UI
-- ====================================
function MonochromeUI:Hide()
    self.MainFrame.Visible = false
    
    if not self.ToggleButton then
        self.ToggleButton = CreateInstance("TextButton", {
            Parent = self.MainGui,
            BackgroundColor3 = Settings.PrimaryColor,
            BorderColor3 = Settings.BorderColor,
            BorderSizePixel = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 35, 0, 35),
            Font = Enum.Font.GothamBold,
            Text = "M",
            TextColor3 = Settings.TextColor,
            TextSize = 16,
            ZIndex = 100,
        })
        
        local ToggleCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = self.ToggleButton,
        })
        
        self.ToggleButton.MouseButton1Click:Connect(function()
            self:Show()
        end)
    end
end

-- ====================================
-- SHOW UI
-- ====================================
function MonochromeUI:Show()
    self.MainFrame.Visible = true
    if self.ToggleButton then
        self.ToggleButton:Destroy()
        self.ToggleButton = nil
    end
end

return MonochromeUI
