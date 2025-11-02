--[
-- Chroma
--
-- A open-source Roblox Universal tool to tweak your gameplay to the max.
-- This code is licensed under the GNU General Public License (V3)
--
-- Have fun!
-- (Yes yes, some yes is GPT but only i'd say only 15/100 is GPT as I don't know much Lua.)
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

local Voice = Window:CreateTab("🤫 OP")
Voice:CreateButton({Name = "Unsuspend VC", Info = "If VC banned, unsuspends your voice chat.", Callback = function() game:GetService("VoiceChatService"):joinVoice() end})

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

local Misc = Window:CreateTab("📝 Misc")
Misc:CreateButton({
    Name = "Anti AFK",
    Info = "Prevents being kicked for idling",
    Callback = function()
        local y = (game:GetService("Players")).LocalPlayer
        local J = game:GetService("VirtualUser")
        if getconnections then
            for _, conn in ipairs(getconnections(y.Idled)) do
                if conn.Disable then
                    conn:Disable()
                else
                    conn:Disconnect()
                end
            end
        else
            task.spawn(function()
                while true do
                    J:CaptureController()
                    J:ClickButton2(Vector2.new())
                    task.wait(1)
                end
            end)
        end
    end
})

local Scripts = Window:CreateTab("📎 Scripts")

Scripts:CreateButton({Name = "Update Chroma", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Chroma.lua"))() end})
Scripts:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
