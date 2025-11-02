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

if not getgenv().chroma_boneesp then
    getgenv().chroma_boneesp = {
        enabled = false,
        playerLines = {},
        playerConns = {},
        playerCharConns = {},
        addedConn = nil,
        removedConn = nil
    }
end

local function removePlayerESP(plr)
    local data = getgenv().chroma_boneesp
    local lines = data.playerLines[plr]
    if lines then
        for _, line in ipairs(lines) do
            if line and line.Remove then
                pcall(function() line:Remove() end)
            end
        end
        data.playerLines[plr] = nil
    end
    if data.playerConns[plr] then
        pcall(function() data.playerConns[plr]:Disconnect() end)
        data.playerConns[plr] = nil
    end
    if data.playerCharConns[plr] then
        pcall(function() data.playerCharConns[plr]:Disconnect() end)
        data.playerCharConns[plr] = nil
    end
end

local function buildBonesForPlayer(plr)
    if not plr or not plr.Character then return end
    removePlayerESP(plr)
    local char = plr.Character
    local bones = char:FindFirstChild("UpperTorso") and 
        {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"} 
        or {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
    local lines = {}
    for i = 1, #bones - 1 do
        local p1 = char:FindFirstChild(bones[i])
        local p2 = char:FindFirstChild(bones[i+1])
        if p1 and p2 then
            local l = Drawing.new("Line")
            l.Color = Color3.fromRGB(255,0,0)
            l.Thickness = 2
            l.Transparency = 1
            l.Visible = false
            table.insert(lines, l)
        end
    end
    if #lines == 0 then
        for _, l in ipairs(lines) do pcall(function() l:Remove() end) end
        return
    end
    getgenv().chroma_boneesp.playerLines[plr] = {lines = lines, boneNames = bones}
    local cam = workspace.CurrentCamera
    local conn = RunService.RenderStepped:Connect(function()
        if not getgenv().chroma_boneesp.enabled then return end
        if not plr.Character then
            for _, l in ipairs(lines) do pcall(function() l.Visible = false end) end
            return
        end
        local validIndex = 1
        for i = 1, #bones - 1 do
            local p1 = plr.Character:FindFirstChild(bones[i])
            local p2 = plr.Character:FindFirstChild(bones[i+1])
            local line = lines[validIndex]
            if p1 and p2 and line then
                local a = cam:WorldToViewportPoint(p1.Position)
                local b = cam:WorldToViewportPoint(p2.Position)
                line.From = Vector2.new(a.X, a.Y)
                line.To = Vector2.new(b.X, b.Y)
                line.Visible = true
                validIndex = validIndex + 1
            elseif line then
                line.Visible = false
            end
        end
    end)
    getgenv().chroma_boneesp.playerConns[plr] = conn
    getgenv().chroma_boneesp.playerCharConns[plr] = plr.Character:WaitForChild("HumanoidRootPart").AncestryChanged:Connect(function()
        if not plr.Character then removePlayerESP(plr) end
    end)
end

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
Movement:CreateSlider({Name = "WalkSpeed", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.WalkSpeed, Callback = function(value) Humanoid.WalkSpeed = value end})
Movement:CreateSlider({Name = "Jump Power", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.JumpPower, Callback = function(value) Humanoid.JumpPower = value end})
Movement:CreateButton({Name = "Reset Walkspeed", Callback = function() Humanoid.WalkSpeed = defaultWalkSpeed end})
Movement:CreateButton({Name = "Reset Jump Power", Callback = function() Humanoid.JumpPower = defaultJumpPower end})

local Cheats = Window:CreateTab("🎯 Cheats")
Cheats:CreateLabel("Aimbot")
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

Cheats:CreateLabel("FOV")

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

local Games = Window:CreateTab("🎲 Games")
Games:CreateLabel("Longest Answer Wins")
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

Games:CreateButton({Name = "Answer", Info = "Sends all answers", Callback = function() submitAnswers() end})

local Visual = Window:CreateTab("👀 Visual")

Cheats:CreateToggle({
    Name = "Bone ESP",
    CurrentValue = false,
    Callback = function(state)
        local data = getgenv().chroma_boneesp
        data.enabled = state
        if state then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    spawn(function()
                        if plr.Character then
                            buildBonesForPlayer(plr)
                        else
                            data.playerCharConns[plr] = plr.CharacterAdded:Connect(function()
                                if data.enabled then buildBonesForPlayer(plr) end
                            end)
                        end
                    end)
                end
            end
            if not data.addedConn then
                data.addedConn = Players.PlayerAdded:Connect(function(plr)
                    if plr == LocalPlayer then return end
                    data.playerCharConns[plr] = plr.CharacterAdded:Connect(function()
                        if data.enabled then buildBonesForPlayer(plr) end
                    end)
                    if plr.Character and data.enabled then buildBonesForPlayer(plr) end
                end)
            end
            if not data.removedConn then
                data.removedConn = Players.PlayerRemoving:Connect(function(plr)
                    removePlayerESP(plr)
                end)
            end
        else
            if data.addedConn then pcall(function() data.addedConn:Disconnect() end) data.addedConn = nil end
            if data.removedConn then pcall(function() data.removedConn:Disconnect() end) data.removedConn = nil end
            for plr, _ in pairs(data.playerLines) do removePlayerESP(plr) end
            data.playerLines = {}
            data.playerConns = {}
            data.playerCharConns = {}
        end
    end
})

local Misc = Window:CreateTab("📝 Misc")
Misc:CreateButton({
    Name = "Placeholder",
    Callback = function()
        -- placeholder
    end
})

local OP = Window:CreateTab("🤫 OP")
OP:CreateButton({Name = "Unsuspend VC", Info = "If VC banned, unsuspends your voice chat.", Callback = function() game:GetService("VoiceChatService"):joinVoice() end})

local Scripts = Window:CreateTab("📎 Scripts")

Scripts:CreateButton({Name = "Update Chroma", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Chroma.lua"))() end})
Scripts:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
