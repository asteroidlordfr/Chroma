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
local CoreGui = game:GetService("CoreGui")

local Library = {Flags = {}}

function Library:Notify(data)
    local gui = Instance.new("ScreenGui", CoreGui)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,300,0,80)
    frame.Position = UDim2.new(1,-320,1,-100)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,-20,0,25)
    title.Position = UDim2.new(0,10,0,5)
    title.BackgroundTransparency = 1
    title.Text = data.Title or ""
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local content = Instance.new("TextLabel", frame)
    content.Size = UDim2.new(1,-20,1,-30)
    content.Position = UDim2.new(0,10,0,30)
    content.BackgroundTransparency = 1
    content.Text = data.Content or ""
    content.TextColor3 = Color3.fromRGB(200,200,200)
    content.Font = Enum.Font.Gotham
    content.TextSize = 13
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

    task.delay(data.Duration or 5, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        gui:Destroy()
    end)
end

function Library:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0,650,0,420)
    Main.Position = UDim2.new(0.5,-325,0.5,-210)
    Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Main.BackgroundTransparency = 1
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1,0,0,40)
    Top.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Top.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Top)
    Title.Size = UDim2.new(1,0,1,0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "Window"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16

    local Close = Instance.new("TextButton", Top)
    Close.Size = UDim2.new(0,30,1,0)
    Close.Position = UDim2.new(1,-30,0,0)
    Close.Text = "X"
    Close.Font = Enum.Font.GothamBold
    Close.TextColor3 = Color3.new(1,1,1)
    Close.BackgroundTransparency = 1

    local Min = Instance.new("TextButton", Top)
    Min.Size = UDim2.new(0,30,1,0)
    Min.Position = UDim2.new(1,-60,0,0)
    Min.Text = "-"
    Min.Font = Enum.Font.GothamBold
    Min.TextColor3 = Color3.new(1,1,1)
    Min.BackgroundTransparency = 1

    local Drop = Instance.new("TextButton", Top)
    Drop.Size = UDim2.new(0,30,1,0)
    Drop.Position = UDim2.new(1,-90,0,0)
    Drop.Text = "□"
    Drop.Font = Enum.Font.GothamBold
    Drop.TextColor3 = Color3.new(1,1,1)
    Drop.BackgroundTransparency = 1

    local TabsHolder = Instance.new("Frame", Main)
    TabsHolder.Size = UDim2.new(0,160,1,-40)
    TabsHolder.Position = UDim2.new(0,0,0,40)
    TabsHolder.BackgroundColor3 = Color3.fromRGB(18,18,18)
    TabsHolder.BorderSizePixel = 0

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1,-160,1,-40)
    Content.Position = UDim2.new(0,160,0,40)
    Content.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", TabsHolder)
    Layout.Padding = UDim.new(0,6)

    local dragging, dragStart, startPos

    Top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)

    Top.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            TweenService:Create(Main, TweenInfo.new(0.1), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    TweenService:Create(Main, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()

    local hidden = false

    Close.MouseButton1Click:Connect(function()
        hidden = not hidden
        Main.Visible = not hidden
    end)

    UserInputService.InputBegan:Connect(function(i,g)
        if not g and i.KeyCode == Enum.KeyCode.K then
            hidden = not hidden
            Main.Visible = not hidden
        end
    end)

    local minimized = false
    local bubble

    Min.MouseButton1Click:Connect(function()
        minimized = true
        Main.Visible = false

        bubble = Instance.new("TextButton", ScreenGui)
        bubble.Size = UDim2.new(0,40,0,40)
        bubble.Position = UDim2.new(0,20,0.5,-20)
        bubble.Text = config.Name or "UI"
        bubble.TextScaled = true
        bubble.BackgroundColor3 = Color3.fromRGB(20,20,20)
        Instance.new("UICorner", bubble).CornerRadius = UDim.new(1,0)

        bubble.MouseButton1Click:Connect(function()
            Main.Visible = true
            bubble:Destroy()
        end)
    end)

    local dropped = false
    Drop.MouseButton1Click:Connect(function()
        dropped = not dropped
        TweenService:Create(Main, TweenInfo.new(0.3), {
            Size = dropped and UDim2.new(0,650,0,40) or UDim2.new(0,650,0,420)
        }):Play()
    end)

    local Window = {}

    function Window:CreateTab(name)
        local Button = Instance.new("TextButton", TabsHolder)
        Button.Size = UDim2.new(1,-10,0,35)
        Button.Text = name
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 14
        Button.TextColor3 = Color3.new(1,1,1)
        Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0,6)

        local Frame = Instance.new("Frame", Content)
        Frame.Size = UDim2.new(1,0,1,0)
        Frame.Visible = false
        Frame.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", Frame)
        Layout.Padding = UDim.new(0,8)

        Button.MouseButton1Click:Connect(function()
            for _,v in pairs(Content:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            Frame.Visible = true
        end)

        local Tab = {}

        function Tab:CreateSection(text)
            local label = Instance.new("TextLabel", Frame)
            label.Size = UDim2.new(1,-10,0,25)
            label.Text = text
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(180,180,180)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Tab:CreateButton(data)
            local b = Instance.new("TextButton", Frame)
            b.Size = UDim2.new(1,-10,0,35)
            b.Text = data.Name
            b.Font = Enum.Font.GothamBold
            b.TextSize = 14
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(30,30,30)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

            b.MouseButton1Click:Connect(function()
                if data.Callback then data.Callback() end
            end)

            return {
                Set = function(_,txt) b.Text = txt end
            }
        end

        function Tab:CreateToggle(data)
            local t = Instance.new("TextButton", Frame)
            t.Size = UDim2.new(1,-10,0,35)
            t.Text = data.Name
            t.Font = Enum.Font.GothamBold
            t.TextSize = 14
            t.TextColor3 = Color3.new(1,1,1)
            t.BackgroundColor3 = Color3.fromRGB(30,30,30)
            Instance.new("UICorner", t).CornerRadius = UDim.new(0,6)

            local state = data.CurrentValue or false

            local function set(v)
                state = v
                Library.Flags[data.Flag or data.Name] = state
                TweenService:Create(t, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Color3.fromRGB(0,170,127) or Color3.fromRGB(30,30,30)
                }):Play()
                if data.Callback then data.Callback(state) end
            end

            t.MouseButton1Click:Connect(function() set(not state) end)
            set(state)

            return {Set = function(_,v) set(v) end, CurrentValue = state}
        end

        function Tab:CreateInput(data)
            local box = Instance.new("TextBox", Frame)
            box.Size = UDim2.new(1,-10,0,35)
            box.Text = data.CurrentValue or ""
            box.PlaceholderText = data.PlaceholderText or ""
            box.Font = Enum.Font.Gotham
            box.TextSize = 14
            box.TextColor3 = Color3.new(1,1,1)
            box.BackgroundColor3 = Color3.fromRGB(30,30,30)
            Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

            box.FocusLost:Connect(function()
                if data.Callback then data.Callback(box.Text) end
                if data.RemoveTextAfterFocusLost then box.Text = "" end
            end)

            return {Set = function(_,v) box.Text = v end}
        end

        function Tab:CreateSlider(data)
            local frame = Instance.new("Frame", Frame)
            frame.Size = UDim2.new(1,-10,0,40)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)

            local value = data.CurrentValue or data.Range[1]

            frame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local move, up
                    move = UserInputService.InputChanged:Connect(function(m)
                        if m.UserInputType == Enum.UserInputType.MouseMovement then
                            local percent = math.clamp((m.Position.X - frame.AbsolutePosition.X)/frame.AbsoluteSize.X,0,1)
                            value = math.floor((data.Range[1] + (data.Range[2]-data.Range[1])*percent)/data.Increment)*data.Increment
                            if data.Callback then data.Callback(value) end
                        end
                    end)
                    up = UserInputService.InputEnded:Connect(function(e)
                        if e.UserInputType == Enum.UserInputType.MouseButton1 then
                            move:Disconnect()
                            up:Disconnect()
                        end
                    end)
                end
            end)

            return {Set = function(_,v) value = v end}
        end

        function Tab:CreateDropdown(data)
            local d = Instance.new("TextButton", Frame)
            d.Size = UDim2.new(1,-10,0,35)
            d.Text = data.Name
            d.Font = Enum.Font.GothamBold
            d.TextSize = 14
            d.TextColor3 = Color3.new(1,1,1)
            d.BackgroundColor3 = Color3.fromRGB(30,30,30)
            Instance.new("UICorner", d).CornerRadius = UDim.new(0,6)

            local current = data.CurrentOption or {}

            d.MouseButton1Click:Connect(function()
                current = {data.Options[1]}
                if data.Callback then data.Callback(current) end
            end)

            return {
                Set = function(_,v) current = v if data.Callback then data.Callback(v) end end,
                Refresh = function(_,opts) data.Options = opts end,
                CurrentOption = current
            }
        end

        return Tab
    end

    return Window
end

return Library
