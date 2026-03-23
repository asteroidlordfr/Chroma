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
            fullbrightEnabled = false, originalBrightness = nil
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
            Name = "Fullbright",
            CurrentValue = false,
            Callback = function(enabled)
                local lighting = Core.game:GetService("Lighting")
                if enabled then
                    state.originalBrightness = lighting.Brightness
                    lighting.Brightness = 2
                    lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                    lighting.Ambient = Color3.new(1, 1, 1)
                    state.fullbrightEnabled = true
                else
                    if state.originalBrightness then
                        lighting.Brightness = state.originalBrightness
                        lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
                        lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
                    end
                    state.fullbrightEnabled = false
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

    
    end
}
