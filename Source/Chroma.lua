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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaSignal
if ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents") and ReplicatedStorage.ReplicaRemoteEvents:FindFirstChild("Replica_ReplicaSignal") then
    ReplicaSignal = ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaSignal
end

-- welcome to the variable warehouse

local sendingAnswers = false
local delayTime = 1
local answers = {"treadmill","samsung","leopard","multiple","rectangle","americanfootball","wednesday","weddingdress","knife","Master bedroom","Cable stripping machine","Philip Sherman","The Great Wall of China","Michael Jordan","Girl With A Pearl Earring","Invincibility","Rectangular prism","Steering wheel","Daily dose of internet","Taking out the trash","scientific calculator","Tamago kake gohan","Amazon Prime Video","inflatable party decorations","Police Car","precious gemstone","sportswear","Air Conditioning","Flight Attendancy","Fire Extinguishers","red light green light","Physical Education","Sour Patch kids","hide and seek","Chocolate Chip Cookie Dough Ice Cream","Anna Sophia","Magdalena","Trinity","Patrick","explore the outdoors","Baby Princess Rosalina","Metallic Gasoline Blue Green","Playing with controlling toys","Malfunctioning Playstation Controller","Duke of Weselton","Waste","Buttercup","Granddaughter","Multipurpose Permanent Marker","Professional Development","Microwave Oven","Washing Machine","compression stockings","smoothie","Interactive whiteboard","Medium Density Fiberboard","Tent pole repair sleeve","International Space Station","Health Insurance","Burrowing Owl","Professional Racketball","Stand up Paddleboarding","Volcanic Eruption","Fairy Godmothers","Statistics and Probability","advanced interactive multidimensional modeling system","Identification Card","Limestone Egyptian Waterclock","Joystick controller","Baby Princess Rosalina","Chocolate Ice Cream Sandwich","Stand Up Paddleboarding","Mozzarella Cheese","Stand Up Paddleboarding","United States of America","Super Mario Brothers","Great White Shark","Pomegranate","Flat screen television","Wheel barrow","Centimeter","Dumbells","Christopher Robin","Sweet Potato","Cherry Blossom","Hippopotomonstrosesquippedaliophobia","Vitamin B12","gaming chair","Saxophone","Wisdom Teeth","Harley Quinn","Frozen Water Bottle","Hermit Crab","Galapagos tortoise","Mountain Everest","Macadamia Nuts","flower","rock","americancheese","steak","pig","angry","taylorswift","kreekcraft","refrigerator handle","Electric Bass Guitar","Rubber Duckie","German","colacola","apple","lemonade","toiletpaper","headphone","captainamerica","facebook","strawberry","mouth"}

local function sendAllAnswers()
    if not ReplicaSignal then return end
    for _, answer in ipairs(answers) do
        local args = { [1] = 2, [2] = "Answer", [3] = answer }
        ReplicaSignal:FireServer(unpack(args))
    end
end

-- no more warehouse

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
Games:CreateLabel("Longest Answer Wins")

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
    Name = "Answers",
    Info = "Sends all answers",
    Callback = function()
        sendAllAnswers()
    end
})

Games:CreateDropdown({
    Name = "Delay",
    Options = {"0", "1","2","3","4","5","6","7","8","9","10"},
    CurrentOption = "1",
    Callback = function(option)
        delayTime = tonumber(option)
    end
})
