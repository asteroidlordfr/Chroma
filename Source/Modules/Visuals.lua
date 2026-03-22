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
            espEnabled = false,
            boneEspEnabled = false,
            xrayActive = false,
            fpsBoostBackup = nil,
            chamsHighlights = nil,
            espBoxes = {},
            espTexts = {},
            boneEspLines = {},
        }

        VisualTab:CreateToggle({
            Name = "X-Ray",
            CurrentValue = false,
            Callback = function(enabled)
                local function setTransparency(value)
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") or v:IsA("MeshPart") then
                            v.LocalTransparencyModifier = value
                        end
                    end
                end
                if enabled then
                    setTransparency(0.5)
                    state.xrayActive = true
                elseif state.xrayActive then
                    setTransparency(0)
                    state.xrayActive = false
                end
            end
        })
        
        VisualTab:CreateToggle({
            Name = "FPS Boost",
            CurrentValue = false,
            Callback = function(enabled)
                local lighting = game.Lighting
                if enabled then
                    state.fpsBoostBackup = {
                        GlobalShadows = lighting.GlobalShadows,
                        Technology = lighting.Technology,
                        PartSettings = {},
                        Effects = {}
                    }
                    lighting.GlobalShadows = false
                    lighting.Technology = Enum.Technology.Compatibility
                    for _, v in ipairs(workspace:GetDescendants()) do
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
                    for v, mat in pairs(state.fpsBoostBackup.PartSettings) do
                        if v and v.Parent then v.Material = mat end
                    end
                    for v, enabledState in pairs(state.fpsBoostBackup.Effects) do
                        if v and v.Parent then v.Enabled = enabledState end
                    end
                    state.fpsBoostBackup = nil
                end
            end
        })
        
        VisualTab:CreateToggle({
            Name = "ESP",
            CurrentValue = false,
            Callback = function(enabled)
                state.espEnabled = enabled
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
                
                if enabled then
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
                    
                    Core.Players.PlayerAdded:Connect(function(player)
                        if player ~= Core.LocalPlayer then
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
                        if state.espBoxes[player] then
                            state.espBoxes[player]:Destroy()
                            state.espBoxes[player] = nil
                        end
                        if state.espTexts[player] then
                            state.espTexts[player]:Destroy()
                            state.espTexts[player] = nil
                        end
                    end)
                else
                    for _, box in pairs(state.espBoxes) do
                        box:Destroy()
                    end
                    for _, tag in pairs(state.espTexts) do
                        tag:Destroy()
                    end
                    state.espBoxes = {}
                    state.espTexts = {}
                end
            end
        })
        
        VisualTab:CreateSection("FOV")
        local defaultFOV = Core.Camera.FieldOfView
        
        VisualTab:CreateSlider({
            Name = "FOV Amount", Range = {1, 120}, Increment = 1,
            CurrentValue = defaultFOV,
            Callback = function(v) Core.Camera.FieldOfView = v end
        })
        
        VisualTab:CreateButton({
            Name = "Reset FOV",
            Callback = function() Core.Camera.FieldOfView = defaultFOV end
        })
    end
}
