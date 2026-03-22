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
        local CombatTab = Window:CreateTab("🎯 Cheats")
        local state = {
            aimbotEnabled = false,
            aimbotRightClick = false,
            teamCheck = true,
            wallCheck = false,
            fovCircle = Drawing.new("Circle"),
            fovCircleVisible = true,
        }
        
        state.fovCircle.Visible = false
        state.fovCircle.Color = Color3.fromRGB(255,255,255)
        state.fovCircle.Thickness = 1
        state.fovCircle.NumSides = 64
        state.fovCircle.Filled = false

        local function getClosestPlayer()
            local localRoot = Core.Utils.getRootPart(Core.Utils.getCharacter())
            if not localRoot then return nil end
            
            local ignoreTeams = {Lobby = true, Spectate = true, Spectator = true, Spec = true}
            local closestPlayer, closestDist = nil, math.huge
            
            for _, plr in pairs(Core.Players:GetPlayers()) do
                if plr ~= Core.LocalPlayer and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    local humanoid = plr.Character:FindFirstChild("Humanoid")
                    
                    if head and humanoid and humanoid.Health > 0 then
                        if state.teamCheck and plr.Team == Core.LocalPlayer.Team then continue end
                        if state.teamCheck and ignoreTeams[plr.Team and plr.Team.Name or ""] then continue end
                        
                        if state.wallCheck then
                            local origin = Core.Camera.CFrame.Position
                            local direction = head.Position - origin
                            local params = RaycastParams.new()
                            params.FilterDescendantsInstances = {Core.Utils.getCharacter()}
                            params.FilterType = Enum.RaycastFilterType.Blacklist
                            local result = workspace:Raycast(origin, direction, params)
                            if result and not result.Instance:IsDescendantOf(plr.Character) then continue end
                        end
                        
                        local dist = (localRoot.Position - head.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPlayer = plr
                        end
                    end
                end
            end
            return closestPlayer
        end
        
        local function toggleAimbot(enable)
            if state.aimbotConnection then
                state.aimbotConnection:Disconnect()
                state.aimbotConnection = nil
            end
            if enable then
                state.aimbotConnection = Core.RunService.RenderStepped:Connect(function()
                    local mousePos = Core.UserInputService:GetMouseLocation()
                    if state.fovCircleVisible then
                        state.fovCircle.Visible = true
                        pcall(function() state.fovCircle.Position = mousePos end)
                        state.fovCircle.Radius = 120
                    end
                    
                    if state.aimbotRightClick and not Core.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
                    
                    local target = getClosestPlayer()
                    if target and target.Character and target.Character:FindFirstChild("Head") then
                        local head = target.Character.Head
                        Core.Camera.CFrame = CFrame.new(Core.Camera.CFrame.Position, head.Position)
                    end
                end)
            else
                state.fovCircle.Visible = false
            end
        end
        
        CombatTab:CreateSection("Aimbot")
        
        CombatTab:CreateToggle({
            Name = "Aimbot [RIGHT CLICK]",
            CurrentValue = false,
            Callback = function(v)
                state.aimbotRightClick = v
                if v then state.aimbotEnabled = false end
                toggleAimbot(v or state.aimbotEnabled)
            end
        })
        
        CombatTab:CreateToggle({
            Name = "Aimbot",
            CurrentValue = false,
            Callback = function(v)
                state.aimbotEnabled = v
                if v then state.aimbotRightClick = false end
                toggleAimbot(v or state.aimbotRightClick)
            end
        })
        
        CombatTab:CreateToggle({
            Name = "Show FOV Circle",
            CurrentValue = true,
            Callback = function(v)
                state.fovCircleVisible = v
                state.fovCircle.Visible = v and (state.aimbotEnabled or state.aimbotRightClick)
            end
        })
        
        CombatTab:CreateSection("Aimbot - Checks")
        
        CombatTab:CreateToggle({
            Name = "Wall Check",
            CurrentValue = false,
            Callback = function(v) state.wallCheck = v end
        })
        
        CombatTab:CreateToggle({
            Name = "Team Check",
            CurrentValue = state.teamCheck,
            Callback = function(v) state.teamCheck = v end
        })
        
        CombatTab:CreateSection("Shooter")
        local aimAssistConn
        
        CombatTab:CreateToggle({
            Name = "Aim Assist",
            CurrentValue = false,
            Callback = function(enabled)
                if aimAssistConn then
                    aimAssistConn:Disconnect()
                    aimAssistConn = nil
                end
                if enabled then
                    local strength = 0.08
                    local fov = 80
                    local maxPullDist = 40
                    local requireRightClick = false
                    
                    local function getClosestToMouse()
                        local closest, closestDist = nil, fov
                        local mousePos = Core.UserInputService:GetMouseLocation()
                        for _, plr in ipairs(Core.Players:GetPlayers()) do
                            if plr ~= Core.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                                local head = plr.Character.Head
                                local screenPos, onScreen = Core.Camera:WorldToScreenPoint(head.Position)
                                if onScreen then
                                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closest = plr
                                    end
                                end
                            end
                        end
                        return closest, closestDist
                    end
                    
                    aimAssistConn = Core.RunService.RenderStepped:Connect(function()
                        if requireRightClick and not Core.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
                        local target, distance = getClosestToMouse()
                        if not target or not target.Character then return end
                        local head = target.Character:FindFirstChild("Head")
                        if not head then return end
                        if distance > maxPullDist then return end
                        local dir = (head.Position - Core.Camera.CFrame.Position).Unit
                        local pullFactor = strength * (distance / maxPullDist)
                        pullFactor = math.clamp(pullFactor, 0, strength)
                        local newLook = Core.Camera.CFrame.LookVector:Lerp(dir, pullFactor)
                        Core.Camera.CFrame = CFrame.new(Core.Camera.CFrame.Position, Core.Camera.CFrame.Position + newLook)
                    end)
                end
            end
        })
    end
}
