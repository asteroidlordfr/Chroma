local PlaceBlock = (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PlaceBlock")) -- this is for Voxels
local voxels = {}

local blockTypes = {"Oak Planks", "Bricks", "Dirt", "Cobblestone", "Oak Log", "Oak Leaves", "Glass", "Stone", "Yellow Wool"}
local spawnedBlocks = {
	PerfectCircle = {},
	PlankSpammer = {},
	PlankTower = {}
}
local activeThreads = {}

-- Below is some Slap Battles stuff

if game.PlaceId == 6403373529 then
local slapDelay = 0.2
local currentTarget
local running = false
local farmConn, speedConn, slapConn, slapLoop
local Reach = 13

gloveHits = {
    ["Default"] = game.ReplicatedStorage.b,
    ["Extended"] = game.ReplicatedStorage.b,
    ["T H I C K"] = game.ReplicatedStorage.GeneralHit,
    ["Squid"] = game.ReplicatedStorage.GeneralHit,
    ["Gummy"] = game.ReplicatedStorage.GeneralHit,
    ["RNG"] = game.ReplicatedStorage.GeneralHit,
    ["Tycoon"] = game.ReplicatedStorage.GeneralHit,
    ["Charge"] = game.ReplicatedStorage.GeneralHit,
    ["Baller"] = game.ReplicatedStorage.GeneralHit,
    ["Tableflip"] = game.ReplicatedStorage.GeneralHit,
    ["Booster"] = game.ReplicatedStorage.GeneralHit,
    ["Shield"] = game.ReplicatedStorage.GeneralHit,
    ["Track"] = game.ReplicatedStorage.GeneralHit,
    ["Goofy"] = game.ReplicatedStorage.GeneralHit,
    ["Confusion"] = game.ReplicatedStorage.GeneralHit,
    ["Elude"] = game.ReplicatedStorage.GeneralHit,
    ["Glitch"] = game.ReplicatedStorage.GeneralHit,
    ["Snowball"] = game.ReplicatedStorage.GeneralHit,
    ["fish"] = game.ReplicatedStorage.GeneralHit,
    ["Killerfish"] = game.ReplicatedStorage.GeneralHit,
    ["🗿"] = game.ReplicatedStorage.GeneralHit,
    ["Obby"] = game.ReplicatedStorage.GeneralHit,
    ["Voodoo"] = game.ReplicatedStorage.GeneralHit,
    ["Leash"] = game.ReplicatedStorage.GeneralHit,
    ["Flamarang"] = game.ReplicatedStorage.GeneralHit,
    ["Berserk"] = game.ReplicatedStorage.GeneralHit,
    ["Quake"] = game.ReplicatedStorage.GeneralHit,
    ["Rattlebones"] = game.ReplicatedStorage.GeneralHit,
    ["Chain"] = game.ReplicatedStorage.GeneralHit,
    ["Ping Pong"] = game.ReplicatedStorage.GeneralHit,
    ["Whirlwind"] = game.ReplicatedStorage.GeneralHit,
    ["Slicer"] = game.ReplicatedStorage.GeneralHit,
    ["Counter"] = game.ReplicatedStorage.GeneralHit,
    ["Hammer"] = game.ReplicatedStorage.GeneralHit,
    ["Excavator"] = game.ReplicatedStorage.GeneralHit,
    ["Home Run"] = game.ReplicatedStorage.GeneralHit,
    ["Psycho"] = game.ReplicatedStorage.GeneralHit,
    ["Kraken"] = game.ReplicatedStorage.GeneralHit,
    ["Gravity"] = game.ReplicatedStorage.GeneralHit,
    ["Lure"] = game.ReplicatedStorage.GeneralHit,
    ["Jebaited"] = game.ReplicatedStorage.GeneralHit,
    ["Meteor"] = game.ReplicatedStorage.GeneralHit,
    ["Tinkerer"] = game.ReplicatedStorage.GeneralHit,
    ["Guardian Angel"] = game.ReplicatedStorage.GeneralHit,
    ["Sun"] = game.ReplicatedStorage.GeneralHit,
    ["Necromancer"] = game.ReplicatedStorage.GeneralHit,
    ["Zombie"] = game.ReplicatedStorage.GeneralHit,
    ["Dual"] = game.ReplicatedStorage.GeneralHit,
    ["Alchemist"] = game.ReplicatedStorage.GeneralHit,
    ["Parry"] = game.ReplicatedStorage.GeneralHit,
    ["Druid"] = game.ReplicatedStorage.GeneralHit,
    ["Oven"] = game.ReplicatedStorage.GeneralHit,
    ["Jester"] = game.ReplicatedStorage.GeneralHit,
    ["Ferryman"] = game.ReplicatedStorage.GeneralHit,
    ["Scythe"] = game.ReplicatedStorage.GeneralHit,
    ["Blackhole"] = game.ReplicatedStorage.GeneralHit,
    ["Santa"] = game.ReplicatedStorage.GeneralHit,
    ["Grapple"] = game.ReplicatedStorage.GeneralHit,
    ["Iceskate"] = game.ReplicatedStorage.GeneralHit,
    ["Pan"] = game.ReplicatedStorage.GeneralHit,
    ["Blasphemy"] = game.ReplicatedStorage.GeneralHit,
    ["Blink"] = game.ReplicatedStorage.GeneralHit,
    ["Ultra Instinct"] = game.ReplicatedStorage.GeneralHit,
    ["Admin"] = game.ReplicatedStorage.GeneralHit,
    ["Prop"] = game.ReplicatedStorage.GeneralHit,
    ["Joust"] = game.ReplicatedStorage.GeneralHit,
    ["Slapstick"] = game.ReplicatedStorage.GeneralHit,
    ["Firework"] = game.ReplicatedStorage.GeneralHit,
    ["Run"] = game.ReplicatedStorage.GeneralHit,
    ["Beatdown"] = game.ReplicatedStorage.GeneralHit,
    ["L.O.L.B.O.M.B"] = game.ReplicatedStorage.GeneralHit,
    ["Glovel"] = game.ReplicatedStorage.GeneralHit,
    ["Chicken"] = game.ReplicatedStorage.GeneralHit,
    ["Divebomb"] = game.ReplicatedStorage.GeneralHit,
    ["Lamp"] = game.ReplicatedStorage.GeneralHit,
    ["Pocket"] = game.ReplicatedStorage.GeneralHit,
    ["BONK"] = game.ReplicatedStorage.GeneralHit,
    ["Knockoff"] = game.ReplicatedStorage.GeneralHit,
    ["Divert"] = game.ReplicatedStorage.GeneralHit,
    ["Frostbite"] = game.ReplicatedStorage.GeneralHit,
    ["Sbeve"] = game.ReplicatedStorage.GeneralHit,
    ["Plank"] = game.ReplicatedStorage.GeneralHit,
    ["Golem"] = game.ReplicatedStorage.GeneralHit,
    ["Spoonful"] = game.ReplicatedStorage.GeneralHit,
    ["Grab"] = game.ReplicatedStorage.GeneralHit,
    ["the schlop"] = game.ReplicatedStorage.GeneralHit,
    ["UFO"] = game.ReplicatedStorage.GeneralHit,
    ["el gato"] = game.ReplicatedStorage.GeneralHit,
    ["Siphon"] = game.ReplicatedStorage.GeneralHit,
    ["Hive"] = game.ReplicatedStorage.GeneralHit,
    ["Wrench"] = game.ReplicatedStorage.GeneralHit,
    ["Hunter"] = game.ReplicatedStorage.GeneralHit,
    ["Relude"] = game.ReplicatedStorage.GeneralHit,
    ["Avatar"] = game.ReplicatedStorage.GeneralHit,
    ["Demolition"] = game.ReplicatedStorage.GeneralHit,
    ["Shotgun"] = game.ReplicatedStorage.GeneralHit,
    ["Beachball"] = game.ReplicatedStorage.GeneralHit,
    ["ZZZZZZZ"] = game.ReplicatedStorage.ZZZZZZZHit,
    ["Brick"] = game.ReplicatedStorage.BrickHit,
    ["Snow"] = game.ReplicatedStorage.SnowHit,
    ["Pull"] = game.ReplicatedStorage.PullHit,
    ["Flash"] = game.ReplicatedStorage.FlashHit,
    ["Spring"] = game.ReplicatedStorage.springhit,
    ["Swapper"] = game.ReplicatedStorage.HitSwapper,
    ["Bull"] = game.ReplicatedStorage.BullHit,
    ["Dice"] = game.ReplicatedStorage.DiceHit,
    ["Ghost"] = game.ReplicatedStorage.GhostHit,
	
    ["Stun"] = game.ReplicatedStorage.HtStun,
    ["Za Hando"] = game.ReplicatedStorage.zhramt,
    ["Fort"] = game.ReplicatedStorage.Fort,
    ["Magnet"] = game.ReplicatedStorage.MagnetHIT,
    ["Pusher"] = game.ReplicatedStorage.PusherHit,
    ["Anchor"] = game.ReplicatedStorage.hitAnchor,
    ["Space"] = game.ReplicatedStorage.HtSpace,
    ["Boomerang"] = game.ReplicatedStorage.BoomerangH,
    ["Speedrun"] = game.ReplicatedStorage.Speedrunhit,
    ["Mail"] = game.ReplicatedStorage.MailHit,
    ["Golden"] = game.ReplicatedStorage.GoldenHit,
    ["MR"] = game.ReplicatedStorage.MisterHit,
    ["Reaper"] = game.ReplicatedStorage.ReaperHit,
    ["Replica"] = game.ReplicatedStorage.ReplicaHit,
    ["Defense"] = game.ReplicatedStorage.DefenseHit,
    ["Killstreak"] = game.ReplicatedStorage.KSHit,
    ["Reverse"] = game.ReplicatedStorage.ReverseHit,
    ["Shukuchi"] = game.ReplicatedStorage.ShukuchiHit,
    ["Duelist"] = game.ReplicatedStorage.DuelistHit,
    ["woah"] = game.ReplicatedStorage.woahHit,
    ["Ice"] = game.ReplicatedStorage.IceHit,
    ["Adios"] = game.ReplicatedStorage.hitAdios,
    ["Blocked"] = game.ReplicatedStorage.BlockedHit,
    ["Engineer"] = game.ReplicatedStorage.engiehit,
    ["Rocky"] = game.ReplicatedStorage.RockyHit,
    ["Conveyor"] = game.ReplicatedStorage.ConvHit,
    ["STOP"] = game.ReplicatedStorage.STOP,
    ["Phantom"] = game.ReplicatedStorage.PhantomHit,
    ["Wormhole"] = game.ReplicatedStorage.WormHit,
    ["Acrobat"] = game.ReplicatedStorage.AcHit,
    ["Plague"] = game.ReplicatedStorage.PlagueHit,
    ["[REDACTED]"] = game.ReplicatedStorage.ReHit,
    ["bus"] = game.ReplicatedStorage.hitbus,
    ["Phase"] = game.ReplicatedStorage.PhaseH,
    ["Warp"] = game.ReplicatedStorage.WarpHt,
    ["Bomb"] = game.ReplicatedStorage.BombHit,
    ["Bubble"] = game.ReplicatedStorage.BubbleHit,
    ["Jet"] = game.ReplicatedStorage.JetHit,
    ["Shard"] = game.ReplicatedStorage.ShardHIT,
    ["potato"] = game.ReplicatedStorage.potatohit,
    ["CULT"] = game.ReplicatedStorage.CULTHit,
    ["bob"] = game.ReplicatedStorage.bobhit,
    ["Buddies"] = game.ReplicatedStorage.buddiesHIT,
    ["Spy"] = game.ReplicatedStorage.SpyHit,
    ["Detonator"] = game.ReplicatedStorage.DetonatorHit,
    ["Rage"] = game.ReplicatedStorage.GRRRR,
    ["Trap"] = game.ReplicatedStorage.traphi,
    ["Orbit"] = game.ReplicatedStorage.Orbihit,
    ["Hybrid"] = game.ReplicatedStorage.HybridCLAP,
    ["Slapple"] = game.ReplicatedStorage.SlappleHit,
    ["Disarm"] = game.ReplicatedStorage.DisarmH,
    ["Dominance"] = game.ReplicatedStorage.DominanceHit,
    ["Link"] = game.ReplicatedStorage.LinkHit,
    ["Rojo"] = game.ReplicatedStorage.RojoHit,
    ["rob"] = game.ReplicatedStorage.robhit,
    ["Rhythm"] = game.ReplicatedStorage.rhythmhit,
    ["Nightmare"] = game.ReplicatedStorage.nightmarehit,
    ["Hitman"] = game.ReplicatedStorage.HitmanHit,
    ["Thor"] = game.ReplicatedStorage.ThorHit,
    ["Retro"] = game.ReplicatedStorage.RetroHit,
    ["Cloud"] = game.ReplicatedStorage.CloudHit,
    ["Null"] = game.ReplicatedStorage.NullHit,
    ["spin"] = game.ReplicatedStorage.spinhit,
    ["Kinetic"] = game.ReplicatedStorage.HtStun,
    ["Recall"] = game.ReplicatedStorage.HtStun,
    ["Balloony"] = game.ReplicatedStorage.HtStun,
    ["Sparky"] = game.ReplicatedStorage.HtStun,
    ["Boogie"] = game.ReplicatedStorage.HtStun,
    ["Coil"] = game.ReplicatedStorage.HtStun,
    ["Diamond"] = game.ReplicatedStorage.DiamondHit,
    ["Megarock"] = game.ReplicatedStorage.DiamondHit,
    ["Moon"] = game.ReplicatedStorage.CelestialHit,
    ["Jupiter"] = game.ReplicatedStorage.CelestialHit,
    ["Mitten"] = game.ReplicatedStorage.MittenHit,
    ["Hallow Jack"] = game.ReplicatedStorage.HallowHIT,
    ["OVERKILL"] = game.ReplicatedStorage.Overkillhit,
    ["The Flex"] = game.ReplicatedStorage.FlexHit,
    ["Custom"] = game.ReplicatedStorage.CustomHit,
    ["God's Hand"] = game.ReplicatedStorage.Godshand,
    ["Error"] = game.ReplicatedStorage.Errorhit
}
end

local function getNextTarget(prev)
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local root = char.HumanoidRootPart
	local closestDist = math.huge
	local target = nil

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p ~= prev and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("entered") then
			local hum = p.Character.Humanoid
			if hum.Health > 0 then
				local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
				if dist < closestDist and dist <= Reach then
					closestDist = dist
					target = p
				end
			end
		end
	end
	return target
end

local function slapTarget()
	local closestDist = math.huge
	local target = nil
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local root = char.HumanoidRootPart

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("entered") then
			local hum = p.Character.Humanoid
			if hum.Health > 0 then
				local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					target = p
				end
			end
		end
	end
	return target
end

-- Below is Plants vs Brainrots references (Kill me)

local player = game:GetService("Players").LocalPlayer
local humanoid = player.Character or player.CharacterAdded:Wait():WaitForChild("Humanoid")
if game.PlaceId == 127742093697776 then
    local seedsFrame = player.PlayerGui.Main.Seeds.Frame.ScrollingFrame
    local gearsFrame = player.PlayerGui.Main.Gears.Frame.ScrollingFrame
end
local Networking = game:GetService("ReplicatedStorage")
local dataRemoteEvent = (Networking:FindFirstChild("BridgeNet2") and Networking.BridgeNet2:FindFirstChild("dataRemoteEvent"))
local useItemRemote = (Networking:FindFirstChild("Remotes") and Networking.Remotes:FindFirstChild("UseItem"))

-- Below is the variable warehouse

local defaultWalkSpeed = 16
local defaultJumpPower = 50
local AnswersSent = false
local aimbotConnection
local aimbotEnabled = false
local aimbotRightClick = false
local teamCheck = true
local wallCheck = false
local fovCircleVisible = true
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
local aimbotConnection
local fovCircle = Drawing.new("Circle")
local fov = 120
local smoothing = 10

-- Below is the preset warehouse

fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(255,255,255)
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Filled = false

-- Below is the function warehouse

local function pos()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart") -- r15
	if not root then
		root = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") -- r6
	end
	return root
end

local function glitter()
	local char = game.Players.LocalPlayer.Character
	if char:FindFirstChild("HumanoidRootPart") then
		return char.HumanoidRootPart
	elseif char:FindFirstChild("Torso") then
		return char.Torso
	elseif char:FindFirstChild("UpperTorso") then
		return char.UpperTorso
	end
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

-- Some answers thing

Answers = loadAnswers("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Resources/LAW/Answers.txt")
loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/script.lua"))()

-- Back to the function warehouse

local function getGloveRemote()
	local gloveName = LocalPlayer.leaderstats.Glove.Value
	return gloveHits[gloveName] or gloveHits["Default"]
end

local function getClosestPlayer()
    local closestDist = math.huge
    local target
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return nil end
    local players = game.Players
    local playerTeams = {}

    for _, p in pairs(players:GetPlayers()) do
        if p.Team then
            playerTeams[p.Team] = true
        end
    end

    local teamCount = 0
    for _ in pairs(playerTeams) do
        teamCount = teamCount + 1
    end

    local ffa = (teamCount <= 1)

    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and type(humanoid.Health) == "number" and humanoid.Health > 0 then
                if teamCheck and not ffa and plr.Team == localPlayer.Team then
                    continue
                end
                if wallCheck then
                    local origin = workspace.CurrentCamera and workspace.CurrentCamera.CFrame and workspace.CurrentCamera.CFrame.Position or nil
                    if origin then
                        local direction = (plr.Character.Head.Position - origin)
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {localPlayer.Character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local raycast = workspace:Raycast(origin, direction, raycastParams)
                        if raycast and raycast.Instance and not raycast.Instance:IsDescendantOf(plr.Character) then
                            continue
                        end
                    end
                end
                local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
                local localRoot = localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head"))
                if root and localRoot and root:IsA("BasePart") and localRoot:IsA("BasePart") then
                    local dist = (localRoot.Position - root.Position).Magnitude
                    if type(dist) == "number" and type(closestDist) == "number" and dist < closestDist then
                        closestDist = dist
                        target = plr
                    end
                end
            end
        end
    end
    return target
end

local function getRandomTarget()
	local valid = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("entered") then
			table.insert(valid, p)
		end
	end
	if #valid > 0 then
		return valid[math.random(1, #valid)]
	end
end

local function toggleAimbot(enable)
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    if enable then
        aimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local UserInputService = game:GetService("UserInputService")
            local Camera = workspace.CurrentCamera
            local target = getClosestPlayer()
            local mousePos = UserInputService:GetMouseLocation()
            if fovCircle then
                if type(fovCircleVisible) == "boolean" then
                    fovCircle.Visible = fovCircleVisible and enable
                else
                    fovCircle.Visible = enable
                end
                if typeof(mousePos) == "Vector2" then
                    pcall(function() fovCircle.Position = mousePos end)
                end
                if type(fovCircle.Radius) == "number" then
                    fovCircle.Radius = 120
                end
            end
            if aimbotRightClick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
            if target and target.Character and target.Character:FindFirstChild("Head") and Camera and Camera.CFrame then
                local head = target.Character.Head
                if head and head:IsA("BasePart") then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                end
            end
        end)
    end
end

local function submitAnswers()
    if not ReplicaSignal then return end
    for _, answer in ipairs(Answers) do
        ReplicaSignal:FireServer(2, "Answer", answer)
    end
end
