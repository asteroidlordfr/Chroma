--[
-- Chroma
--
-- A open-source Roblox Universal tool to tweak your gameplay to the max.
-- This code is licensed under the GNU General Public License (V3)
--
-- Have fun!
-- (Yes yes, some of this is GPT but only i'd say only 15/100 is GPT as I don't know much Lua.)
--]

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Library.lua'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaSignal
if ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents") and ReplicatedStorage.ReplicaRemoteEvents:FindFirstChild("Replica_ReplicaSignal") then
    ReplicaSignal = ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaSignal
end

local defaultWalkSpeed = 16
local defaultJumpPower = 50
local AnswersSent = false
local Answers = {"treadmill","samsung","leopard","multiple","rectangle","americanfootball","wednesday","weddingdress","knife"}
local aimbotEnabled = false
local aimbotRightClick = false
local lockPart = "Head"
local teamCheck = false

local function getClosestPlayer()
    local closestDist = math.huge
    local target
    local mouse = LocalPlayer:GetMouse()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(lockPart) then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if teamCheck and plr.Team == LocalPlayer.Team then continue end
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character[lockPart].Position)
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

local function aimbotStep()
    if not aimbotEnabled and not aimbotRightClick then return end
    if aimbotRightClick and not game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild(lockPart) then
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character[lockPart].Position)
    end
end

game:GetService("RunService").RenderStepped:Connect(aimbotStep)

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

local Movement = Window:CreateTab("Movement")
Movement:CreateSlider({Name = "WalkSpeed", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.WalkSpeed, Callback = function(value) Humanoid.WalkSpeed = value end})
Movement:CreateSlider({Name = "Jump Power", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.JumpPower, Callback = function(value) Humanoid.JumpPower = value end})
Movement:CreateButton({Name = "Reset Walkspeed", Callback = function() Humanoid.WalkSpeed = defaultWalkSpeed end})
Movement:CreateButton({Name = "Reset Jump Power", Callback = function() Humanoid.JumpPower = defaultJumpPower end})

local Cheats = Window:CreateTab("Cheats")

Cheats:CreateToggle({
    Name = "Aimbot [RIGHT CLICK]",
    CurrentValue = false,
    Callback = function(state)
        aimbotRightClick = state
        if state then aimbotEnabled = false end
    end
})

Cheats:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(state)
        aimbotEnabled = state
        if state then aimbotRightClick = false end
    end
})

Cheats:CreateDropdown({
    Name = "Lock Part",
    Options = {"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"},
    CurrentOption = lockPart,
    Callback = function(option)
        lockPart = option
    end
})

Cheats:CreateToggle({
    Name = "Team Check",
    CurrentValue = teamCheck,
    Callback = function(state)
        teamCheck = state
    end
})

local Voice = Window:CreateTab("VC")
Voice:CreateButton({Name = "Unsuspend VC", Info = "If VC banned, unsuspends your voice chat.", Callback = function() game:GetService("VoiceChatService"):joinVoice() end})

local Credits = Window:CreateTab("Credits")
Credits:CreateButton({Name = "AsteroidLord", Info = "Owner and Developer of Chroma", Callback = function() end})

local Games = Window:CreateTab("Games")
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
