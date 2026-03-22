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
            chamsConnection = nil, hitboxVisualizer = nil
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
            Name = "Hitbox Visualizer", CurrentValue = false,
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
            Name = "ESP", CurrentValue = false,
            Callback = function(stateVal)
                state.espEnabled = stateVal
                local function createBox(part)
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = part
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Size = Vector3.new(part.Size.X, 5, part.Size.Z)
                    box.Color3 = Color3.new(1, 0, 0)
                    box.Transparency = 0.5
                    box.Parent = part
                    return box
                end
                local function createNameTag(player, part)
                    local billboard = Instance.new("BillboardGui")
                    billboard.Adornee = part
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                    billboard.Parent = part
                    local textLabel = Instance.new("TextLabel")
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = player.Name
                    textLabel.TextColor3 = Color3.new(1, 0, 0)
                    textLabel.TextStrokeTransparency = 0.5
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextScaled = true
                    textLabel.Parent = billboard
                    return billboard
                end
                if stateVal then
                    for _, player in pairs(Core.Players:GetPlayers()) do
                        if player ~= Core.LocalPlayer then
                            local char = player.Character
                            local root = Core.Utils.getRootPart(char)
                            if root then
                                state.espBoxes[player] = createBox(root)
                                state.espTexts[player] = createNameTag(player, root)
                            end
                        end
                    end
                    local runConnection
                    runConnection = Core.RunService.Heartbeat:Connect(function()
                        if not state.espEnabled then
                            runConnection:Disconnect()
                            for _, box in pairs(state.espBoxes) do box:Destroy() end
                            for _, tag in pairs(state.espTexts) do tag:Destroy() end
                            state.espBoxes = {}
                            state.espTexts = {}
                            return
                        end
                        for player, box in pairs(state.espBoxes) do
                            local char = player.Character
                            local root = char and Core.Utils.getRootPart(char)
                            if root then
                                box.Adornee = root
                                box.Size = Vector3.new(root.Size.X, 5, root.Size.Z)
                                box.Parent = root
                            else
                                box:Destroy()
                                state.espBoxes[player] = nil
                            end
                        end
                        for player, tag in pairs(state.espTexts) do
                            local char = player.Character
                            local root = char and Core.Utils.getRootPart(char)
                            if root then
                                tag.Adornee = root
                                tag.Parent = root
                            else
                                tag:Destroy()
                                state.espTexts[player] = nil
                            end
                        end
                    end)
                    Core.Players.PlayerAdded:Connect(function(player)
                        if state.espEnabled and player ~= Core.LocalPlayer then
                            player.CharacterAdded:Connect(function(char)
                                local root = char:WaitForChild("HumanoidRootPart", 5)
                                if root and state.espEnabled then
                                    state.espBoxes[player] = createBox(root)
                                    state.espTexts[player] = createNameTag(player, root)
                                end
                            end)
                        end
                    end)
                    Core.Players.PlayerRemoving:Connect(function(player)
                        if state.espBoxes[player] then state.espBoxes[player]:Destroy() state.espBoxes[player] = nil end
                        if state.espTexts[player] then state.espTexts[player]:Destroy() state.espTexts[player] = nil end
                    end)
                else
                    for _, box in pairs(state.espBoxes) do box:Destroy() end
                    for _, tag in pairs(state.espTexts) do tag:Destroy() end
                    state.espBoxes = {}
                    state.espTexts = {}
                end
            end,
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
        
        VisualTab:CreateToggle({
            Name = "Bone ESP", CurrentValue = false,
            Callback = function(stateVal)
                state.boneEspEnabled = stateVal
                if state.boneEspEnabled then
                    state.boneEspLines = {}
                    local function createLine(part0, part1)
                        local line = Drawing.new("Line")
                        line.Transparency = 1
                        line.Color = Color3.new(1, 0, 0)
                        line.Thickness = 2
                        line.From = Vector2.new(0,0)
                        line.To = Vector2.new(0,0)
                        return line
                    end
                    local function get2DPos(position, camera)
                        local pos, onScreen = camera:WorldToViewportPoint(position)
                        if onScreen then return Vector2.new(pos.X, pos.Y), true else return Vector2.new(), false end
                    end
                    local function update()
                        for player, data in pairs(state.boneEspLines) do
                            if not player.Character or not Core.Utils.getRootPart(player.Character) then
                                for _, line in pairs(data.lines) do line:Remove() end
                                state.boneEspLines[player] = nil
                            end
                        end
                        for _, player in pairs(Core.Players:GetPlayers()) do
                            if player ~= Core.LocalPlayer and player.Character and Core.Utils.getRootPart(player.Character) then
                                local char = player.Character
                                local joints = {
                                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "LeftUpperLeg"},
                                    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
                                    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}, {"UpperTorso", "LeftUpperArm"},
                                    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
                                    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                                }
                                if not state.boneEspLines[player] then
                                    state.boneEspLines[player] = {lines = {}}
                                    for _ in pairs(joints) do table.insert(state.boneEspLines[player].lines, createLine()) end
                                end
                                for i, joint in pairs(joints) do
                                    local part0 = char:FindFirstChild(joint[1])
                                    local part1 = char:FindFirstChild(joint[2])
                                    local line = state.boneEspLines[player].lines[i]
                                    if part0 and part1 then
                                        local pos0, onScreen0 = get2DPos(part0.Position, Core.Camera)
                                        local pos1, onScreen1 = get2DPos(part1.Position, Core.Camera)
                                        if onScreen0 and onScreen1 then
                                            line.From = pos0
                                            line.To = pos1
                                            line.Visible = true
                                        else line.Visible = false end
                                    else line.Visible = false end
                                end
                            elseif state.boneEspLines[player] then
                                for _, line in pairs(state.boneEspLines[player].lines) do line:Remove() end
                                state.boneEspLines[player] = nil
                            end
                        end
                    end
                    state.boneEspConnection = Core.RunService.RenderStepped:Connect(update)
                else
                    if state.boneEspConnection then state.boneEspConnection:Disconnect() state.boneEspConnection = nil end
                    if state.boneEspLines then
                        for _, data in pairs(state.boneEspLines) do for _, line in pairs(data.lines) do line:Remove() end end
                        state.boneEspLines = nil
                    end
                end
            end,
        })
    end
}
