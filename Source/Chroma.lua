--[
-- Chroma
--
-- A open-source Roblox Universal tool to tweak your gameplay to the max.
-- This code is licensed under the GNU General Public License (V3)
--
-- Have fun!
-- (Yes yes, some of this code is GPT but only i'd say only 15/100 is GPT as I don't know much Lua.)
--]

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Library.lua'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = workspace
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaSignal
if ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents") and ReplicatedStorage.ReplicaRemoteEvents:FindFirstChild("Replica_ReplicaSignal") then
    ReplicaSignal = ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaSignal
end

local defaultWalkSpeed = 16
local defaultJumpPower = 50
local AnswersSent = false
local aimbotEnabled = false
local aimbotRightClick = false
local wallCheck = false
local teamCheck = false
local defaultFOV = workspace.CurrentCamera.FieldOfView
local antiAfkEnabled = false
local chatInput = ""
local chatEnabled = false
local chatConnection
local CFspeed = 50
local CFloop
local flyConn
local flying = false
local swimming = false
local oldgrav = workspace.Gravity
local swimbeat
local gravReset
local vflyEnabled = false
local vflyKeyDown
local vflyKeyUp
local speed = 50
local defaultGravity = workspace.Gravity or 196.2
local cycleTimes = {6, 12, 18, 0}
local currentIndex = 1

local function loadAnswers(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success and response then
        local t = {}
        for line in response:gmatch("[^\r\n]+") do
            if line ~= "" then
                table.insert(t, line:lower())
            end
        end
        return t
    end
    return {}
end

Answers = loadAnswers("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Resources/LAW/Answers.txt")

local function getClosestPlayer()
    local closestDist = math.huge
    local target
    local localPlayer = game.Players.LocalPlayer
    local players = game.Players
    local teamCount = 0
    local playerTeams = {}
    for _, p in pairs(players:GetPlayers()) do
        if p.Team then 
            playerTeams[p.Team] = true
        end
    end
    for _ in pairs(playerTeams) do teamCount = teamCount + 1 end
    local ffa = (teamCount <= 1)
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if teamCheck and not ffa and plr.Team == localPlayer.Team then continue end
                if wallCheck then
                    local origin = workspace.CurrentCamera.CFrame.Position
                    local direction = (plr.Character.Head.Position - origin)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {localPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local raycast = workspace:Raycast(origin, direction, raycastParams)
                    if raycast and not raycast.Instance:IsDescendantOf(plr.Character) then continue end
                end
                local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
                local localRoot = localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head"))
                if root and localRoot then
                    local dist = (localRoot.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = plr
                    end
                end
            end
        end
    end
    return target
end

local aimbotConnection
local function toggleAimbot(enable)
    if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
    if enable then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            if aimbotRightClick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
            end
        end)
    end
end

local Window = Library:CreateWindow({
   Name = "🟢 Chroma",
   LoadingTitle = "An open-sourced Roblox universal cheat.",
   LoadingSubtitle = "Licensed under GPLv3",
   Theme = "Ocean",
   ConfigurationSaving = {Enabled = true, FolderName = nil, FileName = "Chroma"},
   KeySystem = false,
})

local function submitAnswers()
    if not ReplicaSignal then return end
    for _, answer in ipairs(Answers) do
        ReplicaSignal:FireServer(2, "Answer", answer)
    end
end

local Movement = Window:CreateTab("🎮 Movement")
Movement:CreateSection("Sliders")
Movement:CreateSlider({Name = "Walkspeed", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.WalkSpeed, Callback = function(value) Humanoid.WalkSpeed = value end})
Movement:CreateSlider({Name = "Jump Power", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.JumpPower, Callback = function(value) Humanoid.JumpPower = value end})
Movement:CreateSlider({
    Name = "Gravity",
    Range = {0,500},
    Increment = 1,
    CurrentValue = defaultGravity,
    Callback = function(value)
        workspace.Gravity = value
    end,
})
Movement:CreateButton({Name = "Reset Walkspeed", Callback = function() Humanoid.WalkSpeed = defaultWalkSpeed end})
Movement:CreateButton({Name = "Reset Jump Power", Callback = function() Humanoid.JumpPower = defaultJumpPower end})
Movement:CreateButton({
    Name = "Reset Gravity",
    Callback = function()
        workspace.Gravity = defaultGravity
    end,
})

Movement:CreateSection("Player")

Movement:CreateToggle({
    Name = "Platforms (F)",
    CurrentValue = false,
    Callback = function(enabled)
        local connection

        if enabled then
            connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.KeyCode == Enum.KeyCode.F then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local part = Instance.new("Part")
                        part.Anchored = true
                        part.Size = Vector3.new(6, 1, 6)
                        part.Position = char.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                        part.Color = Color3.new(0, 0, 0)
                        part.Material = Enum.Material.SmoothPlastic
                        part.Parent = workspace

                        task.delay(3, function()
                            if part then
                                part:Destroy()
                            end
                        end)
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
            end
        end
    end
})

Movement:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.noclip = game:GetService("RunService").Stepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if _G.noclip then
                _G.noclip:Disconnect()
            end
        end
    end
})

Movement:CreateToggle({
    Name = "Swim",
    CurrentValue = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local uis = game:GetService("UserInputService")

        if state then
            if not swimming and humanoid then
                oldgrav = workspace.Gravity
                workspace.Gravity = 0
                local function swimDied()
                    workspace.Gravity = oldgrav
                    swimming = false
                end
                gravReset = humanoid.Died:Connect(swimDied)
                local enums = Enum.HumanoidStateType:GetEnumItems()
                table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
                for _, v in pairs(enums) do
                    humanoid:SetStateEnabled(v, false)
                end
                humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                swimbeat = game:GetService("RunService").Heartbeat:Connect(function()
                    pcall(function()
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Velocity = ((humanoid.MoveDirection ~= Vector3.new() or uis:IsKeyDown(Enum.KeyCode.Space)) and root.Velocity or Vector3.new())
                        end
                    end)
                end)
                swimming = true
            end
        else
            if humanoid then
                workspace.Gravity = oldgrav
                swimming = false
                if gravReset then gravReset:Disconnect() end
                if swimbeat then swimbeat:Disconnect() swimbeat = nil end
                local enums = Enum.HumanoidStateType:GetEnumItems()
                table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
                for _, v in pairs(enums) do
                    humanoid:SetStateEnabled(v, true)
                end
            end
        end
    end
})

Movement:CreateToggle({
    Name = "Vehicle Fly",
    CurrentValue = false,
    Callback = function(state)
        local players = game:GetService("Players")
        local uis = game:GetService("UserInputService")
        local player = players.LocalPlayer
        local camera = workspace.CurrentCamera
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:WaitForChild("HumanoidRootPart")

        if state then
            vflyEnabled = true
            local control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            local lcontrol = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            local speed = 0
            local flySpeed = 1

            local gyro = Instance.new("BodyGyro")
            local vel = Instance.new("BodyVelocity")
            gyro.P = 9e4
            gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            gyro.CFrame = root.CFrame
            gyro.Parent = root
            vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            vel.Parent = root

            vflyKeyDown = uis.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.W then control.F = flySpeed end
                if input.KeyCode == Enum.KeyCode.S then control.B = -flySpeed end
                if input.KeyCode == Enum.KeyCode.A then control.L = -flySpeed end
                if input.KeyCode == Enum.KeyCode.D then control.R = flySpeed end
                if input.KeyCode == Enum.KeyCode.E then control.Q = flySpeed * 2 end
                if input.KeyCode == Enum.KeyCode.Q then control.E = -flySpeed * 2 end
                pcall(function() camera.CameraType = Enum.CameraType.Track end)
            end)

            vflyKeyUp = uis.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.W then control.F = 0 end
                if input.KeyCode == Enum.KeyCode.S then control.B = 0 end
                if input.KeyCode == Enum.KeyCode.A then control.L = 0 end
                if input.KeyCode == Enum.KeyCode.D then control.R = 0 end
                if input.KeyCode == Enum.KeyCode.E then control.Q = 0 end
                if input.KeyCode == Enum.KeyCode.Q then control.E = 0 end
            end)

            task.spawn(function()
                repeat task.wait()
                    if (control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0 then
                        speed = 50
                    elseif not ((control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0) and speed ~= 0 then
                        speed = 0
                    end
                    if (control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0 then
                        vel.Velocity = ((camera.CFrame.LookVector * (control.F + control.B)) + ((camera.CFrame * CFrame.new(control.L + control.R, (control.F + control.B + control.Q + control.E) * 0.2, 0).p) - camera.CFrame.p)) * speed
                        lcontrol = {F = control.F, B = control.B, L = control.L, R = control.R}
                    elseif speed ~= 0 then
                        vel.Velocity = ((camera.CFrame.LookVector * (lcontrol.F + lcontrol.B)) + ((camera.CFrame * CFrame.new(lcontrol.L + lcontrol.R, (lcontrol.F + lcontrol.B + control.Q + control.E) * 0.2, 0).p) - camera.CFrame.p)) * speed
                    else
                        vel.Velocity = Vector3.zero
                    end
                    gyro.CFrame = camera.CFrame
                until not vflyEnabled
                control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                lcontrol = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                speed = 0
                gyro:Destroy()
                vel:Destroy()
                if humanoid then humanoid.PlatformStand = false end
            end)
        else
            vflyEnabled = false
            if vflyKeyDown then vflyKeyDown:Disconnect() end
            if vflyKeyUp then vflyKeyUp:Disconnect() end
            pcall(function() camera.CameraType = Enum.CameraType.Custom end)
            if humanoid then humanoid.PlatformStand = false end
        end
    end
})

Movement:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        local uis = game:GetService("UserInputService")
        local cam = workspace.CurrentCamera

        if state then
            flying = true
            hum.PlatformStand = true
            flyConn = game:GetService("RunService").RenderStepped:Connect(function()
                local moveDir = Vector3.zero
                if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                if moveDir.Magnitude > 0 then
                    hrp.Velocity = moveDir.Unit * speed
                else
                    hrp.Velocity = Vector3.zero
                end
            end)
        else
            flying = false
            if flyConn then flyConn:Disconnect() end
            hum.PlatformStand = false
            hrp.Velocity = Vector3.zero
        end
    end
})

Movement:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.bhop = true
            task.spawn(function()
                while _G.bhop do
                    local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if h and h.FloorMaterial ~= Enum.Material.Air then
                        h:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    task.wait(0.1)
                end
            end)
        else
            _G.bhop = false
        end
    end
})

Movement:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
                end
            end)
        else
            if _G.infJumpConn then
                _G.infJumpConn:Disconnect()
                _G.infJumpConn = nil
            end
        end
    end
})

Movement:CreateSection("CFrame")

Movement:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local head = char:WaitForChild("Head")

        if state then
            humanoid.PlatformStand = true
            head.Anchored = true
            CFloop = game:GetService("RunService").Heartbeat:Connect(function(dt)
                local moveDirection = humanoid.MoveDirection * (CFspeed * dt)
                local camera = workspace.CurrentCamera
                local cameraCFrame = camera.CFrame
                local cameraOffset = head.CFrame:ToObjectSpace(cameraCFrame).Position
                cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
                local cameraPosition = cameraCFrame.Position
                local headPosition = head.CFrame.Position
                local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
                head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
            end)
        else
            if CFloop then CFloop:Disconnect() end
            humanoid.PlatformStand = false
            head.Anchored = false
        end
    end
})

local Cheats = Window:CreateTab("🎯 Cheats")
Cheats:CreateSection("Aimbot")
Cheats:CreateToggle({
    Name = "Aimbot [RIGHT CLICK]",
    CurrentValue = false,
    Callback = function(state)
        aimbotRightClick = state
        if state then aimbotEnabled = false end
        toggleAimbot(state or aimbotEnabled)
    end
})

Cheats:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(state)
        aimbotEnabled = state
        if state then aimbotRightClick = false end
        toggleAimbot(state or aimbotRightClick)
    end
})

Cheats:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(state)
        wallCheck = state
    end
})

Cheats:CreateToggle({
    Name = "Team Check",
    CurrentValue = teamCheck,
    Callback = function(state)
        teamCheck = state
    end
})

Cheats:CreateSection("FOV")

Cheats:CreateSlider({
    Name = "FOV Amount",
    Range = {1, 120},
    Increment = 1,
    CurrentValue = defaultFOV,
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})
Cheats:CreateButton({
    Name = "Reset FOV",
    Callback = function()
        workspace.CurrentCamera.FieldOfView = defaultFOV
    end
})

local Chat = Window:CreateTab("💬 Chat")

Chat:CreateInput({
    Name = "text input",
    PlaceholderText = "Hello fella",
    Callback = function(text)
        chatInput = text
    end,
})

Chat:CreateButton({
    Name = "send message",
    Callback = function()
        chatEnabled = true
        if chatConnection then
            chatConnection:Disconnect()
            chatConnection = nil
        end
        chatConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if chatInput ~= "" then
                if not isLegacyChat then
                    TextChatService.TextChannels.RBXGeneral:SendAsync(chatInput)
                else
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(chatInput, "All")
                end
            end
            chatConnection:Disconnect()
            chatConnection = nil
        end)
    end,
})

local Games = Window:CreateTab("🎲 Games")
Games:CreateSection("Longest Answer Wins")
Games:CreateToggle({
    Name = "Auto Answer",
    CurrentValue = false,
    Callback = function(state)
        AnswersSent = state
        task.spawn(function()
            while AnswersSent do
                submitAnswers()
                task.wait(0)
            end
        end)
    end
})

Games:CreateSection("Steal a Brainrot")
Games:CreateToggle({
    Name = "Anti Knockback",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.antiKnockbackConn = game:GetService("RunService").Heartbeat:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
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
        else
            if _G.antiKnockbackConn then
                _G.antiKnockbackConn:Disconnect()
                _G.antiKnockbackConn = nil
            end
        end
    end
})

Games:CreateSlider({
    Name = "Undetected Speed",
    Range = {0, 100},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 0,
    Callback = function(speed)
        if _G.antiKnockbackConn then
            _G.antiKnockbackConn:Disconnect()
            _G.antiKnockbackConn = nil
        end
        if speed > 0 then
            _G.antiKnockbackConn = game:GetService("RunService").Heartbeat:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
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

Games:CreateButton({Name = "Answer", Info = "Sends all answers", Callback = function() submitAnswers() end})

local Visual = Window:CreateTab("👀 Visual")

Visual:CreateToggle({
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
            _G.xrayActive = true
        else
            if _G.xrayActive then
                setTransparency(0)
                _G.xrayActive = false
            end
        end
    end
})

Visual:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Callback = function(enabled)
        local lighting = game.Lighting
        if enabled then
            _G.fpsBoostBackup = {
                GlobalShadows = lighting.GlobalShadows,
                Technology = lighting.Technology,
                PartSettings = {},
                Effects = {}
            }
            lighting.GlobalShadows = false
            lighting.Technology = Enum.Technology.Compatibility
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    _G.fpsBoostBackup.PartSettings[v] = v.Material
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("PostEffect") then
                    _G.fpsBoostBackup.Effects[v] = v.Enabled
                    v.Enabled = false
                end
            end
        else
            if _G.fpsBoostBackup then
                lighting.GlobalShadows = _G.fpsBoostBackup.GlobalShadows
                lighting.Technology = _G.fpsBoostBackup.Technology
                for v, mat in pairs(_G.fpsBoostBackup.PartSettings) do
                    if v and v.Parent then v.Material = mat end
                end
                for v, state in pairs(_G.fpsBoostBackup.Effects) do
                    if v and v.Parent then v.Enabled = state end
                end
                _G.fpsBoostBackup = nil
            end
        end
    end
})

Visual:CreateToggle({
    Name = "Hitbox Visualizer",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.hitboxVisualizer = game:GetService("RunService").RenderStepped:Connect(function()
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
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
            if _G.hitboxVisualizer then
                _G.hitboxVisualizer:Disconnect()
            end
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        local adorn = part:FindFirstChild("HitboxAdornment")
                        if adorn then
                            adorn:Destroy()
                        end
                    end
                end
            end
        end
    end
})

Visual:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        if espEnabled then
            espBoxes = {}
            espTexts = {}

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

            local function updateBoxes()
                for player, box in pairs(espBoxes) do
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        box.Adornee = hrp
                        box.Size = Vector3.new(hrp.Size.X, 5, hrp.Size.Z)
                        box.Parent = hrp
                    else
                        box:Destroy()
                        espBoxes[player] = nil
                    end
                end

                for player, tag in pairs(espTexts) do
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        tag.Adornee = hrp
                        tag.Parent = hrp
                    else
                        tag:Destroy()
                        espTexts[player] = nil
                    end
                end
            end

            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and not espBoxes[player] then
                        espBoxes[player] = createBox(hrp)
                        espTexts[player] = createNameTag(player, hrp)
                    end
                end
            end

            local runConnection
            runConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not espEnabled then
                    runConnection:Disconnect()
                    for _, box in pairs(espBoxes) do
                        box:Destroy()
                    end
                    for _, tag in pairs(espTexts) do
                        tag:Destroy()
                    end
                    espBoxes = {}
                    espTexts = {}
                    return
                end
                updateBoxes()
            end)

            game:GetService("Players").PlayerAdded:Connect(function(player)
                if espEnabled and player ~= game.Players.LocalPlayer then
                    player.CharacterAdded:Connect(function(char)
                        local hrp = char:WaitForChild("HumanoidRootPart", 5)
                        if hrp and espEnabled then
                            espBoxes[player] = createBox(hrp)
                            espTexts[player] = createNameTag(player, hrp)
                        end
                    end)
                end
            end)

            game:GetService("Players").PlayerRemoving:Connect(function(player)
                if espBoxes[player] then
                    espBoxes[player]:Destroy()
                    espBoxes[player] = nil
                end
                if espTexts[player] then
                    espTexts[player]:Destroy()
                    espTexts[player] = nil
                end
            end)
        else
            for _, box in pairs(espBoxes) do
                box:Destroy()
            end
            for _, tag in pairs(espTexts) do
                tag:Destroy()
            end
            espBoxes = {}
            espTexts = {}
        end
    end,
})

Visual:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.chamsHighlights = {}
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ChamsHighlight"
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character
                    table.insert(_G.chamsHighlights, highlight)
                end
            end
            _G.chamsConnection = game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ChamsHighlight"
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                    table.insert(_G.chamsHighlights, highlight)
                end)
            end)
        else
            if _G.chamsConnection then
                _G.chamsConnection:Disconnect()
                _G.chamsConnection = nil
            end
            if _G.chamsHighlights then
                for _, h in ipairs(_G.chamsHighlights) do
                    if h and h.Parent then
                        h:Destroy()
                    end
                end
                _G.chamsHighlights = nil
            end
        end
    end
})

Visual:CreateToggle({
    Name = "Bone ESP",
    CurrentValue = false,
    Callback = function(state)
        boneEspEnabled = state
        local RunService = game:GetService("RunService")
        local players = game:GetService("Players")

        if boneEspEnabled then
            boneEspLines = {}

            local function createLine(part0, part1)
                local line = Drawing.new("Line")
                line.Transparency = 1
                line.Color = Color3.new(1, 0, 0)
                line.Thickness = 2
                line.From = Vector2.new(0,0)
                line.To = Vector2.new(0,0)
                return line, part0, part1
            end

            local function get2DPos(position, camera)
                local pos, onScreen = camera:WorldToViewportPoint(position)
                if onScreen then
                    return Vector2.new(pos.X, pos.Y), true
                else
                    return Vector2.new(), false
                end
            end

            local camera = workspace.CurrentCamera

            local function update()
                for player, data in pairs(boneEspLines) do
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        for _, line in pairs(data.lines) do
                            line:Remove()
                        end
                        boneEspLines[player] = nil
                    end
                end

                for _, player in pairs(players:GetPlayers()) do
                    if player ~= players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local char = player.Character
                        local joints = {
                            {"Head", "UpperTorso"},
                            {"UpperTorso", "LowerTorso"},
                            {"LowerTorso", "LeftUpperLeg"},
                            {"LeftUpperLeg", "LeftLowerLeg"},
                            {"LeftLowerLeg", "LeftFoot"},
                            {"LowerTorso", "RightUpperLeg"},
                            {"RightUpperLeg", "RightLowerLeg"},
                            {"RightLowerLeg", "RightFoot"},
                            {"UpperTorso", "LeftUpperArm"},
                            {"LeftUpperArm", "LeftLowerArm"},
                            {"LeftLowerArm", "LeftHand"},
                            {"UpperTorso", "RightUpperArm"},
                            {"RightUpperArm", "RightLowerArm"},
                            {"RightLowerArm", "RightHand"},
                        }

                        if not boneEspLines[player] then
                            boneEspLines[player] = {lines = {}}
                            for _, joint in pairs(joints) do
                                local line, part0, part1 = createLine(joint[1], joint[2])
                                table.insert(boneEspLines[player].lines, line)
                            end
                        end

                        for i, joint in pairs(joints) do
                            local part0 = char:FindFirstChild(joint[1])
                            local part1 = char:FindFirstChild(joint[2])
                            local line = boneEspLines[player].lines[i]
                            if part0 and part1 then
                                local pos0, onScreen0 = get2DPos(part0.Position, camera)
                                local pos1, onScreen1 = get2DPos(part1.Position, camera)
                                if onScreen0 and onScreen1 then
                                    line.From = pos0
                                    line.To = pos1
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    elseif boneEspLines[player] then
                        for _, line in pairs(boneEspLines[player].lines) do
                            line:Remove()
                        end
                        boneEspLines[player] = nil
                    end
                end
            end

            boneEspConnection = RunService.RenderStepped:Connect(update)
        else
            if boneEspConnection then
                boneEspConnection:Disconnect()
                boneEspConnection = nil
            end
            if boneEspLines then
                for _, data in pairs(boneEspLines) do
                    for _, line in pairs(data.lines) do
                        line:Remove()
                    end
                end
                boneEspLines = nil
            end
        end
    end,
})

local Client = Window:CreateTab("💻 Client")

Client:CreateButton({
    Name = "Change Time of Day",
    Callback = function()
        game.Lighting.ClockTime = cycleTimes[currentIndex]
        currentIndex = currentIndex + 1
        if currentIndex > #cycleTimes then
            currentIndex = 1
        end
    end
})

Client:CreateToggle({
    Name = "Anti AFK Kick",
    CurrentValue = false,
    Callback = function(enabled)
        local vu = game:GetService("VirtualUser")
        if enabled then
            _G.afkConnection = game.Players.LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        else
            if _G.afkConnection then
                _G.afkConnection:Disconnect()
                _G.afkConnection = nil
            end
        end
    end
})

local OP = Window:CreateTab("🤫 OP")
OP:CreateSection("Player")

OP:CreateToggle({
    Name = "Anti Knockback",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.antiKnockbackConn = game:GetService("RunService").Heartbeat:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
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
        else
            if _G.antiKnockbackConn then
                _G.antiKnockbackConn:Disconnect()
                _G.antiKnockbackConn = nil
            end
        end
    end
})

OP:CreateSlider({
    Name = "Undetected Speed",
    Range = {0, 100},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 0,
    Callback = function(speed)
        if _G.antiKnockbackConn then
            _G.antiKnockbackConn:Disconnect()
            _G.antiKnockbackConn = nil
        end
        if speed > 0 then
            _G.antiKnockbackConn = game:GetService("RunService").Heartbeat:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
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

OP:CreateSection("Misc")
OP:CreateButton({Name = "Unsuspend VC", Info = "If VC banned, unsuspends your voice chat.", Callback = function() game:GetService("VoiceChatService"):joinVoice() end})

local Scripts = Window:CreateTab("📎 Scripts")

Scripts:CreateButton({Name = "Update Chroma", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Chroma.lua"))() end})
Scripts:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
