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
local defaultGravity = workspace.Gravity or 196.2

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
    local mouse = LocalPlayer:GetMouse()
    local teamCount = 0
    local playerTeams = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Team then 
            playerTeams[p.Team] = true
        end
    end
    for _ in pairs(playerTeams) do teamCount = teamCount + 1 end
    local ffa = (teamCount <= 1)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if teamCheck and not ffa and plr.Team == LocalPlayer.Team then continue end
                if wallCheck then
                    local origin = workspace.CurrentCamera.CFrame.Position
                    local direction = (plr.Character.Head.Position - origin)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local raycast = workspace:Raycast(origin, direction, raycastParams)
                    if raycast and not raycast.Instance:IsDescendantOf(plr.Character) then continue end
                end
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
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
    Min = 0,
    Max = 500,
    Increment = 1,
    Suffix = "gravity",
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

PlayerTab:CreateToggle({
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
    Name = "noclip",
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



local Misc = Window:CreateTab("📝 Misc")
Misc:CreateButton({
    Name = "Placeholder",
    Callback = function()
        -- placeholder
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
