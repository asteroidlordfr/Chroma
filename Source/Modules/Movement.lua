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
            flying = false, swimming = false, vflyEnabled = false, noclip = nil, bhop = false, infJumpConn = nil,
            defaultWalkSpeed = 16, defaultJumpPower = 50, defaultGravity = Core.workspace.Gravity or 196.2,
            flySpeedValue = 50, vehiclenoclip = false, currentveh = nil, seatconn = nil, oldgrav = Core.workspace.Gravity,
            swimbeat = nil, gravReset = nil, vflyKeyDown = nil, vflyKeyUp = nil, CFspeed = 50, CFloop = nil, flyConn = nil
        }
        
        MovementTab:CreateSection("Sliders")
        MovementTab:CreateSlider({Name = "Walkspeed", Range = {0,500}, Increment = 5, CurrentValue = Core.Humanoid.WalkSpeed, Callback = function(value) Core.Humanoid.WalkSpeed = value end})
        MovementTab:CreateSlider({Name = "Jump Power", Range = {0,500}, Increment = 5, CurrentValue = Core.Humanoid.JumpPower, Callback = function(value) Core.Humanoid.JumpPower = value end})
        MovementTab:CreateSlider({Name = "Gravity", Range = {0,500}, Increment = 1, CurrentValue = state.defaultGravity, Callback = function(value) Core.workspace.Gravity = value end})
        MovementTab:CreateButton({Name = "Reset Walkspeed", Callback = function() Core.Humanoid.WalkSpeed = state.defaultWalkSpeed end})
        MovementTab:CreateButton({Name = "Reset Jump Power", Callback = function() Core.Humanoid.JumpPower = state.defaultJumpPower end})
        MovementTab:CreateButton({Name = "Reset Gravity", Callback = function() Core.workspace.Gravity = state.defaultGravity end})
        
        MovementTab:CreateSection("Player")
        
        MovementTab:CreateToggle({
            Name = "Platforms (F)", CurrentValue = false,
            Callback = function(enabled)
                local connection
                if enabled then
                    connection = Core.UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.KeyCode == Enum.KeyCode.F then
                            local char = Core.Utils.getCharacter()
                            local root = Core.Utils.getRootPart(char)
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
                        local char = Core.Utils.getCharacter()
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                            end
                        end
                    end)
                elseif state.noclip then state.noclip:Disconnect() state.noclip = nil end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Noclip [Vehicle]", CurrentValue = false,
            Callback = function(v)
                state.vehiclenoclip = v
                if not v then
                    if state.seatconn then state.seatconn:Disconnect() state.seatconn = nil end
                    local char = Core.Utils.getCharacter()
                    if char then
                        for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                    end
                    if state.currentveh then
                        for _,p in pairs(state.currentveh:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                    end
                    state.currentveh = nil
                end
            end
        })
        
        task.spawn(function()
            while true do
                task.wait()
                if not state.vehiclenoclip then continue end
                local char = Core.Utils.getCharacter()
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart then
                    if not state.currentveh then
                        state.currentveh = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
                        if state.seatconn then state.seatconn:Disconnect() end
                        state.seatconn = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
                            if hum.SeatPart == nil then
                                state.vehiclenoclip = false
                                if char then
                                    for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                                end
                                if state.currentveh then
                                    for _,p in pairs(state.currentveh:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                                end
                                state.currentveh = nil
                                if state.seatconn then state.seatconn:Disconnect() state.seatconn = nil end
                            end
                        end)
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
            Name = "Swim", CurrentValue = false,
            Callback = function(stateVal)
                local char = Core.Utils.getCharacter()
                local humanoid = char:FindFirstChildWhichIsA("Humanoid")
                if stateVal then
                    if not state.swimming and humanoid then
                        state.oldgrav = Core.workspace.Gravity
                        Core.workspace.Gravity = 0
                        local function swimDied() Core.workspace.Gravity = state.oldgrav state.swimming = false end
                        state.gravReset = humanoid.Died:Connect(swimDied)
                        local enums = Enum.HumanoidStateType:GetEnumItems()
                        table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
                        for _, v in pairs(enums) do humanoid:SetStateEnabled(v, false) end
                        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                        state.swimbeat = Core.RunService.Heartbeat:Connect(function()
                            pcall(function()
                                local root = Core.Utils.getRootPart(char)
                                if root then root.Velocity = ((humanoid.MoveDirection ~= Vector3.new() or Core.UserInputService:IsKeyDown(Enum.KeyCode.Space)) and root.Velocity or Vector3.new()) end
                            end)
                        end)
                        state.swimming = true
                    end
                else
                    if humanoid then
                        Core.workspace.Gravity = state.oldgrav
                        state.swimming = false
                        if state.gravReset then state.gravReset:Disconnect() end
                        if state.swimbeat then state.swimbeat:Disconnect() state.swimbeat = nil end
                        local enums = Enum.HumanoidStateType:GetEnumItems()
                        table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
                        for _, v in pairs(enums) do humanoid:SetStateEnabled(v, true) end
                    end
                end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Walk On Water", CurrentValue = false,
            Callback = function(stateVal)
                local walkWater = stateVal
                local conn
                local function set()
                    local char = Core.Utils.getCharacter()
                    local hrp = Core.Utils.getRootPart(char)
                    if not hrp then return end
                    local ray = Ray.new(hrp.Position, Vector3.new(0, -5, 0))
                    local hit, pos = Core.workspace:FindPartOnRay(ray, char)
                    if hit and hit.Material == Enum.Material.Water then
                        hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, pos.Y + 3, hrp.Position.Z))
                    end
                end
                if stateVal then
                    conn = Core.RunService.Heartbeat:Connect(function() if walkWater then set() end end)
                elseif conn then conn:Disconnect() conn = nil end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Bunny Hop", CurrentValue = false,
            Callback = function(stateVal)
                if stateVal then
                    state.bhop = true
                    task.spawn(function()
                        while state.bhop do
                            local char = Core.Utils.getCharacter()
                            local h = char and char:FindFirstChildOfClass("Humanoid")
                            if h and h.FloorMaterial ~= Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                            task.wait(0.1)
                        end
                    end)
                else state.bhop = false end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Infinite Jump", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.infJumpConn = Core.UserInputService.JumpRequest:Connect(function()
                        local char = Core.Utils.getCharacter()
                        local root = Core.Utils.getRootPart(char)
                        if root then root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z) end
                    end)
                elseif state.infJumpConn then state.infJumpConn:Disconnect() state.infJumpConn = nil end
            end
        })
        
        MovementTab:CreateSection("Fly")
        
        MovementTab:CreateSlider({Name = "Fly Speed", Range = {10,300}, Increment = 1, CurrentValue = state.flySpeedValue, Callback = function(v) state.flySpeedValue = v end})
        
        MovementTab:CreateToggle({
            Name = "Fly", CurrentValue = false,
            Callback = function(stateVal)
                local char = Core.Utils.getCharacter()
                local hrp = Core.Utils.getRootPart(char)
                local hum = char:FindFirstChildOfClass("Humanoid")
                if stateVal then
                    state.flying = true
                    hum.PlatformStand = true
                    state.flyConn = Core.RunService.RenderStepped:Connect(function()
                        local moveDir = Vector3.zero
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Core.Camera.CFrame.LookVector end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Core.Camera.CFrame.LookVector end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Core.Camera.CFrame.RightVector end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Core.Camera.CFrame.RightVector end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                        if Core.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                        if moveDir.Magnitude > 0 then hrp.Velocity = moveDir.Unit * state.flySpeedValue else hrp.Velocity = Vector3.zero end
                    end)
                else
                    state.flying = false
                    if state.flyConn then state.flyConn:Disconnect() end
                    hum.PlatformStand = false
                    hrp.Velocity = Vector3.zero
                end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Fly [Vehicle]", CurrentValue = false,
            Callback = function(stateVal)
                local char = Core.Utils.getCharacter()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local root = Core.Utils.getRootPart(char)
                if stateVal then
                    state.vflyEnabled = true
                    local control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                    local lcontrol = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                    local speed = 0
                    local flySpeed = state.flySpeedValue / 50
                    local gyro = Instance.new("BodyGyro")
                    local vel = Instance.new("BodyVelocity")
                    gyro.P = 9e4
                    gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    gyro.CFrame = root.CFrame
                    gyro.Parent = root
                    vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    vel.Parent = root
                    state.vflyKeyDown = Core.UserInputService.InputBegan:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.W then control.F = flySpeed end
                        if input.KeyCode == Enum.KeyCode.S then control.B = -flySpeed end
                        if input.KeyCode == Enum.KeyCode.A then control.L = -flySpeed end
                        if input.KeyCode == Enum.KeyCode.D then control.R = flySpeed end
                        if input.KeyCode == Enum.KeyCode.E then control.Q = flySpeed * 2 end
                        if input.KeyCode == Enum.KeyCode.Q then control.E = -flySpeed * 2 end
                        pcall(function() Core.Camera.CameraType = Enum.CameraType.Track end)
                    end)
                    state.vflyKeyUp = Core.UserInputService.InputEnded:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.W then control.F = 0 end
                        if input.KeyCode == Enum.KeyCode.S then control.B = 0 end
                        if input.KeyCode == Enum.KeyCode.A then control.L = 0 end
                        if input.KeyCode == Enum.KeyCode.D then control.R = 0 end
                        if input.KeyCode == Enum.KeyCode.E then control.Q = 0 end
                        if input.KeyCode == Enum.KeyCode.Q then control.E = 0 end
                    end)
                    task.spawn(function()
                        repeat task.wait()
                            if (control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0 then speed = state.flySpeedValue elseif speed ~= 0 then speed = 0 end
                            if (control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0 then
                                vel.Velocity = ((Core.Camera.CFrame.LookVector * (control.F + control.B)) + ((Core.Camera.CFrame * CFrame.new(control.L + control.R, (control.F + control.B + control.Q + control.E) * 0.2, 0).p) - Core.Camera.CFrame.p)) * speed
                                lcontrol = {F = control.F, B = control.B, L = control.L, R = control.R}
                            elseif speed ~= 0 then
                                vel.Velocity = ((Core.Camera.CFrame.LookVector * (lcontrol.F + lcontrol.B)) + ((Core.Camera.CFrame * CFrame.new(lcontrol.L + lcontrol.R, (lcontrol.F + lcontrol.B + control.Q + control.E) * 0.2, 0).p) - Core.Camera.CFrame.p)) * speed
                            else vel.Velocity = Vector3.zero end
                            gyro.CFrame = Core.Camera.CFrame
                        until not state.vflyEnabled
                        control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                        lcontrol = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                        speed = 0
                        gyro:Destroy()
                        vel:Destroy()
                        if humanoid then humanoid.PlatformStand = false end
                    end)
                else
                    state.vflyEnabled = false
                    if state.vflyKeyDown then state.vflyKeyDown:Disconnect() end
                    if state.vflyKeyUp then state.vflyKeyUp:Disconnect() end
                    pcall(function() Core.Camera.CameraType = Enum.CameraType.Custom end)
                    if humanoid then humanoid.PlatformStand = false end
                end
            end
        })
        
        MovementTab:CreateToggle({
            Name = "Fly [CFrame]", CurrentValue = false,
            Callback = function(stateVal)
                local char = Core.Utils.getCharacter()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local head = char:WaitForChild("Head")
                if stateVal then
                    state.CFspeed = state.flySpeedValue
                    humanoid.PlatformStand = true
                    head.Anchored = true
                    state.CFloop = Core.RunService.Heartbeat:Connect(function(dt)
                        local moveDirection = humanoid.MoveDirection * (state.CFspeed * dt)
                        local cameraCFrame = Core.Camera.CFrame
                        local cameraOffset = head.CFrame:ToObjectSpace(cameraCFrame).Position
                        cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
                        local cameraPosition = cameraCFrame.Position
                        local headPosition = head.CFrame.Position
                        local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
                        head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
                    end)
                else
                    if state.CFloop then state.CFloop:Disconnect() end
                    humanoid.PlatformStand = false
                    head.Anchored = false
                end
            end
        })
    end
}
