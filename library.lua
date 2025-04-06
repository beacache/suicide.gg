local VERSION = "1.3.2"

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
    Themes = {
        Dark = {
            Main = Color3.fromRGB(30, 30, 40),
            Section = Color3.fromRGB(25, 25, 35),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(100, 70, 200),
            Toggle = {
                On = Color3.fromRGB(100, 70, 200),
                Off = Color3.fromRGB(70, 70, 80)
            }
        }
    }
}

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

-- MAIN UI
function Solara:Init()
    if self.Initialized then return end
    
    local MainUI = Instance.new("ScreenGui")
    MainUI.Name = "SolaraHub"
    MainUI.Parent = CG
    MainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainUI.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = self.Themes.Dark.Main
    MainFrame.Parent = MainUI
    
    -- Tabs
    local TabList = Instance.new("Frame")
    TabList.Size = UDim2.new(0, 100, 1, 0)
    TabList.BackgroundColor3 = self.Themes.Dark.Section
    TabList.Parent = MainFrame
    
    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -100, 1, 0)
    Content.Position = UDim2.new(0, 100, 0, 0)
    Content.BackgroundColor3 = self.Themes.Dark.Main
    Content.Parent = MainFrame
    
    self.UI = {
        Main = MainUI,
        Frame = MainFrame,
        Tabs = TabList,
        Content = Content,
        CurrentTab = nil
    }
    
    Draggable(MainFrame)
    self.Initialized = true
end

-- ELEMENTS
function Solara:Button(params)
    local name = params.Text or "Button"
    local callback = params.Callback or function() end
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Position = UDim2.new(0, 10, 0, 10)
    Button.Text = name
    Button.Parent = self.UI.Content
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

function Solara:Toggle(params)
    local name = params.Text or "Toggle"
    local default = params.Default or false
    local callback = params.Callback or function() end
    
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -20, 0, 30)
    Toggle.BackgroundTransparency = 1
    Toggle.Parent = self.UI.Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = name
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleButton.BackgroundColor3 = default and self.Themes.Dark.Toggle.On or self.Themes.Dark.Toggle.Off
    ToggleButton.Parent = Toggle
    
    local state = default
    self.Flags[name] = state
    
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        self.Flags[name] = state
        ToggleButton.BackgroundColor3 = state and self.Themes.Dark.Toggle.On or self.Themes.Dark.Toggle.Off
        callback(state)
    end)
    
    return {
        Set = function(value)
            state = value
            self.Flags[name] = state
            ToggleButton.BackgroundColor3 = state and self.Themes.Dark.Toggle.On or self.Themes.Dark.Toggle.Off
        end,
        Get = function() return state end
    }
end

-- INIT
Solara:Init()

return Solara
