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
        local VisualTab = Window:CreateTab("👀 Visual")
        local state = {
            espEnabled = false, boneEspEnabled = false, xrayActive = false, fpsBoostBackup = nil,
            chamsHighlights = nil, espBoxes = {}, espTexts = {}, boneEspLines = {}, boneEspConnection = nil,
            chamsConnection = nil, hitboxVisualizer = nil,
            tracerEnabled = false, tracerLines = {}, tracerConnection = nil,
            boneEnabled = false, boneLines = {}, boneConnection = nil
        }
        
        VisualTab:CreateToggle({
            Name = "X-Ray", CurrentValue = false,
            Callback = function(enabled)
                local function setTransparency(value)
                    for _, v in ipairs(Core.workspace:GetDescendants()) do
                        if v:IsA("BasePart") or v:IsA("MeshPart") then v.LocalTransparencyModifier = value end
                    end
                end
                if enabled then setTransparency(0.5) state.xrayActive = true
                elseif state.xrayActive then setTransparency(0) state.xrayActive = false end
            end
        })
        
        VisualTab:CreateToggle({
            Name = "FPS Boost", CurrentValue = false,
            Callback = function(enabled)
                local lighting = Core.game.Lighting
                if enabled then
                    state.fpsBoostBackup = {GlobalShadows = lighting.GlobalShadows, Technology = lighting.Technology, PartSettings = {}, Effects = {}}
                    lighting.GlobalShadows = false
                    lighting.Technology = Enum.Technology.Compatibility
                    for _, v in ipairs(Core.workspace:GetDescendants()) do
                        if v:IsA("BasePart") then
                            state.fpsBoostBackup.PartSettings[v] = v.Material
                            v.Material = Enum.Material.SmoothPlastic
                        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("PostEffect") then
                            state.fpsBoostBackup.Effects[v] = v.Enabled
                            v.Enabled = false
                        end
                    end
                elseif state.fpsBoostBackup then
                    lighting.GlobalShadows = state.fpsBoostBackup.GlobalShadows
                    lighting.Technology = state.fpsBoostBackup.Technology
                    for v, mat in pairs(state.fpsBoostBackup.PartSettings) do if v and v.Parent then v.Material = mat end end
                    for v, stateVal in pairs(state.fpsBoostBackup.Effects) do if v and v.Parent then v.Enabled = stateVal end end
                    state.fpsBoostBackup = nil
                end
            end
        })
        
        VisualTab:CreateToggle({
            Name = "ESP", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.hitboxVisualizer = Core.RunService.RenderStepped:Connect(function()
                        for _, player in ipairs(Core.Players:GetPlayers()) do
                            if player ~= Core.LocalPlayer and player.Character then
                                for _, part in ipairs(player.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        if not part:FindFirstChild("HitboxAdornment") then
                                            local box = Instance.new("BoxHandleAdornment")
                                            box.Name = "HitboxAdornment"
                                            box.Adornee = part
                                            box.AlwaysOnTop = true
                                            box.ZIndex = 5
                                            box.Size = part.Size
                                            box.Color3 = Color3.new(1, 0, 0)
                                            box.Transparency = 0.7
                                            box.Parent = part
                                        end
                                    end
                                end
                            end
                        end
                    end)
                else
                    if state.hitboxVisualizer then state.hitboxVisualizer:Disconnect() end
                    for _, player in ipairs(Core.Players:GetPlayers()) do
                        if player.Character then
                            for _, part in ipairs(player.Character:GetDescendants()) do
                                local adorn = part:FindFirstChild("HitboxAdornment")
                                if adorn then adorn:Destroy() end
                            end
                        end
                    end
                end
            end
        })
        
        VisualTab:CreateToggle({
            Name = "Chams", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.chamsHighlights = {}
                    for _, player in ipairs(Core.Players:GetPlayers()) do
                        if player ~= Core.LocalPlayer and player.Character then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ChamsHighlight"
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                            highlight.FillTransparency = 0.3
                            highlight.OutlineTransparency = 0
                            highlight.Parent = player.Character
                            table.insert(state.chamsHighlights, highlight)
                        end
                    end
                    state.chamsConnection = Core.Players.PlayerAdded:Connect(function(player)
                        player.CharacterAdded:Connect(function(char)
                            task.wait(1)
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ChamsHighlight"
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                            highlight.FillTransparency = 0.3
                            highlight.OutlineTransparency = 0
                            highlight.Parent = char
                            table.insert(state.chamsHighlights, highlight)
                        end)
                    end)
                else
                    if state.chamsConnection then state.chamsConnection:Disconnect() state.chamsConnection = nil end
                    if state.chamsHighlights then
                        for _, h in ipairs(state.chamsHighlights) do if h and h.Parent then h:Destroy() end end
                        state.chamsHighlights = nil
                    end
                end
            end
        })

        -- Tracers Feature
        VisualTab:CreateToggle({
            Name = "Tracers", 
            CurrentValue = false,
            Callback = function(enabled)
                state.tracerEnabled = enabled
                
                if enabled then
                    if state.tracerConnection then state.tracerConnection:Disconnect() end
                    state.tracerConnection = Core.RunService.RenderStepped:Connect(function()
                        if not state.tracerEnabled then return end
                        
                        local localChar = Core.Utils.getCharacter()
                        if not localChar then return end
                        
                        local rootPart = Core.Utils.getRootPart(localChar)
                        if not rootPart then return end
                        
                        local startPos = rootPart.Position
                        
                        -- Clear old tracers
                        for _, line in pairs(state.tracerLines) do
                            if line and line.Remove then
                                line:Remove()
                            end
                        end
                        state.tracerLines = {}
                    
                        for _, player in ipairs(Core.Players:GetPlayers()) do
                            if player ~= Core.LocalPlayer and player.Character then
                                local targetRoot = Core.Utils.getRootPart(player.Character)
                                if targetRoot then
                                    local endPos = targetRoot.Position
                                    
                                    local startScreen = Core.Camera:WorldToViewportPoint(startPos)
                                    local endScreen = Core.Camera:WorldToViewportPoint(endPos)
                                    
                                    local line = Drawing.new("Line")
                                    line.From = Vector2.new(startScreen.X, startScreen.Y)
                                    line.To = Vector2.new(endScreen.X, endScreen.Y)
                                    line.Color = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                                    line.Thickness = 2
                                    line.Visible = true
                                    line.Transparency = 0.5
                                    
                                    table.insert(state.tracerLines, line)
                                end
                            end
                        end
                    end)
                else
                    if state.tracerConnection then
                        state.tracerConnection:Disconnect()
                        state.tracerConnection = nil
                    end
                    
                    for _, line in pairs(state.tracerLines) do
                        if line and line.Remove then
                            line:Remove()
                        end
                    end
                    state.tracerLines = {}
                end
            end
        })
        
        -- Bone ESP Feature
        local function getBonePositions(character)
            local bones = {}
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if not humanoid then return bones end
            
            local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
            
            if isR15 then
                -- R15 Bone positions
                local parts = {
                    Head = character:FindFirstChild("Head"),
                    UpperTorso = character:FindFirstChild("UpperTorso"),
                    LowerTorso = character:FindFirstChild("LowerTorso"),
                    LeftUpperArm = character:FindFirstChild("LeftUpperArm"),
                    LeftLowerArm = character:FindFirstChild("LeftLowerArm"),
                    LeftHand = character:FindFirstChild("LeftHand"),
                    RightUpperArm = character:FindFirstChild("RightUpperArm"),
                    RightLowerArm = character:FindFirstChild("RightLowerArm"),
                    RightHand = character:FindFirstChild("RightHand"),
                    LeftUpperLeg = character:FindFirstChild("LeftUpperLeg"),
                    LeftLowerLeg = character:FindFirstChild("LeftLowerLeg"),
                    LeftFoot = character:FindFirstChild("LeftFoot"),
                    RightUpperLeg = character:FindFirstChild("RightUpperLeg"),
                    RightLowerLeg = character:FindFirstChild("RightLowerLeg"),
                    RightFoot = character:FindFirstChild("RightFoot")
                }

                -- Define bone connections for R15
                local connections = {
                    -- Spine
                    {"Head", "UpperTorso"},
                    {"UpperTorso", "LowerTorso"},
                    -- Left arm
                    {"UpperTorso", "LeftUpperArm"},
                    {"LeftUpperArm", "LeftLowerArm"},
                    {"LeftLowerArm", "LeftHand"},
                    -- Right arm
                    {"UpperTorso", "RightUpperArm"},
                    {"RightUpperArm", "RightLowerArm"},
                    {"RightLowerArm", "RightHand"},
                    -- Left leg
                    {"LowerTorso", "LeftUpperLeg"},
                    {"LeftUpperLeg", "LeftLowerLeg"},
                    {"LeftLowerLeg", "LeftFoot"},
                    -- Right leg
                    {"LowerTorso", "RightUpperLeg"},
                    {"RightUpperLeg", "RightLowerLeg"},
                    {"RightLowerLeg", "RightFoot"}
                }
                
                for _, connection in ipairs(connections) do
                    local part1 = parts[connection[1]]
                    local part2 = parts[connection[2]]
                    if part1 and part2 then
                        table.insert(bones, {part1, part2})
                    end
                end
            else
                -- R6 Bone positions
                local parts = {
                    Head = character:FindFirstChild("Head"),
                    Torso = character:FindFirstChild("Torso"),
                    LeftArm = character:FindFirstChild("Left Arm"),
                    RightArm = character:FindFirstChild("Right Arm"),
                    LeftLeg = character:FindFirstChild("Left Leg"),
                    RightLeg = character:FindFirstChild("Right Leg")
                }

                -- Define bone connections for R6
                local connections = {
                    {"Head", "Torso"},
                    {"Torso", "LeftArm"},
                    {"Torso", "RightArm"},
                    {"Torso", "LeftLeg"},
                    {"Torso", "RightLeg"}
                }
                
                for _, connection in ipairs(connections) do
                    local part1 = parts[connection[1]]
                    local part2 = parts[connection[2]]
                    if part1 and part2 then
                        table.insert(bones, {part1, part2})
                    end
                end
            end
            
            return bones
        end
        
        VisualTab:CreateToggle({
            Name = "Bone ESP",
            CurrentValue = false,
            Callback = function(enabled)
                state.boneEnabled = enabled
                
                if enabled then
                    if state.boneConnection then state.boneConnection:Disconnect() end
                    state.boneConnection = Core.RunService.RenderStepped:Connect(function()
                        if not state.boneEnabled then return end
                        
                        -- Clear old bone lines
                        for _, line in pairs(state.boneLines) do
                            if line and line.Remove then
                                line:Remove()
                            end
                        end
                        state.boneLines = {}
                        
                        for _, player in ipairs(Core.Players:GetPlayers()) do
                            if player ~= Core.LocalPlayer and player.Character then
                                local character = player.Character
                                local bones = getBonePositions(character)
                                local playerColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(0, 255, 0)
                                
                                for _, bone in ipairs(bones) do
                                    local part1, part2 = bone[1], bone[2]
                                    if part1 and part2 and part1.Position and part2.Position then
                                        local screenPos1, onScreen1 = Core.Camera:WorldToScreenPoint(part1.Position)
                                        local screenPos2, onScreen2 = Core.Camera:WorldToScreenPoint(part2.Position)
                                        
                                        if onScreen1 and onScreen2 then
                                            local line = Drawing.new("Line")
                                            line.From = Vector2.new(screenPos1.X, screenPos1.Y)
                                            line.To = Vector2.new(screenPos2.X, screenPos2.Y)
                                            line.Color = playerColor
                                            line.Thickness = 2
                                            line.Visible = true
                                            line.Transparency = 0.7
                                            
                                            table.insert(state.boneLines, line)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                else
                    if state.boneConnection then
                        state.boneConnection:Disconnect()
                        state.boneConnection = nil
                    end
                    
                    for _, line in pairs(state.boneLines) do
                        if line and line.Remove then
                            line:Remove()
                        end
                    end
                    state.boneLines = {}
                end
            end
        })
        
        -- Tracer Settings Section
        VisualTab:CreateSection("Tracer Settings")
        
        local tracerColorState = "Team"
        local tracerColorPicker
        
        VisualTab:CreateDropdown({
            Name = "Tracer Color Mode",
            Options = {"Team", "Red", "Green", "Blue", "White", "Custom"},
            CurrentOption = "Team",
            Callback = function(option)
                tracerColorState = option
                if state.tracerEnabled then
                    -- Refresh tracers to apply new color
                    local wasEnabled = state.tracerEnabled
                    state.tracerEnabled = false
                    task.wait()
                    state.tracerEnabled = wasEnabled
                end
            end
        })
        
        tracerColorPicker = VisualTab:CreateColorPicker({
            Name = "Custom Tracer Color",
            CurrentValue = Color3.fromRGB(255, 255, 255),
            Callback = function(color)
                if state.tracerEnabled and tracerColorState == "Custom" then
                    for _, line in pairs(state.tracerLines) do
                        if line then
                            line.Color = color
                        end
                    end
                end
            end
        })
        
        -- Override tracer connection to use color settings
        -- Store the original color picker reference
        local originalTracerConnection = state.tracerConnection
        
        -- Function to update tracer colors
        local function updateTracerColors()
            if not state.tracerEnabled then return end
            
            for _, player in ipairs(Core.Players:GetPlayers()) do
                if player ~= Core.LocalPlayer and player.Character then
                    local line = state.tracerLines[player]
                    if line then
                        local lineColor
                        if tracerColorState == "Team" then
                            lineColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                        elseif tracerColorState == "Red" then
                            lineColor = Color3.fromRGB(255, 0, 0)
                        elseif tracerColorState == "Green" then
                            lineColor = Color3.fromRGB(0, 255, 0)
                        elseif tracerColorState == "Blue" then
                            lineColor = Color3.fromRGB(0, 0, 255)
                        elseif tracerColorState == "White" then
                            lineColor = Color3.fromRGB(255, 255, 255)
                        elseif tracerColorState == "Custom" then
                            lineColor = tracerColorPicker.CurrentValue
                        end
                        line.Color = lineColor
                    end
                end
            end
        end
        
        -- Override the tracer connection to use colors properly
        if state.tracerConnection then
            state.tracerConnection:Disconnect()
        end
        
        state.tracerConnection = Core.RunService.RenderStepped:Connect(function()
            if not state.tracerEnabled then return end
            
            local localChar = Core.Utils.getCharacter()
            if not localChar then return end
            
            local rootPart = Core.Utils.getRootPart(localChar)
            if not rootPart then return end
            
            local startPos = rootPart.Position
            
            -- Clear old tracers
            for _, line in pairs(state.tracerLines) do
                if line and line.Remove then
                    line:Remove()
                end
            end
            state.tracerLines = {}
            
            for _, player in ipairs(Core.Players:GetPlayers()) do
                if player ~= Core.LocalPlayer and player.Character then
                    local targetRoot = Core.Utils.getRootPart(player.Character)
                    if targetRoot then
                        local endPos = targetRoot.Position
                        
                        local lineColor
                        if tracerColorState == "Team" then
                            lineColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                        elseif tracerColorState == "Red" then
                            lineColor = Color3.fromRGB(255, 0, 0)
                        elseif tracerColorState == "Green" then
                            lineColor = Color3.fromRGB(0, 255, 0)
                        elseif tracerColorState == "Blue" then
                            lineColor = Color3.fromRGB(0, 0, 255)
                        elseif tracerColorState == "White" then
                            lineColor = Color3.fromRGB(255, 255, 255)
                        elseif tracerColorState == "Custom" then
                            lineColor = tracerColorPicker.CurrentValue
                        end
                        
                        local startScreen = Core.Camera:WorldToViewportPoint(startPos)
                        local endScreen = Core.Camera:WorldToViewportPoint(endPos)
                        
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(startScreen.X, startScreen.Y)
                        line.To = Vector2.new(endScreen.X, endScreen.Y)
                        line.Color = lineColor
                        line.Thickness = 2
                        line.Visible = true
                        line.Transparency = 0.5
                        
                        table.insert(state.tracerLines, line)
                    end
                end
            end
        end)
    end
}
