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
        local OpTab = Window:CreateTab("🤫 OP")
        local state = {antiKnockbackConn = nil}
        
        OpTab:CreateSection("Player")
        
        OpTab:CreateButton({
            Name = "Headless",
            Callback = function()
                local char = Core.Utils.getCharacter()
                local head = char:FindFirstChild("Head")
                if head then
                    head.Transparency = 1
                    local face = head:FindFirstChild("face")
                    if face then face.Transparency = 1 end
                end
            end
        })
        
        OpTab:CreateToggle({
            Name = "Anti Knockback", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.antiKnockbackConn = Core.RunService.Heartbeat:Connect(function()
                        local char = Core.Utils.getCharacter()
                        if not char then return end
                        local root = Core.Utils.getRootPart(char)
                        local hum = char:FindFirstChildWhichIsA("Humanoid")
                        if root and hum and hum.MoveDirection.Magnitude > 0 then
                            local moveDir = hum.MoveDirection.Unit
                            local speed = 40
                            local currentVel = root.AssemblyLinearVelocity
                            root.AssemblyLinearVelocity = Vector3.new(moveDir.X * speed, currentVel.Y, moveDir.Z * speed)
                        elseif root then
                            local currentVel = root.AssemblyLinearVelocity
                            root.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
                        end
                    end)
                elseif state.antiKnockbackConn then state.antiKnockbackConn:Disconnect() state.antiKnockbackConn = nil end
            end
        })
        
        OpTab:CreateSlider({
            Name = "Undetected Speed", Range = {0, 100}, Increment = 1, Suffix = " studs", CurrentValue = 0,
            Callback = function(speed)
                if state.antiKnockbackConn then state.antiKnockbackConn:Disconnect() state.antiKnockbackConn = nil end
                if speed > 0 then
                    state.antiKnockbackConn = Core.RunService.Heartbeat:Connect(function()
                        local char = Core.Utils.getCharacter()
                        if not char then return end
                        local root = Core.Utils.getRootPart(char)
                        local hum = char:FindFirstChildWhichIsA("Humanoid")
                        if root and hum and hum.MoveDirection.Magnitude > 0 then
                            local moveDir = hum.MoveDirection.Unit
                            root.Velocity = Vector3.new(moveDir.X * speed, root.Velocity.Y, moveDir.Z * speed)
                        elseif root then
                            root.Velocity = Vector3.new(0, root.Velocity.Y, 0)
                        end
                    end)
                end
            end
        })
        
        local godModeConn
        OpTab:CreateToggle({
            Name = "God Mode", CurrentValue = false,
            Callback = function(stateVal)
                if stateVal then
                    if godModeConn then godModeConn:Disconnect() end
                    godModeConn = Core.Humanoid.HealthChanged:Connect(function()
                        if Core.Humanoid then Core.Humanoid.Health = Core.Humanoid.MaxHealth end
                    end)
                elseif godModeConn then godModeConn:Disconnect() godModeConn = nil end
            end
        })
        
        local autoHealConn
        OpTab:CreateToggle({
            Name = "Auto Heal", CurrentValue = false,
            Callback = function(stateVal)
                if stateVal then
                    if autoHealConn then autoHealConn:Disconnect() end
                    autoHealConn = Core.Humanoid.HealthChanged:Connect(function()
                        if Core.Humanoid and Core.Humanoid.Health < 30 then Core.Humanoid.Health = 100 end
                    end)
                elseif autoHealConn then autoHealConn:Disconnect() autoHealConn = nil end
            end
        })
        
        local walkWaterConn
        OpTab:CreateToggle({
            Name = "Walk On Water", CurrentValue = false,
            Callback = function(stateVal)
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
                    walkWaterConn = Core.RunService.Heartbeat:Connect(function() set() end)
                elseif walkWaterConn then walkWaterConn:Disconnect() walkWaterConn = nil end
            end
        })
    end
}
