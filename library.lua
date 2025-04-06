local VERSION = "2.0"

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local HS = game:GetService("HttpService")

-- VARIABLES
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- LIBRARY
local Solara = {
    Flags = {},
    Connections = {},
    Configs = {},
    Notifications = {},
    Themes = {
        Dark = {
            Main = Color3.fromRGB(30, 30, 40),
            Section = Color3.fromRGB(25, 25, 35),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(100, 70, 200),
            Toggle = {
                On = Color3.fromRGB(100, 70, 200),
                Off = Color3.fromRGB(70, 70, 80)
            },
            Button = {
                Default = Color3.fromRGB(60, 60, 70),
                Hover = Color3.fromRGB(80, 80, 90)
            }
        }
    }
}

-- ANTI-DETECTION
do
    local function randomString()
        return HS:GenerateGUID(false):sub(1, 8)
    end

    Solara.ProtectedName = randomString()
    getgenv()[Solara.ProtectedName] = true
end

function library:CreateWindow(options)
    options = options or {}
    
    local window = {
        Tabs = {},
        Options = {
            Title = options.Title or "Solara Hub",
            Center = options.Center or true,
            AutoShow = options.AutoShow or true,
            TabPadding = options.TabPadding or 10
        },
        UI = {}
    }
    
    -- Создание основного GUI
    window.UI.ScreenGui = Instance.new("ScreenGui")
    window.UI.ScreenGui.Name = "SolaraHub"
    window.UI.ScreenGui.Parent = game:GetService("CoreGui")
    window.UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    window.UI.ScreenGui.ResetOnSpawn = false
    
    -- Основное окно
    window.UI.MainFrame = Instance.new("Frame")
    window.UI.MainFrame.Size = UDim2.new(0, 500, 0, 400)
    window.UI.MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    window.UI.MainFrame.Parent = window.UI.ScreenGui
    
    if window.Options.Center then
        window.UI.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    else
        window.UI.MainFrame.Position = UDim2.new(0, 100, 0, 100)
    end
    
    -- Заголовок окна
    window.UI.Title = Instance.new("TextLabel")
    window.UI.Title.Size = UDim2.new(1, 0, 0, 30)
    window.UI.Title.Text = window.Options.Title
    window.UI.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    window.UI.Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    window.UI.Title.Font = Enum.Font.GothamBold
    window.UI.Title.TextSize = 16
    window.UI.Title.Parent = window.UI.MainFrame
    
    -- Контейнер для кнопок вкладок
    window.UI.TabButtons = Instance.new("Frame")
    window.UI.TabButtons.Size = UDim2.new(0, 120, 1, -30)
    window.UI.TabButtons.Position = UDim2.new(0, 0, 0, 30)
    window.UI.TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    window.UI.TabButtons.Parent = window.UI.MainFrame
    
    -- Контейнер для контента вкладок
    window.UI.Content = Instance.new("Frame")
    window.UI.Content.Size = UDim2.new(1, -120, 1, -30)
    window.UI.Content.Position = UDim2.new(0, 120, 0, 30)
    window.UI.Content.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    window.UI.Content.ClipsDescendants = true
    window.UI.Content.Parent = window.UI.MainFrame
    
    -- Функция для добавления вкладки
    function window:AddTab(name)
        local tab = {
            Name = name,
            Elements = {},
            UI = {}
        }
        
        -- Кнопка вкладки
        tab.UI.Button = Instance.new("TextButton")
        tab.UI.Button.Size = UDim2.new(1, -10, 0, 30)
        tab.UI.Button.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * 35))
        tab.UI.Button.Text = name
        tab.UI.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.UI.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tab.UI.Button.Font = Enum.Font.GothamSemibold
        tab.UI.Button.TextSize = 14
        tab.UI.Button.Parent = window.UI.TabButtons
        
        -- Контент вкладки
        tab.UI.Content = Instance.new("ScrollingFrame")
        tab.UI.Content.Size = UDim2.new(1, 0, 1, 0)
        tab.UI.Content.BackgroundTransparency = 1
        tab.UI.Content.Visible = false
        tab.UI.Content.ScrollBarThickness = 5
        tab.UI.Content.Parent = window.UI.Content
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, window.Options.TabPadding)
        contentLayout.Parent = tab.UI.Content
        
        table.insert(self.Tabs, tab)
        
        -- Активация первой вкладки
        if #self.Tabs == 1 then
            self:SwitchTab(1)
        end
        
        -- Обработчик клика по вкладке
        tab.UI.Button.MouseButton1Click:Connect(function()
            self:SwitchTab(table.find(self.Tabs, tab))
        end)
        
        return tab
    end
    
    -- Функция переключения вкладок
    function window:SwitchTab(index)
        for i, tab in ipairs(self.Tabs) do
            tab.UI.Content.Visible = (i == index)
            tab.UI.Button.BackgroundColor3 = (i == index) and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(40, 40, 50)
        end
    end
    
    -- Автопоказ окна
    if window.Options.AutoShow then
        window.UI.ScreenGui.Enabled = true
    end
    
    return window
end

-- UTILS
local function Draggable(UI)
    local dragToggle, dragInput, dragStart, dragPos
    UI.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            dragPos = UI.Position
            dragToggle = true
        end
    end)
    UI.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
            local delta = input.Position - dragStart
            UI.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
        end
    end)
end

local function RippleEffect(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, 0, 0, 0)
    ripple.Parent = button
    ripple.ZIndex = button.ZIndex + 1
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local mousePos = UIS:GetMouseLocation()
    local buttonPos = button.AbsolutePosition
    local pos = Vector2.new(mousePos.X - buttonPos.X, mousePos.Y - buttonPos.Y)
    
    ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
    
    TS:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    }):Play()
    
    spawn(function()
        wait(0.5)
        ripple:Destroy()
    end)
end

-- NOTIFICATIONS
function Solara:Notify(title, message, duration)
    duration = duration or 5
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 70)
    notification.Position = UDim2.new(1, -320, 1, -80 - (#self.Notifications * 80))
    notification.BackgroundColor3 = self.Themes.Dark.Section
    notification.BorderSizePixel = 0
    notification.Parent = self.UI.Main
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Themes.Dark.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -10, 1, -30)
    messageLabel.Position = UDim2.new(0, 10, 0, 25)
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.BackgroundTransparency = 1
    messageLabel.Parent = notification
    
    TS:Create(notification, TweenInfo.new(0.3), {
        Position = UDim2.new(1, 320, 1, -80 - (#self.Notifications * 80))
    }):Play()
    
    table.insert(self.Notifications, notification)
    
    spawn(function()
        wait(duration)
        TS:Create(notification, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 320, 1, -80 - (#self.Notifications * 80))
        }):Play()
        wait(0.3)
        notification:Destroy()
        table.remove(self.Notifications, table.find(self.Notifications, notification))
    end)
end

-- MAIN UI
function Solara:Init()
    if self.Initialized then return end
    
    local MainUI = Instance.new("ScreenGui")
    MainUI.Name = Solara.ProtectedName
    MainUI.Parent = CG
    MainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainUI.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = self.Themes.Dark.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainUI
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "SOLARA HUB v"..VERSION
    Title.TextColor3 = self.Themes.Dark.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Title.BorderSizePixel = 0
    Title.Parent = MainFrame
    
    -- Tabs
    local TabList = Instance.new("Frame")
    TabList.Size = UDim2.new(0, 120, 1, -30)
    TabList.Position = UDim2.new(0, 0, 0, 30)
    TabList.BackgroundColor3 = self.Themes.Dark.Section
    TabList.BorderSizePixel = 0
    TabList.Parent = MainFrame
    
    local TabButtons = Instance.new("ScrollingFrame")
    TabButtons.Size = UDim2.new(1, 0, 1, 0)
    TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtons.ScrollBarThickness = 3
    TabButtons.BackgroundTransparency = 1
    TabButtons.Parent = TabList
    
    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -120, 1, -30)
    Content.Position = UDim2.new(0, 120, 0, 30)
    Content.BackgroundColor3 = self.Themes.Dark.Main
    Content.BorderSizePixel = 0
    Content.ClipsDescendants = true
    Content.Parent = MainFrame
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.Parent = Content
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = Content
    
    self.UI = {
        Main = MainUI,
        Frame = MainFrame,
        Tabs = {
            Frame = TabList,
            Buttons = TabButtons,
            List = {}
        },
        Content = Content,
        CurrentTab = nil
    }
    
    Draggable(MainFrame)
    self.Initialized = true
    self:Notify("Solara Hub", "Successfully loaded!", 3)
end

-- TABS SYSTEM
function Solara:Tab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 30)
    TabButton.Position = UDim2.new(0, 5, 0, 5 + (#self.UI.Tabs.List * 35))
    TabButton.Text = name
    TabButton.TextColor3 = self.Themes.Dark.Text
    TabButton.BackgroundColor3 = self.Themes.Dark.Main
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 14
    TabButton.Parent = self.UI.Tabs.Buttons
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = self.UI.Content
    TabContent.ScrollBarThickness = 3
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 10)
    TabLayout.Parent = TabContent
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local tab = {
        Name = name,
        Button = TabButton,
        Content = TabContent,
        Elements = {}
    }
    
    table.insert(self.UI.Tabs.List, tab)
    self.UI.Tabs.Buttons.CanvasSize = UDim2.new(0, 0, 0, #self.UI.Tabs.List * 35 + 5)
    
    if #self.UI.Tabs.List == 1 then
        self:SwitchTab(1)
    end
    
    TabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(table.find(self.UI.Tabs.List, tab))
    end)
    
    return {
        AddButton = function(params)
            return self:Button(params, TabContent)
        end,
        AddToggle = function(params)
            return self:Toggle(params, TabContent)
        end,
        AddSlider = function(params)
            return self:Slider(params, TabContent)
        end,
        AddDropdown = function(params)
            return self:Dropdown(params, TabContent)
        end,
        AddKeybind = function(params)
            return self:Keybind(params, TabContent)
        end,
        AddColorPicker = function(params)
            return self:ColorPicker(params, TabContent)
        end
    }
end

function Solara:SwitchTab(index)
    if self.UI.CurrentTab then
        self.UI.CurrentTab.Content.Visible = false
        self.UI.CurrentTab.Button.BackgroundColor3 = self.Themes.Dark.Main
    end
    
    self.UI.CurrentTab = self.UI.Tabs.List[index]
    self.UI.CurrentTab.Content.Visible = true
    self.UI.CurrentTab.Button.BackgroundColor3 = self.Themes.Dark.Accent
end

-- ELEMENTS
function Solara:Button(params, parent)
    parent = parent or self.UI.Content
    local name = params.Text or "Button"
    local callback = params.Callback or function() end
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Text = name
    Button.TextColor3 = self.Themes.Dark.Text
    Button.BackgroundColor3 = self.Themes.Dark.Button.Default
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TS:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = self.Themes.Dark.Button.Hover
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TS:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = self.Themes.Dark.Button.Default
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        RippleEffect(Button)
        callback()
    end)
    
    return Button
end

function Solara:Toggle(params, parent)
    parent = parent or self.UI.Content
    local name = params.Text or "Toggle"
    local default = params.Default or false
    local callback = params.Callback or function() end
    
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -20, 0, 30)
    Toggle.BackgroundTransparency = 1
    Toggle.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = "  "..name
    Label.TextColor3 = self.Themes.Dark.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.BackgroundTransparency = 1
    Label.Parent = Toggle
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0, 50, 0, 25)
    ToggleFrame.Position = UDim2.new(1, -50, 0.5, -12)
    ToggleFrame.BackgroundColor3 = self.Themes.Dark.Toggle.Off
    ToggleFrame.Parent = Toggle
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Size = UDim2.new(0, 21, 0, 21)
    ToggleButton.Position = UDim2.new(0, 2, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Parent = ToggleFrame
    
    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 10)
    Corner2.Parent = ToggleButton
    
    local state = default
    self.Flags[name] = state
    
    if state then
        ToggleFrame.BackgroundColor3 = self.Themes.Dark.Toggle.On
        ToggleButton.Position = UDim2.new(1, -23, 0.5, -10)
    end
    
    local function toggleState()
        state = not state
        self.Flags[name] = state
        
        TS:Create(ToggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = state and self.Themes.Dark.Toggle.On or self.Themes.Dark.Toggle.Off
        }):Play()
        
        TS:Create(ToggleButton, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }):Play()
        
        callback(state)
    end
    
    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleState()
        end
    end)
    
    return {
        Set = function(value)
            if state ~= value then
                toggleState()
            end
        end,
        Get = function() return state end
    }
end

function Solara:Slider(params, parent)
    parent = parent or self.UI.Content
    local name = params.Text or "Slider"
    local min = params.Min or 0
    local max = params.Max or 100
    local default = params.Default or min
    local callback = params.Callback or function() end
    local precise = params.Precise or false
    
    local value = math.clamp(default, min, max)
    
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -20, 0, 50)
    Slider.BackgroundTransparency = 1
    Slider.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = name..": "..value
    Label.TextColor3 = self.Themes.Dark.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.BackgroundTransparency = 1
    Label.Parent = Slider
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 5)
    Track.Position = UDim2.new(0, 0, 0, 25)
    Track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Track.Parent = Slider
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 3)
    Corner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = self.Themes.Dark.Accent
    Fill.Parent = Track
    
    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 3)
    Corner2.Parent = Fill
    
    local Handle = Instance.new("TextButton")
    Handle.Size = UDim2.new(0, 15, 0, 15)
    Handle.Position = UDim2.new((value - min)/(max - min), -7, 0.5, -7)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.AutoButtonColor = false
    Handle.Text = ""
    Handle.Parent = Slider
    
    local Corner3 = Instance.new("UICorner")
    Corner3.CornerRadius = UDim.new(0, 7)
    Corner3.Parent = Handle
    
    local dragging = false
    
    local function setValue(newValue)
        newValue = precise and newValue or math.floor(newValue)
        newValue = math.clamp(newValue, min, max)
        
        if value ~= newValue then
            value = newValue
            Label.Text = name..": "..value
            Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
            Handle.Position = UDim2.new((value - min)/(max - min), -7, 0.5, -7)
            callback(value)
        end
    end
    
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RS.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UIS:GetMouseLocation().X
            local sliderPos = Track.AbsolutePosition.X
            local sliderSize = Track.AbsoluteSize.X
            local relativePos = math.clamp(mousePos - sliderPos, 0, sliderSize)
            local newValue = min + (relativePos / sliderSize) * (max - min)
            setValue(newValue)
        end
    end)
    
    setValue(default)
    
    return {
        Set = function(newValue)
            setValue(newValue)
        end,
        Get = function() return value end
    }
end

function Solara:Dropdown(params, parent)
    parent = parent or self.UI.Content
    local name = params.Text or "Dropdown"
    local options = params.Options or {}
    local default = params.Default or options[1]
    local callback = params.Callback or function() end
    
    local selected = default
    local opened = false
    
    local Dropdown = Instance.new("Frame")
    Dropdown.Size = UDim2.new(1, -20, 0, 30)
    Dropdown.BackgroundTransparency = 1
    Dropdown.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = "  "..name
    Label.TextColor3 = self.Themes.Dark.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.BackgroundTransparency = 1
    Label.Parent = Dropdown
    
    local MainButton = Instance.new("TextButton")
    MainButton.Size = UDim2.new(0.3, 0, 1, 0)
    MainButton.Position = UDim2.new(0.7, 0, 0, 0)
    MainButton.Text = selected or "Select"
    MainButton.TextColor3 = self.Themes.Dark.Text
    MainButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    MainButton.Font = Enum.Font.Gotham
    MainButton.TextSize = 14
    MainButton.AutoButtonColor = false
    MainButton.Parent = Dropdown
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = MainButton
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(0.3, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0.7, 0, 0, 30)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    OptionsFrame.Visible = false
    OptionsFrame.Parent = Dropdown
    
    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 5)
    Corner2.Parent = OptionsFrame
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Parent = OptionsFrame
    
    for _, option in pairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.Text = option
        OptionButton.TextColor3 = self.Themes.Dark.Text
        OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionsFrame
        
        OptionButton.MouseEnter:Connect(function()
            TS:Create(OptionButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TS:Create(OptionButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            }):Play()
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            selected = option
            MainButton.Text = option
            callback(option)
            toggleDropdown()
        end)
    end
    
    local function toggleDropdown()
        opened = not opened
        OptionsFrame.Visible = opened
        
        if opened then
            OptionsFrame.Size = UDim2.new(0.3, 0, 0, math.min(#options * 25, 150))
            Dropdown.Size = UDim2.new(1, -20, 0, 30 + math.min(#options * 25, 150))
        else
            OptionsFrame.Size = UDim2.new(0.3, 0, 0, 0)
            Dropdown.Size = UDim2.new(1, -20, 0, 30)
        end
    end
    
    MainButton.MouseButton1Click:Connect(toggleDropdown)
    
    return {
        Set = function(option)
            if table.find(options, option) then
                selected = option
                MainButton.Text = option
                callback(option)
            end
        end,
        Get = function() return selected end
    }
end

function Solara:Keybind(params, parent)
    parent = parent or self.UI.Content
    local name = params.Text or "Keybind"
    local default = params.Default or Enum.KeyCode.F
    local callback = params.Callback or function() end
    local allowMouse = params.AllowMouse or false
    
    local key = default
    local listening = false
    
    local Keybind = Instance.new("Frame")
    Keybind.Size = UDim2.new(1, -20, 0, 30)
    Keybind.BackgroundTransparency = 1
    Keybind.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = "  "..name
    Label.TextColor3 = self.Themes.Dark.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.BackgroundTransparency = 1
    Label.Parent = Keybind
    
    local KeyButton = Instance.new("TextButton")
    KeyButton.Size = UDim2.new(0.3, 0, 1, 0)
    KeyButton.Position = UDim2.new(0.7, 0, 0, 0)
    KeyButton.Text = key.Name
    KeyButton.TextColor3 = self.Themes.Dark.Text
    KeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    KeyButton.Font = Enum.Font.Gotham
    KeyButton.TextSize = 14
    KeyButton.AutoButtonColor = false
    KeyButton.Parent = Keybind
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = KeyButton
    
    local function setKey(newKey)
        key = newKey
        KeyButton.Text = newKey.Name
        callback(newKey)
    end
    
    KeyButton.MouseButton1Click:Connect(function()
        listening = true
        KeyButton.Text = "..."
    end)
    
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not listening or gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            setKey(input.KeyCode)
            listening = false
        elseif allowMouse and input.UserInputType == Enum.UserInputType.MouseButton1 then
            setKey(Enum.KeyCode.LeftControl) -- Пример для мыши
            listening = false
        end
    end)
    
    return {
        Set = function(newKey)
            setKey(newKey)
        end,
        Get = function() return key end
    }
end

function Solara:ColorPicker(params, parent)
    parent = parent or self.UI.Content
    local name = params.Text or "ColorPicker"
    local default = params.Default or Color3.fromRGB(255, 0, 0)
    local callback = params.Callback or function() end
    
    local color = default
    
    local ColorPicker = Instance.new("Frame")
    ColorPicker.Size = UDim2.new(1, -20, 0, 30)
    ColorPicker.BackgroundTransparency = 1
    ColorPicker.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = "  "..name
    Label.TextColor3 = self.Themes.Dark.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.BackgroundTransparency = 1
    Label.Parent = ColorPicker
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Size = UDim2.new(0.3, 0, 1, 0)
    ColorButton.Position = UDim2.new(0.7, 0, 0, 0)
    ColorButton.Text = ""
    ColorButton.BackgroundColor3 = color
    ColorButton.AutoButtonColor = false
    ColorButton.Parent = ColorPicker
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = ColorButton
    
    -- Здесь должна быть реализация выбора цвета (популярное решение - через ColorPicker из библиотеки)
    
    return {
        Set = function(newColor)
            color = newColor
            ColorButton.BackgroundColor3 = newColor
            callback(newColor)
        end,
        Get = function() return color end
    }
end

-- CONFIGS SYSTEM
function Solara:SaveConfig(name)
    local config = {
        Flags = self.Flags,
        Theme = "Dark" -- Можно расширить для разных тем
    }
    
    if not isfolder("SolaraHub") then
        makefolder("SolaraHub")
    end
    
    writefile("SolaraHub/"..name..".json", HS:JSONEncode(config))
    self:Notify("Config", "Saved config: "..name, 3)
end

function Solara:LoadConfig(name)
    if isfile("SolaraHub/"..name..".json") then
        local config = HS:JSONDecode(readfile("SolaraHub/"..name..".json"))
        self.Flags = config.Flags or {}
        -- Здесь нужно обновить все элементы UI в соответствии с загруженными флагами
        self:Notify("Config", "Loaded config: "..name, 3)
    else
        self:Notify("Config", "Config not found: "..name, 3)
    end
end

function Solara:DeleteConfig(name)
    if isfile("SolaraHub/"..name..".json") then
        delfile("SolaraHub/"..name..".json")
        self:Notify("Config", "Deleted config: "..name, 3)
    else
        self:Notify("Config", "Config not found: "..name, 3)
    end
end

-- INIT
Solara:Init()

return Solara
