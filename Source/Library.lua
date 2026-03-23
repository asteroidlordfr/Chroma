--[[

© Chroma, 2026
Yet another Universal script for Roblox.

Fully open-sourced, and free forever.
I don't really know if I plan on long term support for this project, but I review pull requests and would be glad to add some.

Enjoying the script? Star us on GitHub: github.com/asteroidlordfr/Chroma
                                        ^^ you can also read our source code, open pull requests, and issues.
Comments are placed as **DEV COMMENTS**, it is meant to explain parts of the code, credit contributors and other purposes.

--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

function Library:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0,10)

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1,0,0,40)
    Top.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Top.BorderSizePixel = 0
    Top.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,1,0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "Window"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Top

    local TabsHolder = Instance.new("Frame")
    TabsHolder.Size = UDim2.new(0,150,1,-40)
    TabsHolder.Position = UDim2.new(0,0,0,40)
    TabsHolder.BackgroundColor3 = Color3.fromRGB(18,18,18)
    TabsHolder.BorderSizePixel = 0
    TabsHolder.Parent = Main

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,-150,1,-40)
    Content.Position = UDim2.new(0,150,0,40)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local UIListLayout = Instance.new("UIListLayout", TabsHolder)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0,5)

    local dragging = false
    local dragInput, dragStart, startPos

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Top.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Window = {}

    function Window:CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1,-10,0,35)
        TabButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.new(1,1,1)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.Parent = TabsHolder

        local UICorner = Instance.new("UICorner", TabButton)
        UICorner.CornerRadius = UDim.new(0,6)

        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1,0,1,0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = Content

        local Layout = Instance.new("UIListLayout", TabFrame)
        Layout.Padding = UDim.new(0,8)

        TabButton.MouseButton1Click:Connect(function()
            for _,v in pairs(Content:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            TabFrame.Visible = true
        end)

        local Tab = {}

        function Tab:CreateButton(data)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1,-10,0,35)
            Button.BackgroundColor3 = Color3.fromRGB(30,30,30)
            Button.Text = data.Name or "Button"
            Button.TextColor3 = Color3.new(1,1,1)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.Parent = TabFrame

            local UICorner = Instance.new("UICorner", Button)
            UICorner.CornerRadius = UDim.new(0,6)

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                if data.Callback then
                    data.Callback()
                end
            end)
        end

        function Tab:CreateToggle(data)
            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(1,-10,0,35)
            Toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
            Toggle.Text = data.Name or "Toggle"
            Toggle.TextColor3 = Color3.new(1,1,1)
            Toggle.Font = Enum.Font.Gotham
            Toggle.TextSize = 14
            Toggle.Parent = TabFrame

            local state = false

            local UICorner = Instance.new("UICorner", Toggle)
            UICorner.CornerRadius = UDim.new(0,6)

            Toggle.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Toggle, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Color3.fromRGB(0,170,127) or Color3.fromRGB(30,30,30)
                }):Play()
                if data.Callback then
                    data.Callback(state)
                end
            end)
        end

        return Tab
    end

    return Window
end

return Library
