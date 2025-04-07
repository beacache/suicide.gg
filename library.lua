-- WINDOW CREATE
local SolaraHub = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- Перемещаем Notify в SolaraHub
function SolaraHub:Notify(message, duration)
    print("[NOTIFY] " .. message)
    duration = duration or 3
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(1, -210, 1, -60)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notification.Parent = self.ScreenGui or game:GetService("CoreGui") -- Используем CoreGui, если ScreenGui не задан
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 6)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = Color3.fromRGB(50, 50, 60)
    notifStroke.Thickness = 1
    notifStroke.Parent = notification
    
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(1, -10, 1, -10)
    notifLabel.Position = UDim2.new(0, 5, 0, 5)
    notifLabel.Text = message
    notifLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Font = Enum.Font.Gotham
    notifLabel.TextSize = 12
    notifLabel.TextWrapped = true
    notifLabel.Parent = notification
    
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -210, 1, -60)
    })
    tweenIn:Play()
    
    task.delay(duration, function()
        local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 1, -60)
        })
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
        tweenOut:Play()
    end)
end

function SolaraHub:CreateWindow(options)
    options = options or {}
    
    local window = {
        Tabs = {},
        Options = {
            Title = options.Title or "Solara Hub"
        },
        UI = {},
        IsDragging = false,
        CenterWindow = function(self)
            if not self.IsDragging then
                local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
                local windowSize = self.UI.MainFrame.AbsoluteSize
                local newPos = UDim2.new(
                    0.5, -windowSize.X / 2,
                    0.5, -windowSize.Y / 2
                )
                self.UI.MainFrame.Position = newPos
                print("[DEBUG] Centering window at position: " .. tostring(newPos))
            end
        end,
        ResetUI = function(self)
            print("[DEBUG] Resetting UI state")
            self.UI.ScreenGui.Enabled = true
            self.UI.MainFrame.BackgroundTransparency = 0
            self.UI.MainFrame.Size = UDim2.new(0, 600, 0, 400)
            for _, child in pairs(self.UI.MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextTransparency = 0
                    end
                    if child:IsA("Frame") or child:IsA("TextButton") then
                        child.BackgroundTransparency = 0
                    end
                end
            end
            self:CenterWindow()
        end,
        ToggleUI = function(self)
            print("[DEBUG] Toggling UI, current state: " .. tostring(self.UI.ScreenGui.Enabled))
            if self.UI.ScreenGui.Enabled then
                self:HideUI()
            else
                self:ShowUI()
            end
        end,
        ShowUI = function(self)
            print("[DEBUG] Showing UI")
            self.UI.ScreenGui.Enabled = true
            self:CenterWindow()
            self.UI.MainFrame.Size = UDim2.new(0, 600, 0, 0)
            self.UI.MainFrame.BackgroundTransparency = 1
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            local tween = TweenService:Create(self.UI.MainFrame, tweenInfo, {
                Size = UDim2.new(0, 600, 0, 400),
                BackgroundTransparency = 0
            })
            for _, child in pairs(self.UI.MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextTransparency = 1
                        TweenService:Create(child, tweenInfo, {TextTransparency = 0}):Play()
                    end
                    if child:IsA("Frame") or child:IsA("TextButton") then
                        child.BackgroundTransparency = 1
                        TweenService:Create(child, tweenInfo, {BackgroundTransparency = 0}):Play()
                    end
                end
            end
            tween:Play()
        end,
        HideUI = function(self)
            print("[DEBUG] Hiding UI")
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            local tween = TweenService:Create(self.UI.MainFrame, tweenInfo, {
                Size = UDim2.new(0, 600, 0, 0),
                BackgroundTransparency = 1
            })
            for _, child in pairs(self.UI.MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        TweenService:Create(child, tweenInfo, {TextTransparency = 1}):Play()
                    end
                    if child:IsA("Frame") or child:IsA("TextButton") then
                        TweenService:Create(child, tweenInfo, {BackgroundTransparency = 1}):Play()
                    end
                end
            end
            tween.Completed:Connect(function()
                self.UI.ScreenGui.Enabled = false
                print("[DEBUG] UI hidden, ScreenGui.Enabled = false")
            end)
            tween:Play()
        end
    }
    
    print("[DEBUG] Creating ScreenGui")
    window.UI.ScreenGui = Instance.new("ScreenGui")
    window.UI.ScreenGui.Name = "SolaraHub"
    window.UI.ScreenGui.Parent = game:GetService("CoreGui")
    window.UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    window.UI.ScreenGui.ResetOnSpawn = false
    window.UI.ScreenGui.Enabled = false
    print("[DEBUG] ScreenGui created, Enabled = " .. tostring(window.UI.ScreenGui.Enabled))
    
    -- Сохраняем ScreenGui в SolaraHub для использования в Notify
    SolaraHub.ScreenGui = window.UI.ScreenGui
    
    print("[DEBUG] Creating MainFrame")
    window.UI.MainFrame = Instance.new("Frame")
    window.UI.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    window.UI.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    window.UI.MainFrame.Parent = window.UI.ScreenGui
    window.UI.MainFrame.ClipsDescendants = true
    
    window:CenterWindow()
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = window.UI.MainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(50, 50, 60)
    mainStroke.Thickness = 1
    mainStroke.Parent = window.UI.MainFrame
    
    window.UI.TitleBar = Instance.new("Frame")
    window.UI.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    window.UI.TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    window.UI.TitleBar.Parent = window.UI.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = window.UI.TitleBar
    
    window.UI.Icon = Instance.new("ImageLabel")
    window.UI.Icon.Size = UDim2.new(0, 24, 0, 24)
    window.UI.Icon.Position = UDim2.new(0, 10, 0.5, -12)
    window.UI.Icon.BackgroundTransparency = 1
    window.UI.Icon.Image = "rbxassetid://7072724"
    window.UI.Icon.Parent = window.UI.TitleBar
    
    window.UI.Title = Instance.new("TextLabel")
    window.UI.Title.Size = UDim2.new(1, -50, 0, 40)
    window.UI.Title.Position = UDim2.new(0, 40, 0, 0)
    window.UI.Title.Text = window.Options.Title
    window.UI.Title.TextColor3 = Color3.fromRGB(200, 200, 200)
    window.UI.Title.BackgroundTransparency = 1
    window.UI.Title.Font = Enum.Font.GothamBold
    window.UI.Title.TextSize = 16
    window.UI.Title.TextXAlignment = Enum.TextXAlignment.Left
    window.UI.Title.Parent = window.UI.TitleBar
    
    window.UI.TabButtons = Instance.new("Frame")
    window.UI.TabButtons.Size = UDim2.new(1, 0, 0, 40)
    window.UI.TabButtons.Position = UDim2.new(0, 0, 0, 40)
    window.UI.TabButtons.BackgroundTransparency = 1
    window.UI.TabButtons.Parent = window.UI.MainFrame
    
    local tabButtonsLayout = Instance.new("UIListLayout")
    tabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonsLayout.Padding = UDim.new(0, 5)
    tabButtonsLayout.Parent = window.UI.TabButtons
    
    window.UI.Content = Instance.new("Frame")
    window.UI.Content.Size = UDim2.new(1, 0, 1, -80)
    window.UI.Content.Position = UDim2.new(0, 0, 0, 80)
    window.UI.Content.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    window.UI.Content.ClipsDescendants = true
    window.UI.Content.Parent = window.UI.MainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = window.UI.Content
    
    local dragging = false
    local dragStart = nil
    local startPos = nil

    window.UI.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            window.IsDragging = true
            dragStart = input.Position
            startPos = window.UI.MainFrame.Position
            local tween = TweenService:Create(window.UI.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            })
            tween:Play()
        end
    end)

    window.UI.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            window.UI.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    window.UI.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            local tween = TweenService:Create(window.UI.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            })
            tween:Play()
        end
    end)

    RunService.RenderStepped:Connect(function()
        window:CenterWindow()
    end)

-- TAB CREATION
    function window:AddTab(name)
        local tab = {
            Name = name,
            Elements = {},
            UI = {}
        }
        
        tab.UI.Button = Instance.new("TextButton")
        tab.UI.Button.Size = UDim2.new(1 / 4, -5, 0, 30)
        tab.UI.Button.Text = name
        tab.UI.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab.UI.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        tab.UI.Button.Font = Enum.Font.GothamSemibold
        tab.UI.Button.TextSize = 14
        tab.UI.Button.Parent = window.UI.TabButtons
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 6)
        tabButtonCorner.Parent = tab.UI.Button
        
        tab.UI.Button.MouseEnter:Connect(function()
            if tab.UI.Button.BackgroundColor3 ~= Color3.fromRGB(50, 50, 55) then
                local tween = TweenService:Create(tab.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                })
                tween:Play()
            end
        end)
        
        tab.UI.Button.MouseLeave:Connect(function()
            if tab.UI.Button.BackgroundColor3 ~= Color3.fromRGB(50, 50, 55) then
                local tween = TweenService:Create(tab.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                })
                tween:Play()
            end
        end)
        
        tab.UI.Content = Instance.new("ScrollingFrame")
        tab.UI.Content.Size = UDim2.new(1, 0, 1, 0)
        tab.UI.Content.BackgroundTransparency = 1
        tab.UI.Content.Visible = false
        tab.UI.Content.ScrollBarThickness = 4
        tab.UI.Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        tab.UI.Content.Parent = window.UI.Content
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = tab.UI.Content
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.UI.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end)
        
        table.insert(self.Tabs, tab)
        
        if #self.Tabs == 1 then
            self:SwitchTab(1)
        end
        
        for _, t in ipairs(self.Tabs) do
            t.UI.Button.Size = UDim2.new(1 / #self.Tabs, -5, 0, 30)
        end
        
        tab.UI.Button.MouseButton1Click:Connect(function()
            self:SwitchTab(table.find(self.Tabs, tab))
        end)

-- GROUPBOX CREATION
        function tab:AddLeftGroupbox(name)
            print("[DEBUG] Creating Groupbox: " .. name)
            local groupbox = {
                Name = name,
                UI = {}
            }
            
            groupbox.UI.Frame = Instance.new("Frame")
            groupbox.UI.Frame.Size = UDim2.new(0.45, 0, 0, 30)
            groupbox.UI.Frame.Position = UDim2.new(0, 5, 0, 5)
            groupbox.UI.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            groupbox.UI.Frame.Parent = self.UI.Content
            groupbox.UI.Frame.LayoutOrder = #self.Elements
            
            local groupboxCorner = Instance.new("UICorner")
            groupboxCorner.CornerRadius = UDim.new(0, 6)
            groupboxCorner.Parent = groupbox.UI.Frame
            
            local groupboxStroke = Instance.new("UIStroke")
            groupboxStroke.Color = Color3.fromRGB(50, 50, 60)
            groupboxStroke.Thickness = 1
            groupboxStroke.Parent = groupbox.UI.Frame
            
            groupbox.UI.Title = Instance.new("TextLabel")
            groupbox.UI.Title.Size = UDim2.new(1, 0, 0, 20)
            groupbox.UI.Title.Text = name
            groupbox.UI.Title.TextColor3 = Color3.fromRGB(200, 200, 200)
            groupbox.UI.Title.BackgroundTransparency = 1
            groupbox.UI.Title.Font = Enum.Font.GothamBold
            groupbox.UI.Title.TextSize = 14
            groupbox.UI.Title.Parent = groupbox.UI.Frame
            
            local groupboxLayout = Instance.new("UIListLayout")
            groupboxLayout.Padding = UDim.new(0, 5)
            groupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
            groupboxLayout.Parent = groupbox.UI.Frame
            
            groupboxLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                groupbox.UI.Frame.Size = UDim2.new(0.45, 0, 0, groupboxLayout.AbsoluteContentSize.Y)
                tab.UI.Content.CanvasSize = UDim2.new(0, 0, 0, tab.UI.Content.UIListLayout.AbsoluteContentSize.Y)
            end)
            
            table.insert(self.Elements, groupbox)

-- TOGGLE CREATION
            function groupbox:AddToggle(id, options)
                print("[DEBUG] Adding Toggle: " .. (options.Text or "Toggle"))
                if not self.UI or not self.UI.Frame then
                    error("[ERROR] Groupbox UI.Frame is nil!")
                end
                
                local toggle = {
                    State = options.Default or false,
                    Callback = options.Callback or function() end,
                    UI = {}
                }
                
                toggle.UI.Button = Instance.new("TextButton")
                toggle.UI.Button.Size = UDim2.new(1, -10, 0, 25)
                toggle.UI.Button.Text = options.Text or "Toggle"
                toggle.UI.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
                toggle.UI.Button.BackgroundColor3 = toggle.State and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 45)
                toggle.UI.Button.Parent = self.UI.Frame
                toggle.UI.Button.Visible = true
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 4)
                toggleCorner.Parent = toggle.UI.Button
                
                toggle.UI.Button.MouseEnter:Connect(function()
                    local tween = TweenService:Create(toggle.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = toggle.State and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(50, 50, 55)
                    })
                    tween:Play()
                end)
                
                toggle.UI.Button.MouseLeave:Connect(function()
                    local tween = TweenService:Create(toggle.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundColor3 = toggle.State and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 45)
                    })
                    tween:Play()
                end)
                
                toggle.UI.Button.MouseButton1Click:Connect(function()
                    toggle.State = not toggle.State
                    toggle.UI.Button.BackgroundColor3 = toggle.State and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 45)
                    toggle.Callback(toggle.State)
                end)
                
                function toggle:AddKeyPicker(keyId, keyOptions)
                    return self
                end
                
                return toggle
            end

-- BUTTON CREATION
            function groupbox:AddButton(options)
                print("[DEBUG] Adding Button: " .. (options.Text or "Button"))
                if not self.UI or not self.UI.Frame then
                    error("[ERROR] Groupbox UI.Frame is nil!")
                end
                
                local button = {
                    Func = options.Func or function() end,
                    UI = {}
                }
                
                button.UI.Button = Instance.new("TextButton")
                button.UI.Button.Size = UDim2.new(1, -10, 0, 25)
                button.UI.Button.Text = options.Text or "Button"
                button.UI.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
                button.UI.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                button.UI.Button.Parent = self.UI.Frame
                button.UI.Button.Visible = true
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = button.UI.Button
                
                button.UI.Button.MouseEnter:Connect(function()
                    local tween = TweenService:Create(button.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                    })
                    tween:Play()
                end)
                
                button.UI.Button.MouseLeave:Connect(function()
                    local tween = TweenService:Create(button.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    })
                    tween:Play()
                end)
                
                button.UI.Button.MouseButton1Click:Connect(function()
                    button.Func()
                end)
                
                return button
            end

-- SLIDER CREATION
            function groupbox:AddSlider(id, options)
                print("[DEBUG] Adding Slider: " .. (options.Text or "Slider"))
                if not self.UI or not self.UI.Frame then
                    error("[ERROR] Groupbox UI.Frame is nil!")
                end
                
                local slider = {
                    Value = options.Default or options.Min or 0,
                    Min = options.Min or 0,
                    Max = options.Max or 100,
                    Callback = options.Callback or function() end,
                    UI = {}
                }
                
                slider.UI.Frame = Instance.new("Frame")
                slider.UI.Frame.Size = UDim2.new(1, -10, 0, 35)
                slider.UI.Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                slider.UI.Frame.Parent = self.UI.Frame
                slider.UI.Frame.Visible = true
                
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 4)
                sliderCorner.Parent = slider.UI.Frame
                
                slider.UI.Label = Instance.new("TextLabel")
                slider.UI.Label.Size = UDim2.new(1, 0, 0, 20)
                slider.UI.Label.Text = options.Text .. ": " .. slider.Value
                slider.UI.Label.TextColor3 = Color3.fromRGB(180, 180, 180)
                slider.UI.Label.BackgroundTransparency = 1
                slider.UI.Label.Font = Enum.Font.Gotham
                slider.UI.Label.TextSize = 12
                slider.UI.Label.Parent = slider.UI.Frame
                slider.UI.Label.Visible = true
                
                slider.UI.SliderBar = Instance.new("Frame")
                slider.UI.SliderBar.Size = UDim2.new(1, 0, 0, 5)
                slider.UI.SliderBar.Position = UDim2.new(0, 0, 1, -5)
                slider.UI.SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                slider.UI.SliderBar.Parent = slider.UI.Frame
                slider.UI.SliderBar.Visible = true
                
                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(0, 2)
                sliderBarCorner.Parent = slider.UI.SliderBar
                
                local mouse = game.Players.LocalPlayer:GetMouse()
                local dragging = false
                
                slider.UI.SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                slider.UI.SliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = math.clamp((input.Position.X - slider.UI.SliderBar.AbsolutePosition.X) / slider.UI.SliderBar.AbsoluteSize.X, 0, 1)
                        slider.Value = math.floor(slider.Min + (slider.Max - slider.Min) * relativeX)
                        slider.UI.Label.Text = options.Text .. ": " .. slider.Value
                        slider.Callback(slider.Value)
                    end
                end)
                
                return slider
            end

-- DROPDOWN CREATION
            function groupbox:AddDropdown(id, options)
                print("[DEBUG] Adding Dropdown: " .. (options.Text or "Dropdown"))
                if not self.UI or not self.UI.Frame then
                    error("[ERROR] Groupbox UI.Frame is nil!")
                end
                
                local dropdown = {
                    Values = options.Values or {},
                    Selected = options.Default or {},
                    Multi = options.Multi or false,
                    Callback = options.Callback or function() end,
                    UI = {}
                }
                
                dropdown.UI.Button = Instance.new("TextButton")
                dropdown.UI.Button.Size = UDim2.new(1, -10, 0, 25)
                dropdown.UI.Button.Text = options.Text .. ": " .. (dropdown.Multi and table.concat(dropdown.Selected, ", ") or dropdown.Selected)
                dropdown.UI.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
                dropdown.UI.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                dropdown.UI.Button.Parent = self.UI.Frame
                dropdown.UI.Button.Visible = true
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 4)
                dropdownCorner.Parent = dropdown.UI.Button
                
                dropdown.UI.Button.MouseEnter:Connect(function()
                    local tween = TweenService:Create(dropdown.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                    })
                    tween:Play()
                end)
                
                dropdown.UI.Button.MouseLeave:Connect(function()
                    local tween = TweenService:Create(dropdown.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    })
                    tween:Play()
                end)
                
                dropdown.UI.Button.MouseButton1Click:Connect(function()
                    print("Dropdown clicked (not implemented)")
                end)
                
                return dropdown
            end

-- COLORPICKER CREATION
            function groupbox:AddColorPicker(id, options)
                print("[DEBUG] Adding ColorPicker: " .. (options.Title or "Color Picker"))
                if not self.UI or not self.UI.Frame then
                    error("[ERROR] Groupbox UI.Frame is nil!")
                end
                
                local colorpicker = {
                    Color = options.Default or Color3.new(1, 1, 1),
                    Callback = options.Callback or function() end,
                    UI = {}
                }
                
                colorpicker.UI.Button = Instance.new("TextButton")
                colorpicker.UI.Button.Size = UDim2.new(1, -10, 0, 25)
                colorpicker.UI.Button.Text = options.Title or "Color Picker"
                colorpicker.UI.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
                colorpicker.UI.Button.BackgroundColor3 = colorpicker.Color
                colorpicker.UI.Button.Parent = self.UI.Frame
                colorpicker.UI.Button.Visible = true
                
                local colorpickerCorner = Instance.new("UICorner")
                colorpickerCorner.CornerRadius = UDim.new(0, 4)
                colorpickerCorner.Parent = colorpicker.UI.Button
                
                colorpicker.UI.Button.MouseEnter:Connect(function()
                    local tween = TweenService:Create(colorpicker.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = colorpicker.Color:Lerp(Color3.new(1, 1, 1), 0.1)
                    })
                    tween:Play()
                end)
                
                colorpicker.UI.Button.MouseLeave:Connect(function()
                    local tween = TweenService:Create(colorpicker.UI.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundColor3 = colorpicker.Color
                    })
                    tween:Play()
                end)
                
                colorpicker.UI.Button.MouseButton1Click:Connect(function()
                    print("ColorPicker clicked (not implemented)")
                end)
                
                return colorpicker
            end

-- INPUT CREATION
            function groupbox:AddInput(id, options)
                print("[DEBUG] Adding Input: " .. (options.Text or "Input"))
                if not self.UI or not self.UI.Frame then
                    error("[ERROR] Groupbox UI.Frame is nil!")
                end
                
                local input = {
                    Text = options.Default or "",
                    Callback = options.Callback or function() end,
                    UI = {}
                }
                
                input.UI.TextBox = Instance.new("TextBox")
                input.UI.TextBox.Size = UDim2.new(1, -10, 0, 25)
                input.UI.TextBox.Text = options.Text .. ": " .. input.Text
                input.UI.TextBox.TextColor3 = Color3.fromRGB(180, 180, 180)
                input.UI.TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                input.UI.TextBox.Parent = self.UI.Frame
                input.UI.TextBox.Visible = true
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 4)
                inputCorner.Parent = input.UI.TextBox
                
                input.UI.TextBox.FocusLost:Connect(function()
                    input.Text = input.UI.TextBox.Text
                    input.Callback(input.Text)
                end)
                
                return input
            end
            
            return groupbox
        end

-- RIGHT GROUPBOX CREATION
        function tab:AddRightGroupbox(name)
            local groupbox = tab:AddLeftGroupbox(name)
            groupbox.UI.Frame.Position = UDim2.new(0.5, 5, 0, 5)
            return groupbox
        end
        
        return tab
    end

-- TAB SWITCHING
    function window:SwitchTab(index)
        for i, tab in ipairs(self.Tabs) do
            if i == index then
                tab.UI.Content.Visible = true
                tab.UI.Content.Position = UDim2.new(0, 0, 0, 0)
                local tweenIn = TweenService:Create(tab.UI.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0)
                })
                for _, child in pairs(tab.UI.Content:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                        end
                        if child:IsA("Frame") or child:IsA("TextButton") then
                            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                        end
                    end
                end
                tweenIn:Play()
            else
                local tweenOut = TweenService:Create(tab.UI.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, 150, 0, 0)
                })
                for _, child in pairs(tab.UI.Content:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
                        end
                        if child:IsA("Frame") or child:IsA("TextButton") then
                            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
                        end
                    end
                end
                tweenOut.Completed:Connect(function()
                    tab.UI.Content.Visible = false
                end)
                tweenOut:Play()
            end
            tab.UI.Button.BackgroundColor3 = (i == index) and Color3.fromRGB(50, 50, 55) or Color3.fromRGB(30, 30, 35)
        end
    end
    
    return window
end

return SolaraHub
