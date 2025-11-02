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
local aimbotEnv

local function ensureAimbotLoaded()
    if getgenv().ExunysDeveloperAimbot then
        return getgenv().ExunysDeveloperAimbot
    end
end

local function applyDefaults(env)
    if not env then return end
    env.Settings.LockMode = 1
    env.Settings.AliveCheck = true
    env.Settings.TriggerKey = Enum.UserInputType.MouseButton2
    env.Settings.Toggle = false
    env.Settings.Enabled = false
end

aimbotEnv = ensureAimbotLoaded()
applyDefaults(aimbotEnv)

local rightClickToggle
local alwaysToggle

rightClickToggle = Cheats:CreateToggle({
    Name = "Aimbot [RIGHT CLICK]",
    CurrentValue = false,
    Callback = function(state)
        if state and alwaysToggle and alwaysToggle:GetState then alwaysToggle:SetState(false) end
        aimbotEnv = ensureAimbotLoaded()
        if not aimbotEnv then return end
        applyDefaults(aimbotEnv)
        aimbotEnv.Settings.Toggle = false
        aimbotEnv.Settings.TriggerKey = Enum.UserInputType.MouseButton2
        aimbotEnv.Settings.Enabled = state
        if state then aimbotEnv.Load() else aimbotEnv:Exit() end
    end,
})

alwaysToggle = Cheats:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(state)
        if state and rightClickToggle and rightClickToggle:GetState then rightClickToggle:SetState(false) end
        aimbotEnv = ensureAimbotLoaded()
        if not aimbotEnv then return end
        applyDefaults(aimbotEnv)
        aimbotEnv.Settings.Toggle = true
        aimbotEnv.Settings.Enabled = state
        if state then aimbotEnv.Load() else aimbotEnv:Exit() end
    end,
})

Cheats:CreateDropdown({
    Name = "Lock Part",
    Options = {"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"},
    CurrentOption = (aimbotEnv and aimbotEnv.Settings.LockPart) or "Head",
    Callback = function(option)
        aimbotEnv = ensureAimbotLoaded()
        if aimbotEnv then aimbotEnv.Settings.LockPart = option end
    end
})

Cheats:CreateToggle({
    Name = "Team Check",
    CurrentValue = (aimbotEnv and aimbotEnv.Settings.TeamCheck) or false,
    Callback = function(state)
        aimbotEnv = ensureAimbotLoaded()
        if aimbotEnv then aimbotEnv.Settings.TeamCheck = state end
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
