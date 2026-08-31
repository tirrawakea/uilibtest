--[[
    Modern UI Library for Roblox Executors
    Version: 1.0.0
    Author: Your Name
    Description: A comprehensive UI library for Roblox executors with dark/light theme support
    
    Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/UILibrary.lua"))()
]]

-- Wrap everything in a function to avoid global pollution
local function CreateUILibrary()
    local UILibrary = {}
    UILibrary.__index = UILibrary

    -- Services
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")

    -- Types
    export type UIComponent = {
        Instance: GuiObject,
        Type: string,
        Properties: {[string]: any},
        Events: {[string]: {(...any) -> ()}},
        Destroy: (self: UIComponent) -> (),
        SetProperty: (self: UIComponent, property: string, value: any) -> (),
        GetProperty: (self: UIComponent, property: string) -> any,
        Connect: (self: UIComponent, event: string, callback: (...any) -> ()) -> (),
        Disconnect: (self: UIComponent, event: string) -> (),
    }

    -- Theme System
    local Theme = {
        Current = "dark",
        Colors = {
            dark = {
                Background = Color3.fromRGB(30, 30, 35),
                Surface = Color3.fromRGB(45, 45, 50),
                Primary = Color3.fromRGB(0, 120, 255),
                Secondary = Color3.fromRGB(80, 80, 85),
                Text = Color3.fromRGB(255, 255, 255),
                TextSecondary = Color3.fromRGB(180, 180, 185),
                Border = Color3.fromRGB(60, 60, 65),
                Success = Color3.fromRGB(0, 200, 80),
                Danger = Color3.fromRGB(255, 70, 70),
                Warning = Color3.fromRGB(255, 170, 0),
                Shadow = Color3.fromRGB(0, 0, 0),
            },
            light = {
                Background = Color3.fromRGB(245, 245, 250),
                Surface = Color3.fromRGB(255, 255, 255),
                Primary = Color3.fromRGB(0, 120, 255),
                Secondary = Color3.fromRGB(200, 200, 205),
                Text = Color3.fromRGB(0, 0, 0),
                TextSecondary = Color3.fromRGB(80, 80, 85),
                Border = Color3.fromRGB(220, 220, 225),
                Success = Color3.fromRGB(0, 200, 80),
                Danger = Color3.fromRGB(255, 70, 70),
                Warning = Color3.fromRGB(255, 170, 0),
                Shadow = Color3.fromRGB(0, 0, 0),
            }
        },
        Fonts = {
            Default = Enum.Font.Gotham,
            Bold = Enum.Font.GothamBold,
            Medium = Enum.Font.GothamMedium,
            Light = Enum.Font.Gotham,
            Semibold = Enum.Font.GothamSemibold,
        }
    }

    -- Utility Functions
    local function CreateShadow(instance: GuiObject, size: number, transparency: number)
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Image = "rbxassetid://1316045226"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = transparency or 0.5
        shadow.BackgroundTransparency = 1
        shadow.Size = UDim2.new(1, size * 2, 1, size * 2)
        shadow.Position = UDim2.new(0, -size, 0, -size)
        shadow.ZIndex = instance.ZIndex - 1
        shadow.Parent = instance
        return shadow
    end

    local function Animate(instance: GuiObject, properties: {[string]: any}, duration: number)
        local tweenInfo = TweenInfo.new(
            duration or 0.3,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(instance, tweenInfo, properties)
        tween:Play()
        return tween
    end

    -- Component Factory
    local function CreateComponent(type: string, parent: GuiObject, properties: {[string]: any}): UIComponent
        local component = setmetatable({}, UILibrary)
        
        -- Create base instance
        local instance: GuiObject
        local isInteractable = false
        
        if type == "Button" or type == "Toggle" or type == "Checkbox" then
            instance = Instance.new("TextButton")
            isInteractable = true
        elseif type == "TextBox" then
            instance = Instance.new("TextBox")
            isInteractable = true
        elseif type == "Slider" then
            instance = Instance.new("Frame")
        elseif type == "Dropdown" then
            instance = Instance.new("Frame")
        elseif type == "Label" then
            instance = Instance.new("TextLabel")
        else
            instance = Instance.new("Frame")
        end
        
        -- Set defaults
        instance.Name = type
        instance.Parent = parent or nil
        instance.BackgroundTransparency = properties.BackgroundTransparency or 0
        instance.BorderSizePixel = 0
        
        -- Apply properties
        for key, value in pairs(properties) do
            if key ~= "Children" then
                pcall(function()
                    instance[key] = value
                end)
            end
        end
        
        -- Apply theme
        local colorTheme = Theme.Colors[Theme.Current]
        if not properties.BackgroundColor3 and not properties.BackgroundTransparency then
            if type == "Button" then
                instance.BackgroundColor3 = colorTheme.Primary
            elseif type == "Toggle" or type == "Checkbox" then
                instance.BackgroundColor3 = colorTheme.Surface
            elseif type == "Slider" then
                instance.BackgroundColor3 = colorTheme.Surface
            elseif type == "Dropdown" then
                instance.BackgroundColor3 = colorTheme.Surface
            else
                instance.BackgroundColor3 = colorTheme.Surface
            end
        end
        
        if not properties.TextColor3 then
            if type == "Button" then
                instance.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                instance.TextColor3 = colorTheme.Text
            end
        end
        
        if not properties.Font then
            instance.Font = Theme.Fonts.Default
        end
        
        if not properties.TextSize then
            instance.TextSize = 14
        end
        
        -- Add shadow for elevated components
        if properties.Shadow ~= false and type ~= "Button" and type ~= "Toggle" and type ~= "Checkbox" then
            CreateShadow(instance, 4, 0.3)
        end
        
        -- Children
        if properties.Children then
            for _, child in ipairs(properties.Children) do
                child.Parent = instance
            end
        end
        
        -- Component table
        component.Instance = instance
        component.Type = type
        component.Properties = properties
        component.Events = {
            Clicked = {},
            Changed = {},
            Hovered = {},
            Unhovered = {},
            InputBegan = {},
            InputEnded = {},
            Submitted = {},
            Selected = {},
            Opened = {},
            Closed = {},
        }
        
        -- Methods
        function component:Destroy()
            self.Instance:Destroy()
            setmetatable(self, nil)
        end
        
        function component:SetProperty(property: string, value: any)
            pcall(function()
                self.Instance[property] = value
            end)
            self.Properties[property] = value
            self:FireEvent("Changed", property, value)
        end
        
        function component:GetProperty(property: string)
            return self.Instance[property]
        end
        
        function component:Connect(event: string, callback: (...any) -> ())
            if not self.Events[event] then
                self.Events[event] = {}
            end
            table.insert(self.Events[event], callback)
        end
        
        function component:Disconnect(event: string, callback: (...any) -> ())
            if self.Events[event] then
                for i, cb in ipairs(self.Events[event]) do
                    if cb == callback then
                        table.remove(self.Events[event], i)
                        break
                    end
                end
            end
        end
        
        function component:FireEvent(event: string, ...)
            if self.Events[event] then
                for _, callback in ipairs(self.Events[event]) do
                    callback(...)
                end
            end
        end
        
        -- Interactive events
        if isInteractable then
            instance.MouseButton1Click:Connect(function()
                component:FireEvent("Clicked")
            end)
            
            instance.MouseEnter:Connect(function()
                if type ~= "TextBox" then
                    local baseColor = Theme.Colors[Theme.Current].Primary
                    if type == "Toggle" or type == "Checkbox" then
                        baseColor = Theme.Colors[Theme.Current].Surface
                    end
                    local hoverColor = baseColor:Lerp(Color3.fromRGB(255,255,255), 0.15)
                    Animate(instance, {
                        BackgroundColor3 = hoverColor
                    }, 0.2)
                end
                component:FireEvent("Hovered")
            end)
            
            instance.MouseLeave:Connect(function()
                if type ~= "TextBox" then
                    local color = Theme.Colors[Theme.Current].Primary
                    if type == "Toggle" or type == "Checkbox" then
                        color = Theme.Colors[Theme.Current].Surface
                    end
                    Animate(instance, {
                        BackgroundColor3 = color
                    }, 0.2)
                end
                component:FireEvent("Unhovered")
            end)
        end
        
        -- Type-specific setup
        if type == "Button" then
            instance.AutoButtonColor = false
            instance.Text = properties.Text or "Button"
            instance.TextScaled = properties.TextScaled or false
            
        elseif type == "Toggle" then
            instance.AutoButtonColor = false
            instance.Text = ""
            instance.BackgroundColor3 = Theme.Colors[Theme.Current].Surface
            instance.Size = properties.Size or UDim2.new(0, 60, 0, 30)
            
            -- Create toggle indicator
            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.Size = UDim2.new(0, 20, 0, 20)
            indicator.Position = UDim2.new(0, 4, 0.5, -10)
            indicator.BackgroundColor3 = Theme.Colors[Theme.Current].Secondary
            indicator.BorderSizePixel = 0
            indicator.Parent = instance
            
            local circle = Instance.new("Frame")
            circle.Name = "Circle"
            circle.Size = UDim2.new(0, 14, 0, 14)
            circle.Position = UDim2.new(0, 3, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.BorderSizePixel = 0
            circle.Parent = indicator
            
            -- Label
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Name = "Label"
            toggleLabel.Size = UDim2.new(0, 100, 0, 20)
            toggleLabel.Position = UDim2.new(0, 30, 0.5, -10)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.TextColor3 = Theme.Colors[Theme.Current].Text
            toggleLabel.Font = Theme.Fonts.Default
            toggleLabel.TextSize = 12
            toggleLabel.Text = properties.Label or ""
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = instance
            
            component.IsOn = false
            
            component.Toggle = function(value)
                local isOn = (value ~= nil and value) or not component.IsOn
                component.IsOn = isOn
                
                local targetColor = isOn and Theme.Colors[Theme.Current].Primary or Theme.Colors[Theme.Current].Secondary
                local targetPosition = isOn and UDim2.new(0, 32, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
                
                Animate(indicator, {BackgroundColor3 = targetColor}, 0.3)
                Animate(indicator, {Position = targetPosition}, 0.3)
                
                component:FireEvent("Changed", "IsOn", isOn)
            end
            
            instance.MouseButton1Click:Connect(function()
                component:Toggle()
            end)
            
            if properties.IsOn then
                component:Toggle(true)
            end
            
        elseif type == "Checkbox" then
            instance.AutoButtonColor = false
            instance.Text = ""
            instance.BackgroundColor3 = Theme.Colors[Theme.Current].Surface
            instance.Size = properties.Size or UDim2.new(0, 24, 0, 24)
            
            -- Checkmark
            local checkmark = Instance.new("TextLabel")
            checkmark.Name = "Checkmark"
            checkmark.Size = UDim2.new(1, 0, 1, 0)
            checkmark.BackgroundTransparency = 1
            checkmark.Text = "✓"
            checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
            checkmark.TextSize = 18
            checkmark.TextScaled = true
            checkmark.Visible = properties.IsOn or false
            checkmark.Parent = instance
            
            -- Label
            local checkLabel = Instance.new("TextLabel")
            checkLabel.Name = "Label"
            checkLabel.Size = UDim2.new(0, 100, 0, 20)
            checkLabel.Position = UDim2.new(0, 30, 0.5, -10)
            checkLabel.BackgroundTransparency = 1
            checkLabel.TextColor3 = Theme.Colors[Theme.Current].Text
            checkLabel.Font = Theme.Fonts.Default
            checkLabel.TextSize = 12
            checkLabel.Text = properties.Label or ""
            checkLabel.TextXAlignment = Enum.TextXAlignment.Left
            checkLabel.Parent = instance
            
            component.IsOn = false
            
            component.Toggle = function(value)
                local isOn = (value ~= nil and value) or not component.IsOn
                component.IsOn = isOn
                
                local targetColor = isOn and Theme.Colors[Theme.Current].Primary or Theme.Colors[Theme.Current].Surface
                Animate(instance, {BackgroundColor3 = targetColor}, 0.2)
                checkmark.Visible = isOn
                
                component:FireEvent("Changed", "IsOn", isOn)
            end
            
            instance.MouseButton1Click:Connect(function()
                component:Toggle()
            end)
            
            if properties.IsOn then
                component:Toggle(true)
            end
            
        elseif type == "TextBox" then
            instance.BackgroundColor3 = Theme.Colors[Theme.Current].Surface
            instance.Text = properties.Text or ""
            instance.PlaceholderText = properties.PlaceholderText or "Enter text..."
            instance.ClearTextOnFocus = properties.ClearOnFocus or false
            
            instance:GetPropertyChangedSignal("Text"):Connect(function()
                component:FireEvent("Changed", "Text", instance.Text)
            end)
            
            instance.FocusLost:Connect(function(enterPressed)
                component:FireEvent("InputEnded", enterPressed)
                if enterPressed then
                    component:FireEvent("Submitted", instance.Text)
                end
            end)
            
            instance.Focus:Connect(function()
                component:FireEvent("InputBegan")
            end)
            
        elseif type == "Slider" then
            local min = properties.Min or 0
            local max = properties.Max or 100
            local value = properties.Value or 50
            local step = properties.Step or 1
            
            instance.BackgroundColor3 = Theme.Colors[Theme.Current].Surface
            instance.Size = properties.Size or UDim2.new(1, 0, 0, 40)
            
            -- Track
            local track = Instance.new("Frame")
            track.Name = "Track"
            track.Size = UDim2.new(1, -20, 0, 6)
            track.Position = UDim2.new(0, 10, 0.5, -3)
            track.BackgroundColor3 = Theme.Colors[Theme.Current].Secondary
            track.BorderSizePixel = 0
            track.Parent = instance
            
            -- Fill
            local fill = Instance.new("Frame")
            fill.Name = "Fill"
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Colors[Theme.Current].Primary
            fill.BorderSizePixel = 0
            fill.Parent = track
            
            -- Handle
            local handle = Instance.new("Frame")
            handle.Name = "Handle"
            handle.Size = UDim2.new(0, 18, 0, 18)
            handle.Position = UDim2.new((value - min) / (max - min), -9, 0.5, -9)
            handle.BackgroundColor3 = Theme.Colors[Theme.Current].Primary
            handle.BorderSizePixel = 0
            handle.Parent = instance
            CreateShadow(handle, 4, 0.3)
            
            -- Value label
            local label = Instance.new("TextLabel")
            label.Name = "ValueLabel"
            label.Size = UDim2.new(0, 40, 0, 20)
            label.Position = UDim2.new(1, -50, 0.5, -10)
            label.BackgroundTransparency = 1
            label.TextColor3 = Theme.Colors[Theme.Current].Text
            label.Font = Theme.Fonts.Default
            label.TextSize = 12
            label.Text = tostring(value)
            label.Parent = instance
            
            -- Slider label
            if properties.Label then
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "Label"
                sliderLabel.Size = UDim2.new(0, 60, 0, 20)
                sliderLabel.Position = UDim2.new(0, 0, 0.5, -10)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.TextColor3 = Theme.Colors[Theme.Current].Text
                sliderLabel.Font = Theme.Fonts.Default
                sliderLabel.TextSize = 12
                sliderLabel.Text = properties.Label
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = instance
            end
            
            component.Value = value
            component.Min = min
            component.Max = max
            
            local dragging = false
            
            local function SetValue(newValue)
                newValue = math.clamp(math.round(newValue / step) * step, min, max)
                component.Value = newValue
                
                local percent = (newValue - min) / (max - min)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(percent, -9, 0.5, -9)
                label.Text = tostring(newValue)
                
                component:FireEvent("Changed", "Value", newValue)
            end
            
            instance.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local mousePos = UserInputService:GetMouseLocation()
                    local absPos = instance.AbsolutePosition
                    local width = instance.AbsoluteSize.X
                    local percent = math.clamp((mousePos.X - absPos.X) / width, 0, 1)
                    SetValue(min + (max - min) * percent)
                    component:FireEvent("InputBegan")
                end
            end)
            
            instance.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    component:FireEvent("InputEnded")
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local absPos = instance.AbsolutePosition
                    local width = instance.AbsoluteSize.X
                    local percent = math.clamp((input.Position.X - absPos.X) / width, 0, 1)
                    SetValue(min + (max - min) * percent)
                end
            end)
            
        elseif type == "Dropdown" then
            instance.BackgroundColor3 = Theme.Colors[Theme.Current].Surface
            instance.Size = properties.Size or UDim2.new(1, 0, 0, 40)
            instance.ClipsDescendants = false
            
            -- Main button
            local mainButton = Instance.new("TextButton")
            mainButton.Name = "MainButton"
            mainButton.Size = UDim2.new(1, 0, 1, 0)
            mainButton.BackgroundTransparency = 1
            mainButton.Text = properties.Placeholder or "Select option"
            mainButton.TextColor3 = Theme.Colors[Theme.Current].Text
            mainButton.Font = Theme.Fonts.Default
            mainButton.TextSize = 14
            mainButton.TextXAlignment = Enum.TextXAlignment.Left
            mainButton.TextYAlignment = Enum.TextYAlignment.Center
            mainButton.AutoButtonColor = false
            mainButton.Parent = instance
            
            -- Arrow
            local arrow = Instance.new("TextLabel")
            arrow.Name = "Arrow"
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Theme.Colors[Theme.Current].TextSecondary
            arrow.TextSize = 12
            arrow.Parent = mainButton
            
            -- Dropdown items container
            local container = Instance.new("Frame")
            container.Name = "Container"
            container.Size = UDim2.new(1, 0, 0, 0)
            container.Position = UDim2.new(0, 0, 1, 2)
            container.BackgroundColor3 = Theme.Colors[Theme.Current].Surface
            container.BackgroundTransparency = 0
            container.BorderSizePixel = 1
            container.BorderColor3 = Theme.Colors[Theme.Current].Border
            container.ClipsDescendants = true
            container.Visible = false
            container.ZIndex = 100
            container.Parent = instance
            
            component.Options = {}
            component.Selected = nil
            component.IsOpen = false
            
            function component:AddOption(text, value)
                local button = Instance.new("TextButton")
                button.Name = "Option"
                button.Size = UDim2.new(1, 0, 0, 30)
                button.BackgroundTransparency = 1
                button.Text = "  " .. tostring(text)
                button.TextColor3 = Theme.Colors[Theme.Current].Text
                button.Font = Theme.Fonts.Default
                button.TextSize = 14
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.TextYAlignment = Enum.TextYAlignment.Center
                button.AutoButtonColor = false
                button.Parent = container
                
                -- Hover effect
                button.MouseEnter:Connect(function()
                    button.BackgroundTransparency = 0
                    button.BackgroundColor3 = Theme.Colors[Theme.Current].Primary
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                end)
                button.MouseLeave:Connect(function()
                    button.BackgroundTransparency = 1
                    button.TextColor3 = Theme.Colors[Theme.Current].Text
                end)
                
                button.MouseButton1Click:Connect(function()
                    mainButton.Text = tostring(text)
                    component.Selected = value
                    component:FireEvent("Selected", value, text)
                    component:Close()
                end)
                
                table.insert(component.Options, {Text = text, Value = value, Button = button})
                
                -- Update container height
                local count = #component.Options
                container.Size = UDim2.new(1, 0, 0, count * 30 + 2)
            end
            
            function component:Open()
                self.IsOpen = true
                container.Visible = true
                container.Size = UDim2.new(1, 0, 0, #self.Options * 30 + 2)
                arrow.Text = "▲"
                component:FireEvent("Opened")
            end
            
            function component:Close()
                self.IsOpen = false
                container.Visible = false
                container.Size = UDim2.new(1, 0, 0, 0)
                arrow.Text = "▼"
                component:FireEvent("Closed")
            end
            
            function component:Toggle()
                if self.IsOpen then
                    self:Close()
                else
                    self:Open()
                end
            end
            
            mainButton.MouseButton1Click:Connect(function()
                component:Toggle()
            end)
            
            -- Add initial options
            if properties.Options then
                for _, opt in ipairs(properties.Options) do
                    component:AddOption(opt.Text, opt.Value or opt.Text)
                end
            end
        end
        
        return component
    end

    -- Public API
    function UILibrary:Create(parent: GuiObject, type: string, properties: {[string]: any}): UIComponent
        return CreateComponent(type, parent, properties)
    end

    -- Create window/dialog
    function UILibrary:CreateWindow(parent: GuiObject, properties: {[string]: any})
        local window = self:Create(parent, "Frame", {
            Size = properties.Size or UDim2.new(0, 400, 0, 300),
            Position = properties.Position or UDim2.new(0.5, -200, 0.5, -150),
            BackgroundColor3 = Theme.Colors[Theme.Current].Background,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Shadow = true,
            Children = properties.Children or {}
        })
        
        -- Title bar
        local titleBar = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 40)
        titleBar.BackgroundColor3 = Theme.Colors[Theme.Current].Primary
        titleBar.BorderSizePixel = 0
        titleBar.Parent = window.Instance
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -20, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = properties.Title or "Window"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Theme.Fonts.Bold
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = titleBar
        
        -- Close button
        if properties.Closable ~= false then
            local closeBtn = Instance.new("TextButton")
            closeBtn.Name = "CloseButton"
            closeBtn.Size = UDim2.new(0, 30, 1, 0)
            closeBtn.Position = UDim2.new(1, -30, 0, 0)
            closeBtn.BackgroundTransparency = 1
            closeBtn.Text = "✕"
            closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeBtn.TextSize = 16
            closeBtn.Font = Theme.Fonts.Default
            closeBtn.AutoButtonColor = false
            closeBtn.Parent = titleBar
            
            closeBtn.MouseButton1Click:Connect(function()
                window.Instance.Visible = false
                window:FireEvent("Closed")
            end)
            
            closeBtn.MouseEnter:Connect(function()
                closeBtn.BackgroundTransparency = 0.5
                closeBtn.BackgroundColor3 = Theme.Colors[Theme.Current].Danger
            end)
            
            closeBtn.MouseLeave:Connect(function()
                closeBtn.BackgroundTransparency = 1
            end)
        end
        
        -- Draggable
        if properties.Draggable ~= false then
            local dragging = false
            local dragStart, posStart
            
            titleBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = input.Position
                    posStart = window.Instance.Position
                    window.Instance.ZIndex = 999
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Position - dragStart
                    window.Instance.Position = UDim2.new(
                        posStart.X.Scale,
                        posStart.X.Offset + delta.X,
                        posStart.Y.Scale,
                        posStart.Y.Offset + delta.Y
                    )
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
        end
        
        -- Content area
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 1, -40)
        content.Position = UDim2.new(0, 0, 0, 40)
        content.BackgroundTransparency = 1
        content.Parent = window.Instance
        
        -- Create content area for children
        local contentUI = setmetatable({
            Instance = content,
            Type = "Content",
            Events = {},
            Connect = function() end,
            FireEvent = function() end,
            Destroy = function() end,
        }, UILibrary)
        
        return window, contentUI
    end

    -- Theme management
    function UILibrary:SetTheme(themeName: string)
        if Theme.Colors[themeName] then
            Theme.Current = themeName
            self:FireEvent("ThemeChanged", themeName)
            return true
        end
        return false
    end

    function UILibrary:GetTheme()
        return Theme.Current
    end

    function UILibrary:GetColors()
        return Theme.Colors[Theme.Current]
    end

    -- Events system
    UILibrary.Events = {
        ThemeChanged = {},
    }

    function UILibrary:FireEvent(event: string, ...)
        if self.Events[event] then
            for _, callback in ipairs(self.Events[event]) do
                callback(...)
            end
        end
    end

    function UILibrary:Connect(event: string, callback: (...any) -> ())
        if not self.Events[event] then
            self.Events[event] = {}
        end
        table.insert(self.Events[event], callback)
    end

    return UILibrary
end

-- Return the library
return CreateUILibrary()
