-- WINDOW CREATE
local SolaraHub = {}
local TweenService = game:GetService("TweenService")

function SolaraHub:CreateWindow(options)
    options = options or {}
    
    local window = {
        Tabs = {},
        Options = {
            Title = options.Title or "Solara Hub",
            Center = options.Center or true,
            AutoShow = options.AutoShow or true,
            TabPadding = options.TabPadding or 10,
            MenuFadeTime = options.MenuFadeTime or 0.2
        },
        UI = {},
        Notify = function(self, message)
            print("[SolaraHub] " .. message)
        end,
        ToggleUI = function(self)
            if self.UI.ScreenGui.Enabled then
                self:HideUI()
            else
                self:ShowUI()
            end
        end,
        ShowUI = function(self)
            self.UI.ScreenGui.Enabled = true
            local tweenInfo = TweenInfo.new(self.Options.MenuFadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            local tween = TweenService:Create(self.UI.MainFrame, tweenInfo, {
                BackgroundTransparency = 0,
                Position = self.UI.MainFrame.Position
            })
            for _, child in pairs(self.UI.MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        TweenService:Create(child, tweenInfo, {TextTransparency = 0}):Play()
                    end
                    if child:IsA("Frame") or child:IsA("TextButton") then
                        TweenService:Create(child, tweenInfo, {BackgroundTransparency = child.BackgroundTransparency - 0.5}):Play()
                    end
                end
            end
            tween:Play()
        end,
        HideUI = function(self)
            local tweenInfo = TweenInfo.new(self.Options.MenuFadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            local tween = TweenService:Create(self.UI.MainFrame, tweenInfo, {
                BackgroundTransparency = 1,
                Position = self.UI.MainFrame.Position + UDim2.new(0, 0, 0, 50)
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
            end)
            tween:Play()
        end
    }
    
    window.UI.ScreenGui = Instance.new("ScreenGui")
    window.UI.ScreenGui.Name = "SolaraHub"
    window.UI.ScreenGui.Parent = game:GetService("CoreGui")
    window.UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    window.UI.ScreenGui.ResetOnSpawn = false
    
    window.UI.MainFrame = Instance.new("Frame")
    window.UI.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    window.UI.MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    window.UI.MainFrame.Parent = window.UI.ScreenGui
    window.UI.MainFrame.ClipsDescendants = true
    
    if window.Options.Center then
        window.UI.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    else
        window.UI.MainFrame.Position = UDim2.new(0, 100, 0, 100)
    end
    
    window.UI.Title = Instance.new("TextLabel")
    window.UI.Title.Size = UDim2.new(1, 0, 0, 30)
    window.UI.Title.Text = window.Options.Title
    window.UI.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    window.UI.Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    window.UI.Title.Font = Enum.Font.GothamBold
    window.UI.Title.TextSize = 16
    window.UI.Title.Parent = window.UI.MainFrame
    
    window.UI.TabButtons = Instance.new("Frame")
    window.UI.TabButtons.Size = UDim2.new(0, 150, 1, -30)
    window.UI.TabButtons.Position = UDim2.new(0, 0, 0, 30)
    window.UI.TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    window.UI.TabButtons.Parent = window.UI.MainFrame
    
    window.UI.Content = Instance.new("Frame")
    window.UI.Content.Size = UDim2.new(1, -150, 1, -30)
    window.UI.Content.Position = UDim2.new(0, 150, 0, 30)
    window.UI.Content.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    window.UI.Content.ClipsDescendants = true
    window.UI.Content.Parent = window.UI.MainFrame

    local dragging = false
    local dragStart = nil
    local startPos = nil

    window.UI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.UI.MainFrame.Position
        end
    end)

    window.UI.MainFrame.InputChanged:Connect(function(input)
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

    window.UI.MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

-- TAB CREATION
    function window:AddTab(name)
        local tab = {
            Name = name,
            Elements = {},
            UI = {}
        }
        
        tab.UI.Button = Instance.new("TextButton")
        tab.UI.Button.Size = UDim2.new(1, -10, 0, 30)
        tab.UI.Button.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * 35))
        tab.UI.Button.Text = name
        tab.UI.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.UI.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tab.UI.Button.Font = Enum.Font.GothamSemibold
        tab.UI.Button.TextSize = 14
        tab.UI.Button.Parent = window.UI.TabButtons
        
        tab.UI.Content = Instance.new("ScrollingFrame")
        tab.UI.Content.Size = UDim2.new(1, 0, 1, 0)
        tab.UI.Content.BackgroundTransparency = 1
        tab.UI.Content.Visible = false
        tab.UI.Content.ScrollBarThickness = 5
        tab.UI.Content.Parent = window.UI.Content
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, window.Options.TabPadding)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = tab.UI.Content
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.UI.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end)
        
        table.insert(self.Tabs, tab)
        
        if #self.Tabs == 1 then
            self:SwitchTab(1)
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
            groupbox.UI.Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            groupbox.UI.Frame.Parent = self.UI.Content
            groupbox.UI.Frame.LayoutOrder = #self.Elements
            
            groupbox.UI.Title = Instance.new("TextLabel")
            groupbox.UI.Title.Size = UDim2.new(1, 0, 0, 20)
            groupbox.UI.Title.Text = name
            groupbox.UI.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
                if not toggle.UI.Button then
                    error("[ERROR] Failed to create TextButton for Toggle!")
                end
                
                toggle.UI.Button.Size = UDim2.new(1, -10, 0, 20)
                toggle.UI.Button.Text = options.Text or "Toggle"
                toggle.UI.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggle.UI.Button.BackgroundColor3 = toggle.State and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(40, 40, 50)
                toggle.UI.Button.Parent = self.UI.Frame
                toggle.UI.Button.Visible = true
                
                toggle.UI.Button.MouseButton1Click:Connect(function()
                    toggle.State = not toggle.State
                    toggle.UI.Button.BackgroundColor3 = toggle.State and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(40, 40, 50)
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
                if not button.UI.Button then
                    error("[ERROR] Failed to create TextButton for Button!")
                end
                
                button.UI.Button.Size = UDim2.new(1, -10, 0, 20)
                button.UI.Button.Text = options.Text or "Button"
                button.UI.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.UI.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                button.UI.Button.Parent = self.UI.Frame
                button.UI.Button.Visible = true
                
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
                slider.UI.Frame.Size = UDim2.new(1, -10, 0, 30)
                slider.UI.Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                slider.UI.Frame.Parent = self.UI.Frame
                slider.UI.Frame.Visible = true
                
                slider.UI.Label = Instance.new("TextLabel")
                slider.UI.Label.Size = UDim2.new(1, 0, 0, 20)
                slider.UI.Label.Text = options.Text .. ": " .. slider.Value
                slider.UI.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                slider.UI.Label.BackgroundTransparency = 1
                slider.UI.Label.Parent = slider.UI.Frame
                slider.UI.Label.Visible = true
                
                slider.UI.SliderBar = Instance.new("Frame")
                slider.UI.SliderBar.Size = UDim2.new(1, 0, 0, 5)
                slider.UI.SliderBar.Position = UDim2.new(0, 0, 1, -5)
                slider.UI.SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                slider.UI.SliderBar.Parent = slider.UI.Frame
                slider.UI.SliderBar.Visible = true
                
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
                dropdown.UI.Button.Size = UDim2.new(1, -10, 0, 20)
                dropdown.UI.Button.Text = options.Text .. ": " .. (dropdown.Multi and table.concat(dropdown.Selected, ", ") or dropdown.Selected)
                dropdown.UI.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdown.UI.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                dropdown.UI.Button.Parent = self.UI.Frame
                dropdown.UI.Button.Visible = true
                
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
                colorpicker.UI.Button.Size = UDim2.new(1, -10, 0, 20)
                colorpicker.UI.Button.Text = options.Title or "Color Picker"
                colorpicker.UI.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                colorpicker.UI.Button.BackgroundColor3 = colorpicker.Color
                colorpicker.UI.Button.Parent = self.UI.Frame
                colorpicker.UI.Button.Visible = true
                
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
                input.UI.TextBox.Size = UDim2.new(1, -10, 0, 20)
                input.UI.TextBox.Text = options.Text .. ": " .. input.Text
                input.UI.TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                input.UI.TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                input.UI.TextBox.Parent = self.UI.Frame
                input.UI.TextBox.Visible = true
                
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
            tab.UI.Content.Visible = (i == index)
            tab.UI.Button.BackgroundColor3 = (i == index) and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(40, 40, 50)
        end
    end
    
    if window.Options.AutoShow then
        window:ShowUI()
    end
    
    return window
end

return SolaraHub
