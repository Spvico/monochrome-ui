--[[
    Monochrome UI Library v1.0
    Features: Monochrome theme, draggable, minimizable, closable, respawn-proof
    Compatible with most executors (Krnl, Synapse X, Script-Ware, Fluxus, etc.)
    Supports Mobile & Desktop
]]

local MonochromeUI = {}
MonochromeUI.__index = MonochromeUI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

local function IsMobile()
    return UserInputService.TouchEnabled
end

-- Main Library Constructor
function MonochromeUI.new(title)
    local self = setmetatable({}, MonochromeUI)
    
    -- Detect executor support for various protections
    local synced = syn and syn.protect_gui or function(obj) return obj end
    local krnled = getexecutorname and getexecutorname():lower():find("krnl") and getgc or nil
    
    -- Main GUI
    self.MainGui = CreateInstance("ScreenGui", {
        Name = "MonochromeUI_" .. math.random(1000, 9999),
        Parent = (synced and gethui) and gethui() or CoreGui,
        ResetOnSpawn = false, -- Respawn proof
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    
    -- Protect GUI for executors that support it
    if synced then
        synced(self.MainGui)
    elseif krnled then
        for i, v in next, krnled() do
            if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
                local constants = getconstants(v)
                if table.find(constants, "RobloxGui") then
                    self.MainGui.Parent = v()
                    break
                end
            end
        end
    end
    
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
    
    -- Rounded corners effect
    local Corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.MainFrame,
    })
    
    -- Shadow effect
    local Shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        Parent = self.MainFrame,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        Image = "rbxassetid://297034942",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        ZIndex = 0,
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
    
    -- Fix bottom corners
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
    
    -- UI List Layout
    self.Layout = CreateInstance("UIListLayout", {
        Parent = self.ContentFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
    
    -- Variables
    self.Minimized = false
    self.OriginalSize = self.MainFrame.Size
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.Dragging = false
    self.DragInput = nil
    self.DragStart = nil
    self.StartPos = nil
    self.Notifications = {}
    
    -- Dragging System (works on mobile & desktop)
    local function UpdateDrag(input)
        local delta = input.Position - self.DragStart
        local newPos = UDim2.new(self.StartPos.X.Scale, self.StartPos.X.Offset + delta.X, 
                                self.StartPos.Y.Scale, self.StartPos.Y.Offset + delta.Y)
        
        TweenService:Create(self.MainFrame, TweenInfo.new(0.1), {Position = newPos}):Play()
    end
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                end
            end)
        end
    end)
    
    self.TopBar.InputChanged:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                             input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDrag(input)
        end
    end)
    
    -- Minimize Functionality
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Close Functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
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
    
    -- Respawn Protection
    if LocalPlayer then
        LocalPlayer.CharacterAdded:Connect(function()
            if self.MainGui and self.MainGui.Parent then
                -- GUI persists through respawn
                self.MainGui.ResetOnSpawn = false
            end
        end)
    end
    
    -- Auto-update canvas size
    self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    return self
end

-- Tab Creation
function MonochromeUI:CreateTab(name)
    local tab = {}
    
    -- Tab Button
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
    
    -- Tab Page
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
    
    -- Tab Selection Logic
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

-- Select Tab
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

-- Create Button Element
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
    
    -- Hover effects
    element.Frame.MouseEnter:Connect(function()
        CreateTween(element.Frame, {BackgroundColor3 = Settings.AccentColor}, 0.2):Play()
    end)
    
    element.Frame.MouseLeave:Connect(function()
        CreateTween(element.Frame, {BackgroundColor3 = Settings.SecondaryColor}, 0.2):Play()
    end)
    
    -- Click handler
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

-- Create Toggle Element
function MonochromeUI:CreateToggle(tab, name, default, callback)
    local element = {}
    element.Type = "Toggle"
    element.Value = default or false
    
    -- Container
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
    
    -- Label
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
    
    -- Toggle Button
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
    
    -- Toggle Function
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

-- Create Slider Element
function MonochromeUI:CreateSlider(tab, name, min, max, default, callback)
    local element = {}
    element.Type = "Slider"
    element.Value = default or min
    element.Min = min
    element.Max = max
    
    -- Container
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
    
    -- Label
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
    
    -- Slider Background
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
    
    -- Slider Fill
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
    
    -- Slider Dot
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
    
    -- Slider Interaction
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

-- Create Label Element
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

-- Create Dropdown Element
function MonochromeUI:CreateDropdown(tab, name, options, callback)
    local element = {}
    element.Type = "Dropdown"
    element.Value = options[1] or ""
    element.Options = options
    element.Expanded = false
    element.Buttons = {}
    
    -- Main Button
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
    
    -- Options Container (hidden by default)
    element.OptionsFrame = CreateInstance("Frame", {
        Parent = element.Frame,
        BackgroundColor3 = Settings.PrimaryColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 2),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        ZIndex = 5,
        Visible = false,
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
    
    -- Create option buttons
    local function CreateOptionButtons()
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
                ZIndex = 6,
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
    
    -- Toggle Dropdown
    function element:Toggle(state)
        if state == nil then
            state = not element.Expanded
        end
        element.Expanded = state
        
        if state then
            element.OptionsFrame.Visible = true
            local height = #options * 30 + #options - 1
            element.OptionsFrame.Size = UDim2.new(1, 0, 0, height)
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
    
    CreateOptionButtons()
    
    table.insert(self.Elements, element)
    return element
end

-- Create Notification
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
    
    -- Slide in animation
    CreateTween(notification.Frame, {Position = UDim2.new(0.95, 0, 0.7, 0)}, 0.3):Play()
    
    -- Auto remove
    spawn(function()
        wait(duration)
        CreateTween(notification.Frame, {Position = UDim2.new(1, 10, 0.7, 0), BackgroundTransparency = 1}, 0.3):Play()
        wait(0.3)
        notification.Frame:Destroy()
    end)
    
    table.insert(self.Notifications, notification)
    return notification
end

-- Minimize/Maximize
function MonochromeUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        -- Minimize
        self.OriginalSize = self.MainFrame.Size
        CreateTween(self.MainFrame, {Size = UDim2.new(0, 600, 0, 35)}, 0.3):Play()
        self.ContentFrame.Visible = false
        self.TabContainer.Visible = false
        self.TabPageContainer.Visible = false
        self.MinimizeButton.Text = "□"
    else
        -- Maximize
        CreateTween(self.MainFrame, {Size = self.OriginalSize}, 0.3):Play()
        self.ContentFrame.Visible = true
        self.TabContainer.Visible = true
        self.TabPageContainer.Visible = true
        self.MinimizeButton.Text = "─"
    end
end

-- Hide/Show UI
function MonochromeUI:Hide()
    self.MainFrame.Visible = false
    
    -- Create toggle button to show again
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

function MonochromeUI:Show()
    self.MainFrame.Visible = true
    if self.ToggleButton then
        self.ToggleButton:Destroy()
        self.ToggleButton = nil
    end
end

-- Return Library
return MonochromeUI
