--[[

© Chroma, 2026
Yet another Universal script for Roblox.

Fully open-sourced, and free forever.
I don't really know if I plan on long term support for this project, but I review pull requests and would be glad to add some.

Enjoying the script? Star us on GitHub: github.com/asteroidlordfr/Chroma
                                        ^^ you can also read our source code, open pull requests, and issues.
Comments are placed as **DEV COMMENTS**, it is meant to explain parts of the code, credit contributors and other purposes.

--]]

return {
    Initialize = function(Core, Window)
        local MovementTab = Window:CreateTab("🎮 Movement")
        local state = {
            flying = false,
            swimming = false,
            vflyEnabled = false,
            noclip = nil,
            bhop = false,
            infJumpConn = nil,
            defaultWalkSpeed = 16,
            defaultJumpPower = 50,
            defaultGravity = Core.RunService.Gravity or 196.2,
            flySpeed = 50,
        }
        
        MovementTab:CreateSection("Sliders")
        
        MovementTab:CreateSlider({
            Name = "Walkspeed", Range = {0,500}, Increment = 5,
            CurrentValue = Core.Humanoid.WalkSpeed,
            Callback = function(v) Core.Humanoid.WalkSpeed = v end
        })
        
        MovementTab:CreateSlider({
            Name = "Jump Power", Range = {0,500}, Increment = 5,
            CurrentValue = Core.Humanoid.JumpPower,
            Callback = function(v) Core.Humanoid.JumpPower = v end
        })
        
        MovementTab:CreateSlider({
            Name = "Gravity", Range = {0,500}, Increment = 1,
            CurrentValue = state.defaultGravity,
            Callback = function(v) Core.RunService.Gravity = v end
        })
        
        MovementTab:CreateButton({
            Name = "Reset Walkspeed",
            Callback = function() Core.Humanoid.WalkSpeed = state.defaultWalkSpeed end
        })
        
        MovementTab:CreateButton({
            Name = "Reset Jump Power",
            Callback = function() Core.Humanoid.JumpPower = state.defaultJumpPower end
        })
        
        MovementTab:CreateButton({
            Name = "Reset Gravity",
            Callback = function() Core.RunService.Gravity = state.defaultGravity end
        })
        
        MovementTab:CreateSection("Player")
        
        MovementTab:CreateToggle({
            Name = "Platforms (F)",
            CurrentValue = false,
            Callback = function(enabled)
                local connection
                if enabled then
                    connection = Core.UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe or input.KeyCode ~= Enum.KeyCode.F then return end
                        local char = Core.Utils.getCharacter()
                        local root = Core.Utils.getRootPart(char)
                        if root then
                            local part = Instance.new("Part")
                            part.Anchored = true
                            part.Size = Vector3.new(6, 1, 6)
                            part.Position = root.Position - Vector3.new(0, 3, 0)
                            part.Color = Color3.new(0, 0, 0)
                            part.Material = Enum.Material.SmoothPlastic
                            part.Parent = workspace
                            task.delay(3, function() part:Destroy() end)
                        end
                    end)
                elseif connection then
                    connection:Disconnect()
                end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Noclip",
            CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.noclip = Core.RunService.Stepped:Connect(function()
                        local char = Core.Utils.getCharacter()
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                elseif state.noclip then
                    state.noclip:Disconnect()
                    state.noclip = nil
                end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Bunny Hop",
            CurrentValue = false,
            Callback = function(enabled)
                state.bhop = enabled
                if enabled then
                    task.spawn(function()
                        while state.bhop do
                            local char = Core.Utils.getCharacter()
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                            task.wait(0.1)
                        end
                    end)
                end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Infinite Jump",
            CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.infJumpConn = Core.UserInputService.JumpRequest:Connect(function()
                        local char = Core.Utils.getCharacter()
                        local root = Core.Utils.getRootPart(char)
                        if root then
                            root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
                        end
                    end)
                elseif state.infJumpConn then
                    state.infJumpConn:Disconnect()
                    state.infJumpConn = nil
                end
            end
        })
        
        MovementTab:CreateSection("Fly")
        
        MovementTab:CreateSlider({
            Name = "Fly Speed", Range = {10,300}, Increment = 1,
            CurrentValue = state.flySpeed,
            Callback = function(v) state.flySpeed = v end
        })
        
        MovementTab:CreateToggle({
            Name = "Fly",
            CurrentValue = false,
            Callback = function(enabled)
                local char = Core.Utils.getCharacter()
                local root = Core.Utils.getRootPart(char)
                local hum = char:FindFirstChildOfClass("Humanoid")
                local flyConn
                
                if enabled then
                    state.flying = true
                    hum.PlatformStand = true
                    flyConn = Core.RunService.RenderStepped:Connect(function()
                        local moveDir = Vector3.zero
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            moveDir = moveDir + Core.Camera.CFrame.LookVector
                        end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            moveDir = moveDir - Core.Camera.CFrame.LookVector
                        end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            moveDir = moveDir - Core.Camera.CFrame.RightVector
                        end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            moveDir = moveDir + Core.Camera.CFrame.RightVector
                        end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveDir = moveDir + Vector3.new(0,1,0)
                        end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            moveDir = moveDir - Vector3.new(0,1,0)
                        end
                        if moveDir.Magnitude > 0 then
                            root.Velocity = moveDir.Unit * state.flySpeed
                        else
                            root.Velocity = Vector3.zero
                        end
                    end)
                else
                    state.flying = false
                    if flyConn then flyConn:Disconnect() end
                    hum.PlatformStand = false
                    if root then root.Velocity = Vector3.zero end
                end
            end
        })
    end
}
