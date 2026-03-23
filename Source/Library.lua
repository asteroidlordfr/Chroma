--[[

© Chroma, 2026
Yet another Universal script for Roblox.

Fully open-sourced, and free forever.
I don't really know if I plan on long term support for this project, but I review pull requests and would be glad to add some.

Enjoying the script? Star us on GitHub: github.com/asteroidlordfr/Chroma
                                        ^^ you can also read our source code, open pull requests, and issues.
Comments are placed as **DEV COMMENTS**, it is meant to explain parts of the code, credit contributors and other purposes.

--]]

local Library = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui
local MainFrame
local SidebarFrame
local ContentFrame
local TopBarFrame
local TabsContainer
local WindowTitle
local CloseButton

local CurrentTab = nil
local Tabs = {}
local ActiveToggles = {}
local Theme = "Ocean"
local Dragging = false
local DragStart = nil
local DragStartPos = nil

local Themes = {
    Ocean = {
        Primary = Color3.fromRGB(0, 120, 255),
        Secondary = Color3.fromRGB(30, 30, 40),
        Background = Color3.fromRGB(20, 20, 30),
        Surface = Color3.fromRGB(25, 25, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 170),
        Success = Color3.fromRGB(76, 175, 80),
        Danger = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Border = Color3.fromRGB(40, 40, 50),
        Hover = Color3.fromRGB(35, 35, 45)
    },
    Dark = {
        Primary = Color3.fromRGB(156, 39, 176),
        Secondary = Color3.fromRGB(30, 30, 40),
        Background = Color3.fromRGB(18, 18, 24),
        Surface = Color3.fromRGB(24, 24, 32),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 170),
        Success = Color3.fromRGB(76, 175, 80),
        Danger = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Border = Color3.fromRGB(40, 40, 50),
        Hover = Color3.fromRGB(35, 35, 45)
    },
    Neon = {
        Primary = Color3.fromRGB(0, 255, 200),
        Secondary = Color3.fromRGB(20, 20, 30),
        Background = Color3.fromRGB(10, 10, 18),
        Surface = Color3.fromRGB(15, 15, 25),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 170),
        Success = Color3.fromRGB(76, 175, 80),
        Danger = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Border = Color3.fromRGB(0, 255, 200),
        Hover = Color3.fromRGB(25, 25, 35)
    },
    Royal = {
        Primary = Color3.fromRGB(255, 64, 129),
        Secondary = Color3.fromRGB(30, 25, 35),
        Background = Color3.fromRGB(20, 15, 25),
        Surface = Color3.fromRGB(25, 20, 30),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 150, 170),
        Success = Color3.fromRGB(76, 175, 80),
        Danger = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Border = Color3.fromRGB(255, 64, 129),
        Hover = Color3.fromRGB(35, 30, 40)
    }
}

local TweenInfo = {
    In = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Out = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

local function GetColor(key)
    return Themes[Theme][key]
end

local function CreateTween(obj, props, time, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(time or 0.2, style, direction)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

function Library:CreateWindow(options)
    options = options or {}
    Theme = options.Theme or "Ocean"

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ChromaUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 800, 0, 550)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -275)
    MainFrame.BackgroundColor3 = GetColor("Background")
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.Parent = MainFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame

    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 12)
    ShadowCorner.Parent = Shadow

    TopBarFrame = Instance.new("Frame")
    TopBarFrame.Size = UDim2.new(1, 0, 0, 40)
    TopBarFrame.BackgroundColor3 = GetColor("Secondary")
    TopBarFrame.BackgroundTransparency = 0.95
    TopBarFrame.BorderSizePixel = 0
    TopBarFrame.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBarFrame

    WindowTitle = Instance.new("TextLabel")
    WindowTitle.Size = UDim2.new(0, 200, 1, 0)
    WindowTitle.Position = UDim2.new(0, 15, 0, 0)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Text = options.Name or "Chroma"
    WindowTitle.TextColor3 = GetColor("Text")
    WindowTitle.TextSize = 16
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.Font = Enum.Font.GothamSemibold
    WindowTitle.Parent = TopBarFrame

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 150, 1, 0)
    Subtitle.Position = UDim2.new(0, 120, 0, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = options.Subtitle or ""
    Subtitle.TextColor3 = GetColor("TextSecondary")
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = TopBarFrame

    CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = GetColor("TextSecondary")
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Parent = TopBarFrame

    CloseButton.MouseButton1Click:Connect(function()
        CreateTween(MainFrame, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -400, 0.5, -275)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    TopBarFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            DragStartPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(DragStartPos.X.Scale, DragStartPos.X.Offset + delta.X, DragStartPos.Y.Scale, DragStartPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    SidebarFrame = Instance.new("Frame")
    SidebarFrame.Size = UDim2.new(0, 200, 1, -40)
    SidebarFrame.Position = UDim2.new(0, 0, 0, 40)
    SidebarFrame.BackgroundColor3 = GetColor("Surface")
    SidebarFrame.BackgroundTransparency = 0.95
    SidebarFrame.BorderSizePixel = 0
    SidebarFrame.Parent = MainFrame

    ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -210, 1, -55)
    ContentFrame.Position = UDim2.new(0, 210, 0, 50)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = GetColor("Primary")
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.Parent = MainFrame

    TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 0)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Parent = SidebarFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Parent = TabsContainer

    MainFrame.BackgroundTransparency = 1
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -275)
    CreateTween(MainFrame, {BackgroundTransparency = 0.05}, 0.3)

    return {
        CreateTab = function(self, name)
            local Tab = {}

            local TabButton = Instance.new("TextButton")
            TabButton.Size = UDim2.new(0, 180, 0, 40)
            TabButton.Position = UDim2.new(0, 10, 0, 0)
            TabButton.BackgroundTransparency = 1
            TabButton.Text = name
            TabButton.TextColor3 = GetColor("TextSecondary")
            TabButton.TextSize = 14
            TabButton.Font = Enum.Font.Gotham
            TabButton.Parent = TabsContainer

            local TabFrame = Instance.new("Frame")
            TabFrame.Size = UDim2.new(1, 0, 0, 0)
            TabFrame.BackgroundTransparency = 1
            TabFrame.Visible = false
            TabFrame.Parent = ContentFrame

            local TabListLayout = Instance.new("UIListLayout")
            TabListLayout.Padding = UDim.new(0, 10)
            TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            TabListLayout.Parent = TabFrame

            local function SelectTab()
                if CurrentTab and CurrentTab.Button then
                    CreateTween(CurrentTab.Button, {TextColor3 = GetColor("TextSecondary")}, 0.2)
                    CurrentTab.Frame.Visible = false
                end
                CurrentTab = {Button = TabButton, Frame = TabFrame}
                CreateTween(TabButton, {TextColor3 = GetColor("Primary")}, 0.2)
                TabFrame.Visible = true
            end

            TabButton.MouseButton1Click:Connect(SelectTab)

            if not CurrentTab then SelectTab() end

            function Tab:CreateSection(name)
                local SectionFrame = Instance.new("Frame")
                SectionFrame.Size = UDim2.new(1, -20, 0, 40)
                SectionFrame.BackgroundTransparency = 1
                SectionFrame.Parent = TabFrame

                local SectionLabel = Instance.new("TextLabel")
                SectionLabel.Size = UDim2.new(1, 0, 1, 0)
                SectionLabel.BackgroundTransparency = 1
                SectionLabel.Text = name
                SectionLabel.TextColor3 = GetColor("Primary")
                SectionLabel.TextSize = 18
                SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
                SectionLabel.Font = Enum.Font.GothamSemibold
                SectionLabel.Parent = SectionFrame

                return SectionFrame
            end

            function Tab:CreateLabel(text)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, -20, 0, 30)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = TabFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = GetColor("TextSecondary")
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = LabelFrame

                return LabelFrame
            end

            function Tab:CreateButton(options)
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Size = UDim2.new(1, -20, 0, 40)
                ButtonFrame.BackgroundColor3 = GetColor("Surface")
                ButtonFrame.BackgroundTransparency = 0.95
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Parent = TabFrame

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = ButtonFrame

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundTransparency = 1
                Button.Text = options.Name or "Button"
                Button.TextColor3 = GetColor("Text")
                Button.TextSize = 14
                Button.Font = Enum.Font.Gotham
                Button.Parent = ButtonFrame

                if options.Info then
                    local Info = Instance.new("TextLabel")
                    Info.Size = UDim2.new(0, 150, 1, 0)
                    Info.Position = UDim2.new(1, -160, 0, 0)
                    Info.BackgroundTransparency = 1
                    Info.Text = options.Info
                    Info.TextColor3 = GetColor("TextSecondary")
                    Info.TextSize = 12
                    Info.TextXAlignment = Enum.TextXAlignment.Right
                    Info.Font = Enum.Font.Gotham
                    Info.Parent = ButtonFrame
                end

                Button.MouseButton1Click:Connect(function()
                    if options.Callback then
                        options.Callback()
                    end
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.8}, 0.1)
                    task.wait(0.1)
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.95}, 0.2)
                end)

                Button.MouseEnter:Connect(function()
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.85}, 0.2)
                end)

                Button.MouseLeave:Connect(function()
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.95}, 0.2)
                end)

                return ButtonFrame
            end

            function Tab:CreateToggle(options)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, -20, 0, 45)
                ToggleFrame.BackgroundColor3 = GetColor("Surface")
                ToggleFrame.BackgroundTransparency = 0.95
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Parent = TabFrame

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = ToggleFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -70, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Toggle"
                Label.TextColor3 = GetColor("Text")
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = ToggleFrame

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 50, 0, 30)
                ToggleButton.Position = UDim2.new(1, -65, 0, 7.5)
                ToggleButton.BackgroundColor3 = GetColor("Danger")
                ToggleButton.BackgroundTransparency = 0.3
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = "OFF"
                ToggleButton.TextColor3 = GetColor("Text")
                ToggleButton.TextSize = 12
                ToggleButton.Font = Enum.Font.Gotham
                ToggleButton.Parent = ToggleFrame

                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleButton

                local ToggleState = options.CurrentValue or false

                local function UpdateToggle()
                    if ToggleState then
                        CreateTween(ToggleButton, {BackgroundColor3 = GetColor("Success"), BackgroundTransparency = 0.3}, 0.2)
                        ToggleButton.Text = "ON"
                    else
                        CreateTween(ToggleButton, {BackgroundColor3 = GetColor("Danger"), BackgroundTransparency = 0.3}, 0.2)
                        ToggleButton.Text = "OFF"
                    end
                end

                UpdateToggle()

                ToggleButton.MouseButton1Click:Connect(function()
                    ToggleState = not ToggleState
                    UpdateToggle()
                    if options.Callback then
                        options.Callback(ToggleState)
                    end
                    CreateTween(ToggleButton, {BackgroundTransparency = 0.2}, 0.1)
                    task.wait(0.1)
                    CreateTween(ToggleButton, {BackgroundTransparency = 0.3}, 0.2)
                end)

                return ToggleFrame
            end

            function Tab:CreateSlider(options)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, -20, 0, 70)
                SliderFrame.BackgroundColor3 = GetColor("Surface")
                SliderFrame.BackgroundTransparency = 0.95
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = TabFrame

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = SliderFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -20, 0, 25)
                Label.Position = UDim2.new(0, 15, 0, 5)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Slider"
                Label.TextColor3 = GetColor("Text")
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = SliderFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 60, 0, 25)
                ValueLabel.Position = UDim2.new(1, -75, 0, 5)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(options.CurrentValue or options.Range[1])
                ValueLabel.TextColor3 = GetColor("Primary")
                ValueLabel.TextSize = 14
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -30, 0, 4)
                SliderBar.Position = UDim2.new(0, 15, 0, 45)
                SliderBar.BackgroundColor3 = GetColor("Border")
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame

                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(1, 0)
                SliderCorner.Parent = SliderBar

                local FillBar = Instance.new("Frame")
                FillBar.Size = UDim2.new(0, 0, 1, 0)
                FillBar.BackgroundColor3 = GetColor("Primary")
                FillBar.BorderSizePixel = 0
                FillBar.Parent = SliderBar

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = FillBar

                local SliderButton = Instance.new("TextButton")
                SliderButton.Size = UDim2.new(0, 16, 0, 16)
                SliderButton.Position = UDim2.new(0, 0, 0, -6)
                SliderButton.BackgroundColor3 = GetColor("Primary")
                SliderButton.BorderSizePixel = 0
                SliderButton.Text = ""
                SliderButton.AutoButtonColor = false
                SliderButton.Parent = FillBar

                local SliderButtonCorner = Instance.new("UICorner")
                SliderButtonCorner.CornerRadius = UDim.new(1, 0)
                SliderButtonCorner.Parent = SliderButton

                local Min = options.Range[1]
                local Max = options.Range[2]
                local Increment = options.Increment or 1
                local CurrentValue = options.CurrentValue or Min

                local function UpdateSlider(value)
                    value = math.clamp(value, Min, Max)
                    if Increment then
                        value = math.floor(value / Increment + 0.5) * Increment
                    end
                    CurrentValue = value
                    ValueLabel.Text = tostring(value) .. (options.Suffix or "")
                    local percent = (value - Min) / (Max - Min)
                    FillBar.Size = UDim2.new(percent, 0, 1, 0)
                    SliderButton.Position = UDim2.new(percent, -8, 0, -6)
                    if options.Callback then
                        options.Callback(value)
                    end
                end

                UpdateSlider(CurrentValue)

                local dragging = false
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local mousePos = UserInputService:GetMouseLocation()
                        local sliderPos = SliderBar.AbsolutePosition
                        local sliderSize = SliderBar.AbsoluteSize.X
                        local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize, 0, 1)
                        local value = Min + (Max - Min) * percent
                        UpdateSlider(value)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                return SliderFrame
            end

            function Tab:CreateDropdown(options)
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, -20, 0, 45)
                DropdownFrame.BackgroundColor3 = GetColor("Surface")
                DropdownFrame.BackgroundTransparency = 0.95
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.Parent = TabFrame

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = DropdownFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -120, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Dropdown"
                Label.TextColor3 = GetColor("Text")
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = DropdownFrame

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(0, 100, 0, 30)
                DropdownButton.Position = UDim2.new(1, -115, 0, 7.5)
                DropdownButton.BackgroundColor3 = GetColor("Background")
                DropdownButton.BackgroundTransparency = 0.5
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = options.CurrentOption or options.Options[1]
                DropdownButton.TextColor3 = GetColor("Text")
                DropdownButton.TextSize = 12
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Parent = DropdownFrame

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 6)
                DropCorner.Parent = DropdownButton

                local DropdownList = Instance.new("Frame")
                DropdownList.Size = UDim2.new(0, 100, 0, 0)
                DropdownList.Position = UDim2.new(1, -115, 0, 37.5)
                DropdownList.BackgroundColor3 = GetColor("Background")
                DropdownList.BackgroundTransparency = 0.95
                DropdownList.BorderSizePixel = 0
                DropdownList.ClipsDescendants = true
                DropdownList.Visible = false
                DropdownList.Parent = DropdownFrame

                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 6)
                ListCorner.Parent = DropdownList

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = DropdownList

                local DropdownOpen = false

                for _, option in ipairs(options.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 30)
                    OptionButton.BackgroundColor3 = GetColor("Surface")
                    OptionButton.BackgroundTransparency = 0.5
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = option
                    OptionButton.TextColor3 = GetColor("TextSecondary")
                    OptionButton.TextSize = 12
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Parent = DropdownList

                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionButton

                    OptionButton.MouseButton1Click:Connect(function()
                        DropdownButton.Text = option
                        DropdownList.Visible = false
                        DropdownOpen = false
                        DropdownList.Size = UDim2.new(0, 100, 0, 0)
                        if options.Callback then
                            options.Callback(option)
                        end
                    end)

                    OptionButton.MouseEnter:Connect(function()
                        CreateTween(OptionButton, {BackgroundTransparency = 0.3}, 0.1)
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        CreateTween(OptionButton, {BackgroundTransparency = 0.5}, 0.1)
                    end)
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    DropdownOpen = not DropdownOpen
                    if DropdownOpen then
                        DropdownList.Visible = true
                        local count = #options.Options
                        DropdownList.Size = UDim2.new(0, 100, 0, count * 32 + 5)
                        CreateTween(DropdownList, {BackgroundTransparency = 0.95}, 0.2)
                    else
                        CreateTween(DropdownList, {BackgroundTransparency = 1}, 0.2)
                        task.wait(0.2)
                        DropdownList.Visible = false
                        DropdownList.Size = UDim2.new(0, 100, 0, 0)
                    end
                end)

                return DropdownFrame
            end

            function Tab:CreateColorPicker(options)
                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, -20, 0, 45)
                ColorFrame.BackgroundColor3 = GetColor("Surface")
                ColorFrame.BackgroundTransparency = 0.95
                ColorFrame.BorderSizePixel = 0
                ColorFrame.Parent = TabFrame

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = ColorFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Color Picker"
                Label.TextColor3 = GetColor("Text")
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = ColorFrame

                local ColorButton = Instance.new("TextButton")
                ColorButton.Size = UDim2.new(0, 60, 0, 30)
                ColorButton.Position = UDim2.new(1, -75, 0, 7.5)
                ColorButton.BackgroundColor3 = options.Color or Color3.fromRGB(255, 255, 255)
                ColorButton.BorderSizePixel = 0
                ColorButton.Text = ""
                ColorButton.Parent = ColorFrame

                local ColorCorner = Instance.new("UICorner")
                ColorCorner.CornerRadius = UDim.new(0, 6)
                ColorCorner.Parent = ColorButton

                local function CreateColorPickerPopup()
                    local Popup = Instance.new("Frame")
                    Popup.Size = UDim2.new(0, 200, 0, 150)
                    Popup.Position = UDim2.new(0.5, -100, 0.5, -75)
                    Popup.BackgroundColor3 = GetColor("Background")
                    Popup.BackgroundTransparency = 0.1
                    Popup.BorderSizePixel = 0
                    Popup.Visible = false
                    Popup.Parent = MainFrame

                    local PopupCorner = Instance.new("UICorner")
                    PopupCorner.CornerRadius = UDim.new(0, 12)
                    PopupCorner.Parent = Popup

                    local Colors = {
                        Color3.fromRGB(255, 0, 0),
                        Color3.fromRGB(0, 255, 0),
                        Color3.fromRGB(0, 0, 255),
                        Color3.fromRGB(255, 255, 0),
                        Color3.fromRGB(255, 0, 255),
                        Color3.fromRGB(0, 255, 255),
                        Color3.fromRGB(255, 255, 255),
                        Color3.fromRGB(0, 0, 0)
                    }

                    local Grid = Instance.new("Frame")
                    Grid.Size = UDim2.new(1, -20, 1, -50)
                    Grid.Position = UDim2.new(0, 10, 0, 10)
                    Grid.BackgroundTransparency = 1
                    Grid.Parent = Popup

                    local UIGrid = Instance.new("UIGridLayout")
                    UIGrid.CellSize = UDim2.new(0, 40, 0, 40)
                    UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)
                    UIGrid.Parent = Grid

                    for _, color in ipairs(Colors) do
                        local ColorOption = Instance.new("TextButton")
                        ColorOption.Size = UDim2.new(0, 40, 0, 40)
                        ColorOption.BackgroundColor3 = color
                        ColorOption.BorderSizePixel = 0
                        ColorOption.Text = ""
                        ColorOption.Parent = Grid

                        local ColorCorner = Instance.new("UICorner")
                        ColorCorner.CornerRadius = UDim.new(0, 6)
                        ColorCorner.Parent = ColorOption

                        ColorOption.MouseButton1Click:Connect(function()
                            ColorButton.BackgroundColor3 = color
                            Popup.Visible = false
                            if options.Callback then
                                options.Callback(color)
                            end
                        end)
                    end

                    local CloseBtn = Instance.new("TextButton")
                    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
                    CloseBtn.Position = UDim2.new(1, -40, 0, 5)
                    CloseBtn.BackgroundTransparency = 1
                    CloseBtn.Text = "✕"
                    CloseBtn.TextColor3 = GetColor("Text")
                    CloseBtn.TextSize = 14
                    CloseBtn.Font = Enum.Font.Gotham
                    CloseBtn.Parent = Popup

                    CloseBtn.MouseButton1Click:Connect(function()
                        Popup.Visible = false
                    end)

                    return Popup
                end

                local ColorPopup = CreateColorPickerPopup()

                ColorButton.MouseButton1Click:Connect(function()
                    ColorPopup.Visible = true
                    CreateTween(ColorPopup, {BackgroundTransparency = 0.1}, 0.2)
                end)

                return {CurrentValue = ColorButton.BackgroundColor3}
            end

            return Tab
        end
    }
end

return Library
