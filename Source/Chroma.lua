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
local Answers = {"treadmill","samsung","leopard","multiple","rectangle","americanfootball","wednesday","weddingdress","knife","Master bedroom","Cable stripping machine","Philip Sherman","The Great Wall of China","Michael Jordan","Girl With A Pearl Earring","Invincibility","Rectangular prism","Steering wheel","Daily dose of internet","Taking out the trash","scientific calculator","Tamago kake gohan","Amazon Prime Video","inflatable party decorations","Police Car","precious gemstone","sportswear","Air Conditioning","Flight Attendancy","Fire Extinguishers","red light green light","Physical Education","Sour Patch kids","hide and seek","Chocolate Chip Cookie Dough Ice Cream","Anna Sophia","Magdalena","Trinity","Patrick","explore the outdoors","Baby Princess Rosalina","Metallic Gasoline Blue Green","Playing with controlling toys","Malfunctioning Playstation Controller","Duke of Weselton","Waste","Buttercup","Granddaughter","Multipurpose Permanent Marker","Professional Development","Microwave Oven","Washing Machine","compression stockings","smoothie","Interactive whiteboard","Medium Density Fiberboard","Tent pole repair sleeve","International Space Station","Health Insurance","Burrowing Owl","Professional Racketball","Stand up Paddleboarding","Volcanic Eruption","Fairy Godmothers","Statistics and Probability","advanced interactive multidimensional modeling system","Identification Card","Limestone Egyptian Waterclock","Joystick controller","Baby Princess Rosalina","Chocolate Ice Cream Sandwich","Stand Up Paddleboarding","Mozzarella Cheese","Stand Up Paddleboarding","United States of America","Super Mario Brothers","Great White Shark","Pomegranate","Flat screen television","Wheel barrow","Centimeter","Dumbells","Christopher Robin","Sweet Potato","Cherry Blossom","Hippopotomonstrosesquippedaliophobia","Vitamin B12","gaming chair","Saxophone","Wisdom Teeth","Harley Quinn","Frozen Water Bottle","Hermit Crab","Galapagos tortoise","Mountain Everest","Macadamia Nuts","flower","rock","americancheese","steak","pig","angry","taylorswift","kreekcraft","refrigerator handle","Electric Bass Guitar","Rubber Duckie","German","colacola","apple","lemonade","toiletpaper","headphone","captainamerica","facebook","strawberry","mouth","television","united states of america","Construction","Condensed Milk","Cumulonimbus"}
local aimbotEnabled = false
local aimbotRightClick = false
local wallCheck = false
local teamCheck = false

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

local Voice = Window:CreateTab("VC")
Voice:CreateButton({Name = "Unsuspend VC", Info = "If VC banned, unsuspends your voice chat.", Callback = function() game:GetService("VoiceChatService"):joinVoice() end})

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
