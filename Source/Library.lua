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
local CloseButton
local MinimizeButton

local CurrentTab = nil
local Tabs = {}
local Theme = {
    Sidebar = Color3.fromRGB(30, 30, 35),
    Content = Color3.fromRGB(40, 40, 45),
    TopBar = Color3.fromRGB(35, 35, 40),
    Primary = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    Border = Color3.fromRGB(50, 50, 55),
    Hover = Color3.fromRGB(50, 50, 55),
    Success = Color3.fromRGB(76, 175, 80),
    Danger = Color3.fromRGB(244, 67, 54)
}

local Dragging = false
local DragStart = nil
local DragStartPos = nil
local Visible = true

local function CreateTween(obj, props, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

function Library:CreateWindow(options)
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ChromaUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.Content
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.Parent = MainFrame
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 12)
    ShadowCorner.Parent = Shadow
    
    TopBarFrame = Instance.new("Frame")
    TopBarFrame.Size = UDim2.new(1, 0, 0, 40)
    TopBarFrame.Position = UDim2.new(0, 0, 0, 0)
    TopBarFrame.BackgroundColor3 = Theme.TopBar
    TopBarFrame.BorderSizePixel = 0
    TopBarFrame.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBarFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 150, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = options.Name or "Chroma"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamSemibold
    Title.Parent = TopBarFrame
    
    MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
    MinimizeButton.Position = UDim2.new(1, -65, 0, 0)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = "—"
    MinimizeButton.TextColor3 = Theme.TextSecondary
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Parent = TopBarFrame
    
    CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Theme.TextSecondary
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Parent = TopBarFrame
    
    local Minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            CreateTween(MainFrame, {Size = UDim2.new(0, 700, 0, 40), Position = UDim2.new(0.5, -350, 0.5, -20)}, 0.3)
            SidebarFrame.Visible = false
            ContentFrame.Visible = false
        else
            CreateTween(MainFrame, {Size = UDim2.new(0, 700, 0, 500), Position = UDim2.new(0.5, -350, 0.5, -250)}, 0.3)
            task.wait(0.3)
            SidebarFrame.Visible = true
            ContentFrame.Visible = true
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        CreateTween(MainFrame, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -350, 0.5, -250)}, 0.2)
        task.wait(0.2)
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
    SidebarFrame.Size = UDim2.new(0, 180, 1, -40)
    SidebarFrame.Position = UDim2.new(0, 0, 0, 40)
    SidebarFrame.BackgroundColor3 = Theme.Sidebar
    SidebarFrame.BorderSizePixel = 0
    SidebarFrame.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = SidebarFrame
    
    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Thickness = 0
    SidebarStroke.Parent = SidebarFrame
    
    ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -190, 1, -55)
    ContentFrame.Position = UDim2.new(0, 190, 0, 50)
    ContentFrame.BackgroundColor3 = Theme.Content
    ContentFrame.BackgroundTransparency = 0
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Theme.Primary
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 12)
    ContentCorner.Parent = ContentFrame
    
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 0)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Parent = SidebarFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Parent = TabsContainer
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.K then
            Visible = not Visible
            if Visible then
                MainFrame.Visible = true
                CreateTween(MainFrame, {BackgroundTransparency = 0}, 0.2)
            else
                CreateTween(MainFrame, {BackgroundTransparency = 1}, 0.2)
                task.wait(0.2)
                MainFrame.Visible = false
            end
        end
    end)
    
    MainFrame.Visible = true
    
    return {
        CreateTab = function(self, name)
            local TabButton = Instance.new("TextButton")
            TabButton.Size = UDim2.new(0, 160, 0, 40)
            TabButton.Position = UDim2.new(0, 10, 0, 0)
            TabButton.BackgroundTransparency = 1
            TabButton.Text = name
            TabButton.TextColor3 = Theme.TextSecondary
            TabButton.TextSize = 14
            TabButton.Font = Enum.Font.GothamSemibold
            TabButton.Parent = TabsContainer
            
            local TabFrame = Instance.new("Frame")
            TabFrame.Size = UDim2.new(1, -20, 0, 0)
            TabFrame.Position = UDim2.new(0, 10, 0, 0)
            TabFrame.BackgroundTransparency = 1
            TabFrame.Visible = false
            TabFrame.Parent = ContentFrame
            
            local TabContentLayout = Instance.new("UIListLayout")
            TabContentLayout.Padding = UDim.new(0, 12)
            TabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            TabContentLayout.Parent = TabFrame
            
            local function SelectTab()
                if CurrentTab then
                    CreateTween(CurrentTab.Button, {TextColor3 = Theme.TextSecondary}, 0.2)
                    CurrentTab.Frame.Visible = false
                end
                CurrentTab = {Button = TabButton, Frame = TabFrame}
                CreateTween(TabButton, {TextColor3 = Theme.Primary}, 0.2)
                TabFrame.Visible = true
            end
            
            TabButton.MouseButton1Click:Connect(SelectTab)
            
            if not CurrentTab then SelectTab() end
            
            function TabFrame:CreateSection(text)
                local Section = Instance.new("Frame")
                Section.Size = UDim2.new(1, -20, 0, 40)
                Section.BackgroundTransparency = 1
                Section.Parent = TabFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.Primary
                Label.TextSize = 18
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.GothamSemibold
                Label.Parent = Section
                
                return Section
            end
            
            function TabFrame:CreateLabel(text)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, -20, 0, 30)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = TabFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.TextSecondary
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = LabelFrame
                
                return LabelFrame
            end
            
            function TabFrame:CreateButton(options)
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Size = UDim2.new(1, -20, 0, 45)
                ButtonFrame.BackgroundColor3 = Theme.Sidebar
                ButtonFrame.BackgroundTransparency = 0.5
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Parent = TabFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = ButtonFrame
                
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundTransparency = 1
                Button.Text = options.Name or "Button"
                Button.TextColor3 = Theme.Text
                Button.TextSize = 14
                Button.Font = Enum.Font.Gotham
                Button.Parent = ButtonFrame
                
                if options.Info then
                    local Info = Instance.new("TextLabel")
                    Info.Size = UDim2.new(0, 150, 1, 0)
                    Info.Position = UDim2.new(1, -160, 0, 0)
                    Info.BackgroundTransparency = 1
                    Info.Text = options.Info
                    Info.TextColor3 = Theme.TextSecondary
                    Info.TextSize = 12
                    Info.TextXAlignment = Enum.TextXAlignment.Right
                    Info.Font = Enum.Font.Gotham
                    Info.Parent = ButtonFrame
                end
                
                Button.MouseButton1Click:Connect(function()
                    if options.Callback then options.Callback() end
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.7}, 0.1)
                    task.wait(0.1)
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.5}, 0.2)
                end)
                
                Button.MouseEnter:Connect(function()
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.3}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    CreateTween(ButtonFrame, {BackgroundTransparency = 0.5}, 0.2)
                end)
                
                return ButtonFrame
            end
            
            function TabFrame:CreateToggle(options)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
                ToggleFrame.BackgroundColor3 = Theme.Sidebar
                ToggleFrame.BackgroundTransparency = 0.5
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Parent = TabFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = ToggleFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Toggle"
                Label.TextColor3 = Theme.Text
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 55, 0, 30)
                ToggleButton.Position = UDim2.new(1, -70, 0, 10)
                ToggleButton.BackgroundColor3 = Theme.Danger
                ToggleButton.BackgroundTransparency = 0.3
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = "OFF"
                ToggleButton.TextColor3 = Theme.Text
                ToggleButton.TextSize = 12
                ToggleButton.Font = Enum.Font.Gotham
                ToggleButton.Parent = ToggleFrame
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleButton
                
                local State = options.CurrentValue or false
                
                local function UpdateToggle()
                    if State then
                        CreateTween(ToggleButton, {BackgroundColor3 = Theme.Success, BackgroundTransparency = 0.3}, 0.2)
                        ToggleButton.Text = "ON"
                    else
                        CreateTween(ToggleButton, {BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0.3}, 0.2)
                        ToggleButton.Text = "OFF"
                    end
                end
                
                UpdateToggle()
                
                ToggleButton.MouseButton1Click:Connect(function()
                    State = not State
                    UpdateToggle()
                    if options.Callback then options.Callback(State) end
                end)
                
                return ToggleFrame
            end
            
            function TabFrame:CreateSlider(options)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, -20, 0, 80)
                SliderFrame.BackgroundColor3 = Theme.Sidebar
                SliderFrame.BackgroundTransparency = 0.5
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = TabFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = SliderFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -20, 0, 25)
                Label.Position = UDim2.new(0, 15, 0, 8)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Slider"
                Label.TextColor3 = Theme.Text
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = SliderFrame
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 80, 0, 25)
                ValueLabel.Position = UDim2.new(1, -95, 0, 8)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(options.CurrentValue or options.Range[1])
                ValueLabel.TextColor3 = Theme.Primary
                ValueLabel.TextSize = 14
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.Parent = SliderFrame
                
                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, -30, 0, 4)
                SliderBar.Position = UDim2.new(0, 15, 0, 48)
                SliderBar.BackgroundColor3 = Theme.Border
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(1, 0)
                SliderCorner.Parent = SliderBar
                
                local FillBar = Instance.new("Frame")
                FillBar.Size = UDim2.new(0, 0, 1, 0)
                FillBar.BackgroundColor3 = Theme.Primary
                FillBar.BorderSizePixel = 0
                FillBar.Parent = SliderBar
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = FillBar
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Size = UDim2.new(0, 16, 0, 16)
                SliderButton.Position = UDim2.new(0, 0, 0, -6)
                SliderButton.BackgroundColor3 = Theme.Primary
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
            
            function TabFrame:CreateDropdown(options)
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, -20, 0, 50)
                DropdownFrame.BackgroundColor3 = Theme.Sidebar
                DropdownFrame.BackgroundTransparency = 0.5
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.Parent = TabFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = DropdownFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -130, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Dropdown"
                Label.TextColor3 = Theme.Text
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(0, 110, 0, 32)
                DropdownButton.Position = UDim2.new(1, -125, 0, 9)
                DropdownButton.BackgroundColor3 = Theme.Content
                DropdownButton.BackgroundTransparency = 0.3
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = options.CurrentOption or options.Options[1]
                DropdownButton.TextColor3 = Theme.Text
                DropdownButton.TextSize = 12
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Parent = DropdownFrame
                
                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 6)
                DropCorner.Parent = DropdownButton
                
                local DropdownList = Instance.new("Frame")
                DropdownList.Size = UDim2.new(0, 110, 0, 0)
                DropdownList.Position = UDim2.new(1, -125, 0, 41)
                DropdownList.BackgroundColor3 = Theme.Content
                DropdownList.BackgroundTransparency = 0.1
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
                
                local Open = false
                
                for _, option in ipairs(options.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 32)
                    OptionButton.BackgroundColor3 = Theme.Sidebar
                    OptionButton.BackgroundTransparency = 0.3
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = option
                    OptionButton.TextColor3 = Theme.TextSecondary
                    OptionButton.TextSize = 12
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Parent = DropdownList
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionButton
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        DropdownButton.Text = option
                        DropdownList.Visible = false
                        Open = false
                        DropdownList.Size = UDim2.new(0, 110, 0, 0)
                        if options.Callback then
                            options.Callback(option)
                        end
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        CreateTween(OptionButton, {BackgroundTransparency = 0.1}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        CreateTween(OptionButton, {BackgroundTransparency = 0.3}, 0.1)
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Open = not Open
                    if Open then
                        DropdownList.Visible = true
                        local count = #options.Options
                        DropdownList.Size = UDim2.new(0, 110, 0, count * 34 + 5)
                        CreateTween(DropdownList, {BackgroundTransparency = 0.1}, 0.2)
                    else
                        CreateTween(DropdownList, {BackgroundTransparency = 0.5}, 0.2)
                        task.wait(0.2)
                        DropdownList.Visible = false
                        DropdownList.Size = UDim2.new(0, 110, 0, 0)
                    end
                end)
                
                return DropdownFrame
            end
            
            function TabFrame:CreateColorPicker(options)
                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, -20, 0, 50)
                ColorFrame.BackgroundColor3 = Theme.Sidebar
                ColorFrame.BackgroundTransparency = 0.5
                ColorFrame.BorderSizePixel = 0
                ColorFrame.Parent = TabFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = ColorFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -90, 1, 0)
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = options.Name or "Color Picker"
                Label.TextColor3 = Theme.Text
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.Gotham
                Label.Parent = ColorFrame
                
                local ColorButton = Instance.new("TextButton")
                ColorButton.Size = UDim2.new(0, 70, 0, 32)
                ColorButton.Position = UDim2.new(1, -85, 0, 9)
                ColorButton.BackgroundColor3 = options.Color or Color3.fromRGB(255, 255, 255)
                ColorButton.BorderSizePixel = 0
                ColorButton.Text = ""
                ColorButton.Parent = ColorFrame
                
                local ColorCorner = Instance.new("UICorner")
                ColorCorner.CornerRadius = UDim.new(0, 6)
                ColorCorner.Parent = ColorButton
                
                local Popup = Instance.new("Frame")
                Popup.Size = UDim2.new(0, 220, 0, 160)
                Popup.Position = UDim2.new(0.5, -110, 0.5, -80)
                Popup.BackgroundColor3 = Theme.Content
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
                    Color3.fromRGB(100, 100, 100)
                }
                
                local Grid = Instance.new("Frame")
                Grid.Size = UDim2.new(1, -20, 1, -50)
                Grid.Position = UDim2.new(0, 10, 0, 10)
                Grid.BackgroundTransparency = 1
                Grid.Parent = Popup
                
                local GridLayout = Instance.new("UIGridLayout")
                GridLayout.CellSize = UDim2.new(0, 45, 0, 45)
                GridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
                GridLayout.Parent = Grid
                
                for _, color in ipairs(Colors) do
                    local ColorOption = Instance.new("TextButton")
                    ColorOption.Size = UDim2.new(0, 45, 0, 45)
                    ColorOption.BackgroundColor3 = color
                    ColorOption.BorderSizePixel = 0
                    ColorOption.Text = ""
                    ColorOption.Parent = Grid
                    
                    local ColorOptionCorner = Instance.new("UICorner")
                    ColorOptionCorner.CornerRadius = UDim.new(0, 6)
                    ColorOptionCorner.Parent = ColorOption
                    
                    ColorOption.MouseButton1Click:Connect(function()
                        ColorButton.BackgroundColor3 = color
                        Popup.Visible = false
                        if options.Callback then
                            options.Callback(color)
                        end
                    end)
                end
                
                local ClosePopup = Instance.new("TextButton")
                ClosePopup.Size = UDim2.new(0, 25, 0, 25)
                ClosePopup.Position = UDim2.new(1, -35, 0, 5)
                ClosePopup.BackgroundTransparency = 1
                ClosePopup.Text = "✕"
                ClosePopup.TextColor3 = Theme.Text
                ClosePopup.TextSize = 14
                ClosePopup.Font = Enum.Font.Gotham
                ClosePopup.Parent = Popup
                
                ClosePopup.MouseButton1Click:Connect(function()
                    Popup.Visible = false
                end)
                
                ColorButton.MouseButton1Click:Connect(function()
                    Popup.Visible = true
                    CreateTween(Popup, {BackgroundTransparency = 0.1}, 0.2)
                end)
                
                return {CurrentValue = ColorButton.BackgroundColor3}
            end
            
            return TabFrame
        end
    }
end

return Library
