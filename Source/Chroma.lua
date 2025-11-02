local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/refs/heads/main/Source/Rayfield.lua'))()

-- the variable (and function) warehouse

local ReplicaSignal = game:GetService("ReplicatedStorage"):WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")

local sendingAnswers = false
local randomizedSending = false
local delayTime = 1

local function sendAllAnswers()
    for _, answer in ipairs(answers) do
        local args = { [1] = 2, [2] = "Answer", [3] = answer }
        ReplicaSignal:FireServer(unpack(args))
    end
end

-- no more warehouse

local Window = Rayfield:CreateWindow({
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
   Callback = function()
   end,
})

local Games = Window:CreateTab("Games") 
Games:AddSection({
      Name = "Type or Die",
})

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
