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
        local function getChar()
            if not Core then return nil end
            local char = Core.LocalPlayer.Character
            if char then return char end
            local ok, result = pcall(function()
                return Core.LocalPlayer.CharacterAdded:Wait()
            end)
            if ok then return result end
            return nil
        end
    
        local function getHum(char)
            if not char then return nil end
            return char:FindFirstChildOfClass("Humanoid")
        end
        
        local function getRoot(char)
            if not char then return nil end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then return root end
            return char:WaitForChild("HumanoidRootPart", 2)
        end
    
        local MovementTab = Window:CreateTab("🎮 Movement")
        
        local state = {
            flying = false, swimming = false, vflyEnabled = false, noclip = nil, bhop = false, infJumpConn = nil,
            defaultWalkSpeed = 16, defaultJumpPower = 50, defaultGravity = Core.workspace.Gravity or 196.2,
            flySpeedValue = 50, vehiclenoclip = false, currentveh = nil, seatconn = nil, oldgrav = Core.workspace.Gravity,
            swimbeat = nil, gravReset = nil, vflyKeyDown = nil, vflyKeyUp = nil, CFspeed = 50, CFloop = nil, flyConn = nil,
            spiderConn = nil, spiderEnabled = false, swimConn = nil, swimEnabled = false, bhopConn = nil, clickTpConn = nil
        }
        
        MovementTab:CreateSection("Player")
        
        MovementTab:CreateToggle({
            Name = "Platforms (F)", CurrentValue = false,
            Callback = function(enabled)
                local connection
                if enabled then
                    connection = Core.UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.KeyCode == Enum.KeyCode.F then
                            local char = getChar()
                            local root = getRoot(char)
                            if root then
                                local part = Instance.new("Part")
                                part.Anchored = true
                                part.Size = Vector3.new(6, 1, 6)
                                part.Position = root.Position - Vector3.new(0, 3, 0)
                                part.Color = Color3.new(0, 0, 0)
                                part.Material = Enum.Material.SmoothPlastic
                                part.Parent = Core.workspace
                                task.delay(3, function() if part then part:Destroy() end end)
                            end
                        end
                    end)
                elseif connection then connection:Disconnect() end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Noclip", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.noclip = Core.RunService.Stepped:Connect(function()
                        local char = getChar()
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                        end
                    end)
                elseif state.noclip then state.noclip:Disconnect() state.noclip = nil end
            end
        })
        
        task.spawn(function()
            while true do
                task.wait()
                if not state.vehiclenoclip then continue end
                local char = getChar()
                local hum = getHum(char)
                if hum and hum.SeatPart then
                    if not state.currentveh then
                        state.currentveh = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
                    end
                    if state.currentveh then
                        for _,p in pairs(state.currentveh:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    end
                    if char then
                        for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    end
                end
            end
        end)
        
        MovementTab:CreateToggle({
            Name = "Low Gravity", CurrentValue = false,
            Callback = function(stateVal)
                local char = getChar()
                local humanoid = getHum(char)
                if stateVal then
                    if humanoid then
                        state.oldgrav = Core.workspace.Gravity
                        Core.workspace.Gravity = 0
                    end
                else
                    if humanoid then
                        Core.workspace.Gravity = state.oldgrav
                    end
                end
            end
        })

        MovementTab:CreateToggle({
            Name = "Weird Gravity", CurrentValue = false,
            Callback = function(stateVal)
                local char = getChar()
                local humanoid = getHum(char)
                if stateVal then
                    if humanoid then
                        state.oldgrav = Core.workspace.Gravity
                        Core.workspace.Gravity = 10
                    end
                else
                    if humanoid then
                        Core.workspace.Gravity = state.oldgrav
                    end
                end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Infinite Jump", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.infJumpConn = Core.UserInputService.JumpRequest:Connect(function()
                        local char = getChar()
                        local root = getRoot(char)
                        if root then root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z) end
                    end)
                elseif state.infJumpConn then state.infJumpConn:Disconnect() state.infJumpConn = nil end
            end
        })

        MovementTab:CreateToggle({
            Name = "Fly", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    if state.flyConn then state.flyConn:Disconnect() end
                    local char = getChar()
                    local root = getRoot(char)
                    local hum = getHum(char)
                    if not root or not hum then return end
                    
                    hum.PlatformStand = true
                    state.flyConn = Core.RunService.RenderStepped:Connect(function()
                        local root = getRoot(char)
                        if not root then return end
                        local moveDirection = Vector3.new()
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
                        
                        if moveDirection.Magnitude > 0 then
                            moveDirection = moveDirection.Unit
                        end
                        
                        local camera = Core.workspace.CurrentCamera
                        local forward = camera.CFrame.LookVector
                        local right = camera.CFrame.RightVector
                        local up = camera.CFrame.UpVector
                        
                        local velocity = (forward * moveDirection.Z + right * moveDirection.X + up * moveDirection.Y) * state.flySpeedValue
                        root.Velocity = velocity
                    end)
                else
                    if state.flyConn then
                        state.flyConn:Disconnect()
                        state.flyConn = nil
                    end
                    local char = getChar()
                    local hum = getHum(char)
                    if hum then
                        hum.PlatformStand = false
                    end
                end
            end
        })

        MovementTab:CreateToggle({
            Name = "Spider", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    if state.spiderConn then state.spiderConn:Disconnect() end
                    state.spiderEnabled = true
                    state.spiderConn = Core.RunService.RenderStepped:Connect(function()
                        if not state.spiderEnabled then return end
                        local char = getChar()
                        local root = getRoot(char)
                        local hum = getHum(char)
                        if not root or not hum then return end
                        
                        local rayOrigin = root.Position
                        local rayDirection = root.CFrame.UpVector * -1
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.FilterDescendantsInstances = {char}
                        
                        local rayResult = Core.workspace:Raycast(rayOrigin, rayDirection * 3, rayParams)
                        
                        if rayResult then
                            local wallNormal = rayResult.Normal
                            local wallTangent = Vector3.new(1, 0, 0)
                            if math.abs(wallNormal.Y) > 0.9 then
                                hum.PlatformStand = false
                                return
                            end
                            
                            hum.PlatformStand = true
                            local moveDirection = Vector3.new()
                            if Core.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
                            if Core.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
                            if Core.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
                            if Core.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
                            if Core.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
                            
                            if moveDirection.Magnitude > 0 then
                                moveDirection = moveDirection.Unit
                            end
                            
                            local camera = Core.workspace.CurrentCamera
                            local right = camera.CFrame.RightVector
                            local up = camera.CFrame.UpVector
                            local forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
                            
                            local horizontalMove = (right * moveDirection.X + forward * moveDirection.Z) * 50
                            local verticalMove = up * moveDirection.Y * 30
                            local moveVelocity = horizontalMove + verticalMove
                            
                            local wallParallel = moveVelocity - (moveVelocity:Dot(wallNormal)) * wallNormal
                            root.Velocity = wallParallel + Vector3.new(0, root.Velocity.Y, 0) * 0.5
                        else
                            hum.PlatformStand = false
                        end
                    end)
                else
                    state.spiderEnabled = false
                    if state.spiderConn then
                        state.spiderConn:Disconnect()
                        state.spiderConn = nil
                    end
                    local char = getChar()
                    local hum = getHum(char)
                    if hum then
                        hum.PlatformStand = false
                    end
                end
            end
        })

        MovementTab:CreateToggle({
            Name = "Swim", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    if state.swimConn then state.swimConn:Disconnect() end
                    state.swimEnabled = true
                    state.swimConn = Core.RunService.RenderStepped:Connect(function()
                        if not state.swimEnabled then return end
                        local char = getChar()
                        local hum = getHum(char)
                        local root = getRoot(char)
                        if not hum or not root then return end
                        
                        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                        hum:ChangeState(Enum.HumanoidStateType.Swimming)
                        
                        local moveDirection = Vector3.new()
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
                        
                        if moveDirection.Magnitude > 0 then
                            moveDirection = moveDirection.Unit
                        end
                        
                        local camera = Core.workspace.CurrentCamera
                        local forward = camera.CFrame.LookVector
                        local right = camera.CFrame.RightVector
                        local up = camera.CFrame.UpVector
                        
                        local velocity = (forward * moveDirection.Z + right * moveDirection.X + up * moveDirection.Y) * 40
                        root.Velocity = velocity
                    end)
                else
                    state.swimEnabled = false
                    if state.swimConn then
                        state.swimConn:Disconnect()
                        state.swimConn = nil
                    end
                    local char = getChar()
                    local hum = getHum(char)
                    if hum then
                        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                        if hum:GetState() == Enum.HumanoidStateType.Swimming then
                            hum:ChangeState(Enum.HumanoidStateType.Landed)
                        end
                    end
                end
            end
        })

        MovementTab:CreateToggle({
            Name = "BHop", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    if state.bhopConn then state.bhopConn:Disconnect() end
                    state.bhop = true
                    state.bhopConn = Core.RunService.RenderStepped:Connect(function()
                        if not state.bhop then return end
                        local char = getChar()
                        local hum = getHum(char)
                        if not hum then return end
                        
                        if hum:GetState() == Enum.HumanoidStateType.Landed then
                            hum.Jump = true
                        end
                    end)
                else
                    state.bhop = false
                    if state.bhopConn then
                        state.bhopConn:Disconnect()
                        state.bhopConn = nil
                    end
                end
            end
        })

        MovementTab:CreateToggle({
            Name = "Click TP", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    if state.clickTpConn then state.clickTpConn:Disconnect() end
                    state.clickTpConn = Core.UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local char = getChar()
                            local root = getRoot(char)
                            if not root then return end
                            
                            local mouse = Core.UserInputService:GetMouseLocation()
                            local camera = Core.workspace.CurrentCamera
                            local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                            rayParams.FilterDescendantsInstances = {char}
                            
                            local rayResult = Core.workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
                            if rayResult then
                                local targetPos = rayResult.Position
                                root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                            end
                        end
                    end)
                else
                    if state.clickTpConn then
                        state.clickTpConn:Disconnect()
                        state.clickTpConn = nil
                    end
                end
            end
        })

        MovementTab:CreateSection("Sliders")
        MovementTab:CreateSlider({Name = "Walkspeed", Range = {0,500}, Increment = 5, CurrentValue = Core.Humanoid.WalkSpeed, Callback = function(value) if Core.Humanoid then Core.Humanoid.WalkSpeed = value end end})
        MovementTab:CreateSlider({Name = "Jump Power", Range = {0,500}, Increment = 5, CurrentValue = Core.Humanoid.JumpPower, Callback = function(value) if Core.Humanoid then Core.Humanoid.JumpPower = value end end})
        MovementTab:CreateSlider({Name = "Gravity", Range = {0,500}, Increment = 1, CurrentValue = state.defaultGravity, Callback = function(value) Core.workspace.Gravity = value end})
        MovementTab:CreateButton({Name = "Reset Walkspeed", Callback = function() if Core.Humanoid then Core.Humanoid.WalkSpeed = state.defaultWalkSpeed end end})
        MovementTab:CreateButton({Name = "Reset Jump Power", Callback = function() if Core.Humanoid then Core.Humanoid.JumpPower = state.defaultJumpPower end end})
        MovementTab:CreateButton({Name = "Reset Gravity", Callback = function() Core.workspace.Gravity = state.defaultGravity end})
        MovementTab:CreateSlider({Name = "Fly Speed", Range = {10,300}, Increment = 1, CurrentValue = state.flySpeedValue, Callback = function(v) state.flySpeedValue = v end})
    
    end
}
