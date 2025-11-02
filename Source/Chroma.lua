local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Library.lua'))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaSignal
if ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents") and ReplicatedStorage.ReplicaRemoteEvents:FindFirstChild("Replica_ReplicaSignal") then
    ReplicaSignal = ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaSignal
end

local sendingAnswers = false
local delayTime = 1
local answers = {}

local function sendAllAnswers()
    if not ReplicaSignal then return end
    for _, answer in ipairs(answers) do
        local args = { [1] = 2, [2] = "Answer", [3] = answer }
        ReplicaSignal:FireServer(unpack(args))
    end
end

local Window = Library:CreateWindow({
   Name = "Chroma",
   LoadingTitle = "Open-sourced Roblox universal cheat.",
   LoadingSubtitle = "Licensed under GPLv3",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Chroma"
   },
   KeySystem = false,
})

local Voice = Window:CreateTab("VC")
Voice:CreateButton({
    Name = "Unsuspend VC",
    Info = "If VC banned, unsuspends your voice chat.",
    Callback = function()
        game:GetService("VoiceChatService"):joinVoice()
    end,
})

local Credits = Window:CreateTab("Credits")
Credits:CreateButton({
    Name = "AsteroidLord",
    Info = "Owner and Developer of Chroma",
    Callback = function() end,
})

local Games = Window:CreateTab("Games")
Games:CreateLabel("Type or Die")

Games:CreateToggle({
    Name = "Auto Answer",
    CurrentValue = false,
    Callback = function(state)
        sendingAnswers = state
        task.spawn(function()
            while sendingAnswers do
                sendAllAnswers()
                task.wait(delayTime)
            end
        end)
    end
})

Games:CreateButton({
    Name = "Answer",
    Info = "Sends a answer",
    Callback = function()
        sendAllAnswers()
    end,
})
