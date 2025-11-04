--[[
-- Chroma
--
-- A open-source Roblox Universal tool to tweak your gameplay to the max.
-- This code is licensed under the GNU General Public License (V3)
--
-- Have fun!
-- (Yes yes, some of this code is GPT but only i'd say only 15/100 is GPT as I don't know much Lua.)
-- (also, forgive me for how bad some of this is organized)
--
--]]

repeat task.wait() until game:IsLoaded() -- Simple but thank you to TRICK-HUBB/TrickHub for this
task.wait(0.3)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Library.lua'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local workspace = workspace
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = ReplicatedStorage
local ReplicaSignal
if ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents") and ReplicatedStorage.ReplicaRemoteEvents:FindFirstChild("Replica_ReplicaSignal") then
    ReplicaSignal = ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaSignal
end

local PlaceBlock = (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PlaceBlock")) -- this is for Voxels
local voxels = {}
local spawnedBlocks = {}
local circleRadius = 20

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
local aimbotEnabled = false
local aimbotRightClick = false
local wallCheck = false
local teamCheck = false
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
local showFovCircle = true

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

-- Back to the function warehouse

local function getClosestPlayer()
    local closestDist = math.hugelocal cam = Camera
    local target
    local localPlayer = game.Players.LocalPlayer
    local players = game.Players
    local teamCount = 0
    local playerTeams = {}
    for _, p in pairs(players:GetPlayers()) do
        if p.Team then 
            playerTeams[p.Team] = true
        end
    end
    for _ in pairs(playerTeams) do teamCount = teamCount + 1 end
    local ffa = (teamCount <= 1)
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if teamCheck and not ffa and plr.Team == localPlayer.Team then continue end
                if wallCheck then
                    local origin = workspace.CurrentCamera.CFrame.Position
                    local direction = (plr.Character.Head.Position - origin)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {localPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local raycast = workspace:Raycast(origin, direction, raycastParams)
                    if raycast and not raycast.Instance:IsDescendantOf(plr.Character) then continue end
                end
                local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
                local localRoot = localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head"))
                if root and localRoot then
                    local dist = (localRoot.Position - root.Position).Magnitude
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
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    if enable then
        aimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local UserInputService = game:GetService("UserInputService")
            local Camera = workspace.CurrentCamera
            local LocalPlayer = game.Players.LocalPlayer

            local target = getClosestPlayer()
            local mousePos = UserInputService:GetMouseLocation()
            fovCircle.Visible = fovCircleVisible and enable
            fovCircle.Position = mousePos
            fovCircle.Radius = 120

            if aimbotRightClick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
            if not target or not target.Character then return end

            local function partScreenInfo(part)
                local p = part
                if not p then return nil, false end
                local screenPos, onScreen = Camera:WorldToScreenPoint(p.Position)
                return Vector2.new(screenPos.X, screenPos.Y), onScreen
            end
            local chosenPart = nil
            local head = target.Character:FindFirstChild("Head")
            if head then
                local _, headOn = partScreenInfo(head)
                if headOn then
                    chosenPart = head
                end
            end

            if not chosenPart then
                local candidates = {
                    "HumanoidRootPart","UpperTorso","LowerTorso","Torso",
                    "RightUpperArm","LeftUpperArm","RightLowerArm","LeftLowerArm",
                    "RightUpperLeg","LeftUpperLeg","RightLowerLeg","LeftLowerLeg",
                    "RightArm","LeftArm","RightLeg","LeftLeg","Torso","UpperTorso"
                }
                local visibleParts = {}
                for _, name in ipairs(candidates) do
                    local p = target.Character:FindFirstChild(name)
                    if p and p:IsA("BasePart") then
                        local _, on = partScreenInfo(p)
                        if on then
                            table.insert(visibleParts, p)
                        end
                    end
                end
                if #visibleParts > 0 then
                    chosenPart = visibleParts[math.random(1, #visibleParts)]
                else
                    chosenPart = head or target.Character:FindFirstChild("HumanoidRootPart")
                end
            end

            if chosenPart and chosenPart:IsA("BasePart") then
                local cam = Camera
                cam.CFrame = CFrame.new(cam.CFrame.Position, chosenPart.Position)
            end
        end)
    end
end

--[[
local aimbotConnection
local function toggleAimbot(enable)
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    if enable then
        aimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local UserInputService = game:GetService("UserInputService")
            local Camera = workspace.CurrentCamera
            local LocalPlayer = game.Players.LocalPlayer
            local target = getClosestPlayer()
            local mousePos = UserInputService:GetMouseLocation()
            fovCircle.Visible = fovCircleVisible and enable
            fovCircle.Position = mousePos
            fovCircle.Radius = 120
            if aimbotRightClick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local cam = Camera
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
            end
        end)
    end
end

^^ Old aimbot system
--]]

local function submitAnswers()
    if not ReplicaSignal then return end
    for _, answer in ipairs(Answers) do
        ReplicaSignal:FireServer(2, "Answer", answer)
    end
end

-- Below is the Rayfield [Library reference] window creation

local Window = Library:CreateWindow({
   Name = "🟢 Chroma",
   LoadingTitle = "An open-sourced Roblox universal cheat.",
   LoadingSubtitle = "Licensed under GPLv3",
   Theme = "Ocean",
   ConfigurationSaving = {Enabled = true, FolderName = "ChromaConfigs", FileName = "Chroma"},
   KeySystem = false,
})


-- Below is all the spicy toggle stuff and categories, enjoy.

local Movement = Window:CreateTab("🎮 Movement")
Movement:CreateSection("Sliders")
Movement:CreateSlider({Name = "Walkspeed", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.WalkSpeed, Callback = function(value) Humanoid.WalkSpeed = value end})
Movement:CreateSlider({Name = "Jump Power", Range = {0,500}, Increment = 5, CurrentValue = Humanoid.JumpPower, Callback = function(value) Humanoid.JumpPower = value end})
Movement:CreateSlider({
    Name = "Gravity",
    Range = {0,500},
    Increment = 1,
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

Movement:CreateToggle({
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
    Name = "Noclip",
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
    Name = "Swim",
    CurrentValue = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local uis = game:GetService("UserInputService")

        if state then
            if not swimming and humanoid then
                oldgrav = workspace.Gravity
                workspace.Gravity = 0
                local function swimDied()
                    workspace.Gravity = oldgrav
                    swimming = false
                end
                gravReset = humanoid.Died:Connect(swimDied)
                local enums = Enum.HumanoidStateType:GetEnumItems()
                table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
                for _, v in pairs(enums) do
                    humanoid:SetStateEnabled(v, false)
                end
                humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                swimbeat = game:GetService("RunService").Heartbeat:Connect(function()
                    pcall(function()
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Velocity = ((humanoid.MoveDirection ~= Vector3.new() or uis:IsKeyDown(Enum.KeyCode.Space)) and root.Velocity or Vector3.new())
                        end
                    end)
                end)
                swimming = true
            end
        else
            if humanoid then
                workspace.Gravity = oldgrav
                swimming = false
                if gravReset then gravReset:Disconnect() end
                if swimbeat then swimbeat:Disconnect() swimbeat = nil end
                local enums = Enum.HumanoidStateType:GetEnumItems()
                table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
                for _, v in pairs(enums) do
                    humanoid:SetStateEnabled(v, true)
                end
            end
        end
    end
})

Movement:CreateToggle({
	Name = "Walk On Water",
	CurrentValue = false,
	Callback = function(state)
		local walkWater = state
		local conn
		local function set()
			local char = LocalPlayer.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local ray = Ray.new(hrp.Position, Vector3.new(0, -5, 0))
			local hit, pos = workspace:FindPartOnRay(ray, char)
			if hit and hit.Material == Enum.Material.Water then
				hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, pos.Y + 3, hrp.Position.Z))
			end
		end

		if state then
			conn = RunService.Heartbeat:Connect(function()
				if walkWater then
					set()
				end
			end)
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
	end
})

Movement:CreateToggle({
    Name = "Vehicle Fly",
    CurrentValue = false,
    Callback = function(state)
        local players = game:GetService("Players")
        local uis = game:GetService("UserInputService")
        local player = players.LocalPlayer
        local camera = workspace.CurrentCamera
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:WaitForChild("HumanoidRootPart")

        if state then
            vflyEnabled = true
            local control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            local lcontrol = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            local speed = 0
            local flySpeed = 1

            local gyro = Instance.new("BodyGyro")
            local vel = Instance.new("BodyVelocity")
            gyro.P = 9e4
            gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            gyro.CFrame = root.CFrame
            gyro.Parent = root
            vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            vel.Parent = root

            vflyKeyDown = uis.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.W then control.F = flySpeed end
                if input.KeyCode == Enum.KeyCode.S then control.B = -flySpeed end
                if input.KeyCode == Enum.KeyCode.A then control.L = -flySpeed end
                if input.KeyCode == Enum.KeyCode.D then control.R = flySpeed end
                if input.KeyCode == Enum.KeyCode.E then control.Q = flySpeed * 2 end
                if input.KeyCode == Enum.KeyCode.Q then control.E = -flySpeed * 2 end
                pcall(function() camera.CameraType = Enum.CameraType.Track end)
            end)

            vflyKeyUp = uis.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.W then control.F = 0 end
                if input.KeyCode == Enum.KeyCode.S then control.B = 0 end
                if input.KeyCode == Enum.KeyCode.A then control.L = 0 end
                if input.KeyCode == Enum.KeyCode.D then control.R = 0 end
                if input.KeyCode == Enum.KeyCode.E then control.Q = 0 end
                if input.KeyCode == Enum.KeyCode.Q then control.E = 0 end
            end)

            task.spawn(function()
                repeat task.wait()
                    if (control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0 then
                        speed = 50
                    elseif not ((control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0) and speed ~= 0 then
                        speed = 0
                    end
                    if (control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0 then
                        vel.Velocity = ((camera.CFrame.LookVector * (control.F + control.B)) + ((camera.CFrame * CFrame.new(control.L + control.R, (control.F + control.B + control.Q + control.E) * 0.2, 0).p) - camera.CFrame.p)) * speed
                        lcontrol = {F = control.F, B = control.B, L = control.L, R = control.R}
                    elseif speed ~= 0 then
                        vel.Velocity = ((camera.CFrame.LookVector * (lcontrol.F + lcontrol.B)) + ((camera.CFrame * CFrame.new(lcontrol.L + lcontrol.R, (lcontrol.F + lcontrol.B + control.Q + control.E) * 0.2, 0).p) - camera.CFrame.p)) * speed
                    else
                        vel.Velocity = Vector3.zero
                    end
                    gyro.CFrame = camera.CFrame
                until not vflyEnabled
                control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                lcontrol = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                speed = 0
                gyro:Destroy()
                vel:Destroy()
                if humanoid then humanoid.PlatformStand = false end
            end)
        else
            vflyEnabled = false
            if vflyKeyDown then vflyKeyDown:Disconnect() end
            if vflyKeyUp then vflyKeyUp:Disconnect() end
            pcall(function() camera.CameraType = Enum.CameraType.Custom end)
            if humanoid then humanoid.PlatformStand = false end
        end
    end
})

Movement:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        local uis = game:GetService("UserInputService")
        local cam = workspace.CurrentCamera

        if state then
            flying = true
            hum.PlatformStand = true
            flyConn = game:GetService("RunService").RenderStepped:Connect(function()
                local moveDir = Vector3.zero
                if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                if moveDir.Magnitude > 0 then
                    hrp.Velocity = moveDir.Unit * speed
                else
                    hrp.Velocity = Vector3.zero
                end
            end)
        else
            flying = false
            if flyConn then flyConn:Disconnect() end
            hum.PlatformStand = false
            hrp.Velocity = Vector3.zero
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

Movement:CreateSection("CFrame")

Movement:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local head = char:WaitForChild("Head")

        if state then
            humanoid.PlatformStand = true
            head.Anchored = true
            CFloop = game:GetService("RunService").Heartbeat:Connect(function(dt)
                local moveDirection = humanoid.MoveDirection * (CFspeed * dt)
                local camera = workspace.CurrentCamera
                local cameraCFrame = camera.CFrame
                local cameraOffset = head.CFrame:ToObjectSpace(cameraCFrame).Position
                cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
                local cameraPosition = cameraCFrame.Position
                local headPosition = head.CFrame.Position
                local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
                head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
            end)
        else
            if CFloop then CFloop:Disconnect() end
            humanoid.PlatformStand = false
            head.Anchored = false
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
    Name = "Show FOV Circle",
    CurrentValue = true,
    Callback = function(state)
        showFovCircle = state
        fovCircle.Visible = state and (aimbotEnabled or aimbotRightClick)
    end
})

Cheats:CreateSection("Aimbot - Checks")

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

Cheats:CreateSection("Shooter")

Cheats:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = false,
    Callback = function(state)
        if _G.triggerbotConnection then
            _G.triggerbotConnection:Disconnect()
            _G.triggerbotConnection = nil
        end

        if _G.hitboxConnections then
            for _, conn in ipairs(_G.hitboxConnections) do
                conn:Disconnect()
            end
            _G.hitboxConnections = nil
        end

        if _G.hitboxes then
            for _, box in ipairs(_G.hitboxes) do
                if box and box.Parent then box:Destroy() end
            end
            _G.hitboxes = nil
        end

        if state then
            local LocalPlayer = game.Players.LocalPlayer
            local Players = game.Players
            local RunService = game:GetService("RunService")
            local VirtualUser = game:GetService("VirtualUser")

            _G.hitboxes = {}
            _G.hitboxConnections = {}

            local function addHitbox(player)
                if not player.Character then return end
                if player.Character:FindFirstChild("HitboxBox") then return end
                local box = Instance.new("SelectionBox")
                box.Name = "HitboxBox"
                box.Adornee = player.Character
                box.LineThickness = 0.1
                box.SurfaceTransparency = 0.9
                box.Parent = player.Character
                table.insert(_G.hitboxes, box)
            end

            local function removeHitbox(player)
                if player.Character and player.Character:FindFirstChild("HitboxBox") then
                    player.Character.HitboxBox:Destroy()
                end
            end

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then addHitbox(p) end
            end

            table.insert(_G.hitboxConnections, Players.PlayerAdded:Connect(function(p)
                addHitbox(p)
            end))

            table.insert(_G.hitboxConnections, Players.PlayerRemoving:Connect(function(p)
                removeHitbox(p)
            end))

            local lastClick = 0
            _G.triggerbotConnection = RunService.RenderStepped:Connect(function()
                local now = tick()
                if now - lastClick < 0.15 then return end

                local mouse = LocalPlayer:GetMouse()
                local targetPart = mouse.Target
                if not targetPart then return end

                local targetPlayer = Players:GetPlayerFromCharacter(targetPart:FindFirstAncestorOfClass("Model"))
                if not targetPlayer or targetPlayer == LocalPlayer then return end
                local humanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end

                local teams = {}
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Team then teams[p.Team] = true end
                end
                local teamCount = 0
                for _ in pairs(teams) do teamCount += 1 end
                local ffa = (teamCount <= 1)
                if not ffa and targetPlayer.Team == LocalPlayer.Team then return end

                lastClick = now
                if type(mouse1click) == "function" then
                    pcall(mouse1click)
                else
                    pcall(function()
                        VirtualUser:Button1Down(Vector2.new(), workspace.CurrentCamera.CFrame)
                        task.wait(0.03)
                        VirtualUser:Button1Up(Vector2.new(), workspace.CurrentCamera.CFrame)
                    end)
                end
            end)
        end
    end
})

Cheats:CreateToggle({
    Name = "Aim Assist",
    CurrentValue = false,
    Callback = function(enabled)
        if _G._aimAssistConn then
            _G._aimAssistConn:Disconnect()
            _G._aimAssistConn = nil
        end
        if enabled then
            local strength = 0.08
            local fov = 80
            local maxPullDist = 40
            local requireRightClick = false

            local function getClosestToMouse()
                local closest, closestDist = nil, fov
                local mousePos = UserInputService:GetMouseLocation()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = plr
                            end
                        end
                    end
                end
                return closest, closestDist
            end

            _G._aimAssistConn = RunService.RenderStepped:Connect(function()
                if requireRightClick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
                local target, distance = getClosestToMouse()
                if not target or not target.Character then return end
                local head = target.Character:FindFirstChild("Head")
                if not head then return end
                if distance > maxPullDist then return end
				local dir = (head.Position - Camera.CFrame.Position).Unit
				local pullFactor = strength * (distance / maxPullDist)
				pullFactor = math.clamp(pullFactor, 0, strength)
				local newLook = Camera.CFrame.LookVector:Lerp(dir, pullFactor)
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
            end)
        end
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

Cheats:CreateSection("Misc")

Cheats:CreateToggle({
	Name = "Ultra Instincts",
	CurrentValue = false,
	Callback = function(state)
		local ultra = state
		local lteleport = 0
		local cooldown = 1.5
		local checkDist = 60
		local look = 0.985
		local conn
		local function teleport(center, radius, tries, dumb)
			for i = 1, tries do
				local rx = (math.random() * 2 - 1) * radius
				local rz = (math.random() * 2 - 1) * radius
				local candidate = Vector3.new(center.X + rx, center.Y + 50, center.Z + rz)
				local params = RaycastParams.new()
				params.FilterDescendantsInstances = dumb
				params.FilterType = Enum.RaycastFilterType.Blacklist
				local r = workspace:Raycast(candidate, Vector3.new(0, -200, 0), params)
				if r and r.Instance then
					local y = r.Position.Y + 3
					local final = Vector3.new(candidate.X, y, candidate.Z)
					local smallParams = RaycastParams.new()
					smallParams.FilterDescendantsInstances = dumb
					smallParams.FilterType = Enum.RaycastFilterType.Blacklist
					local check = workspace:Raycast(final, Vector3.new(0, -3, 0), smallParams)
					if check and check.Instance then
						return final
					end
				end
			end
			return nil
		end

		if state then
			if conn then conn:Disconnect() end
			conn = RunService.Heartbeat:Connect(function()
				if not ultra then return end
				local char = LocalPlayer.Character
				if not char then return end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				local now = tick()
				if now - lteleport < cooldown then return end
				for _, pl in pairs(Players:GetPlayers()) do
					if pl ~= LocalPlayer then
						local c = pl.Character
						if c then
							local head = c:FindFirstChild("Head")
							local hrp2 = c:FindFirstChild("HumanoidRootPart")
							if head and hrp2 then
								local toMe = hrp.Position - head.Position
								local dist = toMe.Magnitude
								if dist <= checkDist then
									local dirToMe = toMe.Unit
									local lookVec = head.CFrame.LookVector
									local dot = lookVec:Dot(dirToMe)
									if dot >= look then
										local dumb = {char, c}
										local dest = teleport(hrp.Position, 12, 10, dumb)
										if dest then
											hrp.CFrame = CFrame.new(dest)
											lteleport = now
											break
										end
									end
								end
							end
						end
					end
				end
			end)
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
	end
})

local Chat = Window:CreateTab("💬 Chat")

Chat:CreateInput({
    Name = "Text Input",
    PlaceholderText = "Hello fella",
    Callback = function(text)
        chatInput = text
    end,
})

Chat:CreateButton({
    Name = "Send Message",
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

Chat:CreateSection("Chat")

Chat:CreateButton({
    Name = "Show Chat",
    Callback = function()
        local chat = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Chat")
        if chat then chat.Enabled = true end
        local chatFrame = game:GetService("CoreGui"):FindFirstChild("Chat")
        if chatFrame then chatFrame.Enabled = true end
    end
})

Chat:CreateButton({
    Name = "Hide Chat",
    Callback = function()
        local chat = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Chat")
        if chat then chat.Enabled = false end
        local chatFrame = game:GetService("CoreGui"):FindFirstChild("Chat")
        if chatFrame then chatFrame.Enabled = false end
    end
})

local Games = Window:CreateTab("🎲 Games")
Games:CreateSection("Longest Answer Wins")

Games:CreateButton({Name = "Answer", Info = "Sends all answers", Callback = function() submitAnswers() end})

Games:CreateToggle({
    Name = "Auto Answer",
    CurrentValue = false,
    Callback = function(state)
        AnswersSent = state
        task.spawn(function()
            while AnswersSent do
                submitAnswers()
                task.wait(0.5)
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

if game.PlaceId == 127742093697776 then
Games:CreateSection("Plants vs Brainrots")

Games:CreateToggle({
	Name = "Auto Buy [BEST SEEDS]",
	CurrentValue = false,
	Callback = function(val)
		local running = val
		spawn(function()
			while running do
				for _, itemFrame in ipairs(seedsFrame:GetChildren()) do
					if itemFrame:IsA("Frame") and itemFrame:FindFirstChild("Stock") and string.match(itemFrame.Name,"Premium") then
						local amount = tonumber(itemFrame.Stock.Text:match("x(%d+)")) or 0
						for i = 1, amount do
							dataRemoteEvent:FireServer({itemFrame.Name, "\b"})
						end
					end
				end
				task.wait(1)
			end
		end)
	end
})

Games:CreateToggle({
	Name = "Auto Buy [BAD SEEDS]",
	CurrentValue = false,
	Callback = function(val)
		local running = val
		spawn(function()
			while running do
				for _, itemFrame in ipairs(seedsFrame:GetChildren()) do
					if itemFrame:IsA("Frame") and itemFrame:FindFirstChild("Stock") and not string.match(itemFrame.Name,"Premium") then
						local amount = tonumber(itemFrame.Stock.Text:match("x(%d+)")) or 0
						for i = 1, amount do
							dataRemoteEvent:FireServer({itemFrame.Name, "\b"})
						end
					end
				end
				task.wait(1)
			end
		end)
	end
})

Games:CreateToggle({
	Name = "Auto Buy [GEARS]",
	CurrentValue = false,
	Callback = function(val)
		local running = val
		spawn(function()
			while running do
				for _, itemFrame in ipairs(gearsFrame:GetChildren()) do
					if itemFrame:IsA("Frame") and itemFrame:FindFirstChild("Stock") then
						local amount = tonumber(itemFrame.Stock.Text:match("x(%d+)")) or 0
						for i = 1, amount do
							dataRemoteEvent:FireServer({itemFrame.Name, "\026"})
						end
					end
				end
				task.wait(1)
			end
		end)
	end
})

Games:CreateToggle({
	Name = "Auto Frost Grenade All",
	CurrentValue = false,
	Callback = function(val)
		local running = val
		spawn(function()
			while running do
				for _, brainrot in ipairs(Workspace.ScriptedMap.Brainrots:GetChildren()) do
					local progress = brainrot:GetAttribute("Progress") or 0
					if progress > 0.6 then
						local tool
						for _, container in ipairs({player.Character, player.Backpack}) do
							for _, item in ipairs(container:GetChildren()) do
								if item:IsA("Tool") and string.match(item.Name, "^%[x%d+%] Frost Grenade$") then
									tool = item
								end
							end
						end
						if tool then
							humanoid:EquipTool(tool)
							local bp = brainrot.PrimaryPart or brainrot:FindFirstChildWhichIsA("BasePart")
							if bp then
								useItemRemote:FireServer({{Toggle=true, Tool=tool, Time=0.5, Pos=bp.Position}})
							end
						end
					end
				end
				task.wait(2)
			end
		end)
	end
})
end

Games:CreateSlider({
	Name = "Circle Radius",
	Range = {5, 100},
	Default = 20,
	Callback = function(value)
		circleRadius = value
	end
})

Games:CreateToggle({
	Name = "Perfect Circle",
	CurrentValue = false,
	Callback = function(enabled)
		voxels.PerfectCircle = enabled
		spawn(function()
			local step = 3
			while voxels.PerfectCircle do
				local rootPos = pos().Position
				for x = -circleRadius, circleRadius, step do
					for z = -circleRadius, circleRadius, step do
						local offset = Vector3.new(x, 0, z)
						if offset.Magnitude <= circleRadius and offset.Magnitude >= circleRadius - step then
							PlaceBlock:FireServer(workspace["1Grass"], Enum.NormalId.Top, rootPos + offset, "Oak Planks")
						end
					end
				end
				task.wait(0.05)
			end
		end)
	end
})

Games:CreateToggle({
	Name = "Plank Spammer",
	CurrentValue = false,
	Callback = function(enabled)
		voxels.PlankSpammer = enabled
		spawn(function()
			while voxels.PlankSpammer do
				PlaceBlock:FireServer(workspace["1Grass"], Enum.NormalId.Top, pos().Position, "Oak Planks")
				task.wait(0.02)
			end
		end)
	end
})

Games:CreateToggle({
	Name = "Plank Tower",
	CurrentValue = false,
	Callback = function(enabled)
		voxels.PlankTower = enabled
		spawn(function()
			local yOffset = 0
			while voxels.PlankTower do
				PlaceBlock:FireServer(workspace["1Grass"], Enum.NormalId.Top, pos().Position + Vector3.new(0, yOffset, 0), "Oak Planks")
				yOffset = yOffset + 4
				task.wait(0.05)
			end
		end)
	end
})

Games:CreateToggle({
	Name = "Hollow Box",
	CurrentValue = false,
	Callback = function(enabled)
		voxels.HollowBox = enabled
		if not enabled then
			for _, blockPos in ipairs(spawnedBlocks) do
				PlaceBlock:FireServer(workspace["1Grass"], Enum.NormalId.Top, blockPos, "Air")
			end
			spawnedBlocks = {}
			return
		end
		spawn(function()
			local size = 20
			local step = 4
			while voxels.HollowBox do
				local rootPos = pos().Position
				for x = -size, size, step do
					for y = 0, size * 2, step do
						for z = -size, size, step do
							if x == -size or x == size or y == 0 or y == size*2 or z == -size or z == size then
								local blockPos = rootPos + Vector3.new(x, y, z)
								PlaceBlock:FireServer(workspace["1Grass"], Enum.NormalId.Top, blockPos, "Oak Planks")
								table.insert(spawnedBlocks, blockPos)
							end
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end
})

Games:CreateSection("Slap Battles")

Games:CreateButton({
	Name = "Get Badge Gloves [TRICKHUB]",
	Callback = function()
		local lobby = workspace:FindFirstChild("Lobby")
		if lobby then
			for _, part in ipairs(lobby:GetChildren()) do
				if part:IsA("BasePart") then
					print("Lobby object Z position:", part.CFrame.Z)
				end
			end
		else
			warn("Lobby not found in Workspace")
		end

		local networkFolder = game:GetService("ReplicatedStorage"):FindFirstChild("_NETWORK")
		if networkFolder and lobby then
			for _, obj in ipairs(networkFolder:GetChildren()) do
				for _, v in pairs(lobby:GetChildren()) do
					if obj:IsA("RemoteEvent") and v:IsA("MeshPart") then
						obj:FireServer(v.Name)
					else
						warn(obj.Name .. " is not a RemoteEvent or " .. v.Name .. " is not a MeshPart, skipping.")
					end
				end
			end
		else
			warn("_NETWORK folder not found in ReplicatedStorage or Lobby missing")
		end
	end
})

Games:CreateSection("a literal baseplate")

Games:CreateToggle({
	Name = "Anti Fling",
	CurrentValue = false,
	Callback = function(state)
		local enabled = state
		local function setCollision(c, collide)
			for _, part in pairs(c:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = collide
				end
			end
		end

		local conn
		if enabled then
			for _, pl in pairs(Players:GetPlayers()) do
				if pl ~= LocalPlayer and pl.Character then
					setCollision(pl.Character, false)
				end
			end
			conn = Players.PlayerAdded:Connect(function(pl)
				pl.CharacterAdded:Connect(function(c)
					if enabled then
						setCollision(c, false)
					end
				end)
			end)
		else
			for _, pl in pairs(Players:GetPlayers()) do
				if pl.Character then
					setCollision(pl.Character, true)
				end
			end
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
	end
})

Games:CreateSection("Da Hood")

Games:CreateButton({
    Name = "Show Chat",
    Callback = function()
        local chat = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Chat")
        if chat then chat.Enabled = true end
        local chatFrame = game:GetService("CoreGui"):FindFirstChild("Chat")
        if chatFrame then chatFrame.Enabled = true end
    end
})

Games:CreateButton({
    Name = "Hide Chat",
    Callback = function()
        local chat = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Chat")
        if chat then chat.Enabled = false end
        local chatFrame = game:GetService("CoreGui"):FindFirstChild("Chat")
        if chatFrame then chatFrame.Enabled = false end
    end
})

Games:CreateToggle({
	Name = "Ultra Instincts",
	CurrentValue = false,
	Callback = function(state)
		local ultra = state
		local lteleport = 0
		local cooldown = 1.5
		local checkDist = 60
		local look = 0.985
		local conn
		local function teleport(center, radius, tries, dumb)
			for i = 1, tries do
				local rx = (math.random() * 2 - 1) * radius
				local rz = (math.random() * 2 - 1) * radius
				local candidate = Vector3.new(center.X + rx, center.Y + 50, center.Z + rz)
				local params = RaycastParams.new()
				params.FilterDescendantsInstances = dumb
				params.FilterType = Enum.RaycastFilterType.Blacklist
				local r = workspace:Raycast(candidate, Vector3.new(0, -200, 0), params)
				if r and r.Instance then
					local y = r.Position.Y + 3
					local final = Vector3.new(candidate.X, y, candidate.Z)
					local smallParams = RaycastParams.new()
					smallParams.FilterDescendantsInstances = dumb
					smallParams.FilterType = Enum.RaycastFilterType.Blacklist
					local check = workspace:Raycast(final, Vector3.new(0, -3, 0), smallParams)
					if check and check.Instance then
						return final
					end
				end
			end
			return nil
		end

		if state then
			if conn then conn:Disconnect() end
			conn = RunService.Heartbeat:Connect(function()
				if not ultra then return end
				local char = LocalPlayer.Character
				if not char then return end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				local now = tick()
				if now - lteleport < cooldown then return end
				for _, pl in pairs(Players:GetPlayers()) do
					if pl ~= LocalPlayer then
						local c = pl.Character
						if c then
							local head = c:FindFirstChild("Head")
							local hrp2 = c:FindFirstChild("HumanoidRootPart")
							if head and hrp2 then
								local toMe = hrp.Position - head.Position
								local dist = toMe.Magnitude
								if dist <= checkDist then
									local dirToMe = toMe.Unit
									local lookVec = head.CFrame.LookVector
									local dot = lookVec:Dot(dirToMe)
									if dot >= look then
										local dumb = {char, c}
										local dest = teleport(hrp.Position, 12, 10, dumb)
										if dest then
											hrp.CFrame = CFrame.new(dest)
											lteleport = now
											break
										end
									end
								end
							end
						end
					end
				end
			end)
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
	end
})

local Visual = Window:CreateTab("👀 Visual")

Visual:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Callback = function(enabled)
        local function setTransparency(value)
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    v.LocalTransparencyModifier = value
                end
            end
        end
        if enabled then
            setTransparency(0.5)
            _G.xrayActive = true
        else
            if _G.xrayActive then
                setTransparency(0)
                _G.xrayActive = false
            end
        end
    end
})

Visual:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Callback = function(enabled)
        local lighting = game.Lighting
        if enabled then
            _G.fpsBoostBackup = {
                GlobalShadows = lighting.GlobalShadows,
                Technology = lighting.Technology,
                PartSettings = {},
                Effects = {}
            }
            lighting.GlobalShadows = false
            lighting.Technology = Enum.Technology.Compatibility
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    _G.fpsBoostBackup.PartSettings[v] = v.Material
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("PostEffect") then
                    _G.fpsBoostBackup.Effects[v] = v.Enabled
                    v.Enabled = false
                end
            end
        else
            if _G.fpsBoostBackup then
                lighting.GlobalShadows = _G.fpsBoostBackup.GlobalShadows
                lighting.Technology = _G.fpsBoostBackup.Technology
                for v, mat in pairs(_G.fpsBoostBackup.PartSettings) do
                    if v and v.Parent then v.Material = mat end
                end
                for v, state in pairs(_G.fpsBoostBackup.Effects) do
                    if v and v.Parent then v.Enabled = state end
                end
                _G.fpsBoostBackup = nil
            end
        end
    end
})

Visual:CreateToggle({
    Name = "Hitbox Visualizer",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.hitboxVisualizer = game:GetService("RunService").RenderStepped:Connect(function()
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if not part:FindFirstChild("HitboxAdornment") then
                                    local box = Instance.new("BoxHandleAdornment")
                                    box.Name = "HitboxAdornment"
                                    box.Adornee = part
                                    box.AlwaysOnTop = true
                                    box.ZIndex = 5
                                    box.Size = part.Size
                                    box.Color3 = Color3.new(1, 0, 0)
                                    box.Transparency = 0.7
                                    box.Parent = part
                                end
                            end
                        end
                    end
                end
            end)
        else
            if _G.hitboxVisualizer then
                _G.hitboxVisualizer:Disconnect()
            end
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        local adorn = part:FindFirstChild("HitboxAdornment")
                        if adorn then
                            adorn:Destroy()
                        end
                    end
                end
            end
        end
    end
})

Visual:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        if espEnabled then
            espBoxes = {}
            espTexts = {}

            local function createBox(part)
                local box = Instance.new("BoxHandleAdornment")
                box.Adornee = part
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Size = Vector3.new(part.Size.X, 5, part.Size.Z) 
                box.Color3 = Color3.new(1, 0, 0)
                box.Transparency = 0.5
                box.Parent = part
                return box
            end

            local function createNameTag(player, part)
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = part
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                billboard.Parent = part

                local textLabel = Instance.new("TextLabel")
                textLabel.BackgroundTransparency = 1
                textLabel.Text = player.Name
                textLabel.TextColor3 = Color3.new(1, 0, 0)
                textLabel.TextStrokeTransparency = 0.5
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextScaled = true
                textLabel.Parent = billboard

                return billboard
            end

            local function updateBoxes()
                for player, box in pairs(espBoxes) do
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        box.Adornee = hrp
                        box.Size = Vector3.new(hrp.Size.X, 5, hrp.Size.Z)
                        box.Parent = hrp
                    else
                        box:Destroy()
                        espBoxes[player] = nil
                    end
                end

                for player, tag in pairs(espTexts) do
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        tag.Adornee = hrp
                        tag.Parent = hrp
                    else
                        tag:Destroy()
                        espTexts[player] = nil
                    end
                end
            end

            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and not espBoxes[player] then
                        espBoxes[player] = createBox(hrp)
                        espTexts[player] = createNameTag(player, hrp)
                    end
                end
            end

            local runConnection
            runConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not espEnabled then
                    runConnection:Disconnect()
                    for _, box in pairs(espBoxes) do
                        box:Destroy()
                    end
                    for _, tag in pairs(espTexts) do
                        tag:Destroy()
                    end
                    espBoxes = {}
                    espTexts = {}
                    return
                end
                updateBoxes()
            end)

            game:GetService("Players").PlayerAdded:Connect(function(player)
                if espEnabled and player ~= game.Players.LocalPlayer then
                    player.CharacterAdded:Connect(function(char)
                        local hrp = char:WaitForChild("HumanoidRootPart", 5)
                        if hrp and espEnabled then
                            espBoxes[player] = createBox(hrp)
                            espTexts[player] = createNameTag(player, hrp)
                        end
                    end)
                end
            end)

            game:GetService("Players").PlayerRemoving:Connect(function(player)
                if espBoxes[player] then
                    espBoxes[player]:Destroy()
                    espBoxes[player] = nil
                end
                if espTexts[player] then
                    espTexts[player]:Destroy()
                    espTexts[player] = nil
                end
            end)
        else
            for _, box in pairs(espBoxes) do
                box:Destroy()
            end
            for _, tag in pairs(espTexts) do
                tag:Destroy()
            end
            espBoxes = {}
            espTexts = {}
        end
    end,
})

Visual:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            _G.chamsHighlights = {}
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ChamsHighlight"
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character
                    table.insert(_G.chamsHighlights, highlight)
                end
            end
            _G.chamsConnection = game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ChamsHighlight"
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                    table.insert(_G.chamsHighlights, highlight)
                end)
            end)
        else
            if _G.chamsConnection then
                _G.chamsConnection:Disconnect()
                _G.chamsConnection = nil
            end
            if _G.chamsHighlights then
                for _, h in ipairs(_G.chamsHighlights) do
                    if h and h.Parent then
                        h:Destroy()
                    end
                end
                _G.chamsHighlights = nil
            end
        end
    end
})

Visual:CreateToggle({
    Name = "Bone ESP",
    CurrentValue = false,
    Callback = function(state)
        boneEspEnabled = state
        local RunService = game:GetService("RunService")
        local players = game:GetService("Players")

        if boneEspEnabled then
            boneEspLines = {}

            local function createLine(part0, part1)
                local line = Drawing.new("Line")
                line.Transparency = 1
                line.Color = Color3.new(1, 0, 0)
                line.Thickness = 2
                line.From = Vector2.new(0,0)
                line.To = Vector2.new(0,0)
                return line, part0, part1
            end

            local function get2DPos(position, camera)
                local pos, onScreen = camera:WorldToViewportPoint(position)
                if onScreen then
                    return Vector2.new(pos.X, pos.Y), true
                else
                    return Vector2.new(), false
                end
            end

            local camera = workspace.CurrentCamera

            local function update()
                for player, data in pairs(boneEspLines) do
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        for _, line in pairs(data.lines) do
                            line:Remove()
                        end
                        boneEspLines[player] = nil
                    end
                end

                for _, player in pairs(players:GetPlayers()) do
                    if player ~= players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local char = player.Character
                        local joints = {
                            {"Head", "UpperTorso"},
                            {"UpperTorso", "LowerTorso"},
                            {"LowerTorso", "LeftUpperLeg"},
                            {"LeftUpperLeg", "LeftLowerLeg"},
                            {"LeftLowerLeg", "LeftFoot"},
                            {"LowerTorso", "RightUpperLeg"},
                            {"RightUpperLeg", "RightLowerLeg"},
                            {"RightLowerLeg", "RightFoot"},
                            {"UpperTorso", "LeftUpperArm"},
                            {"LeftUpperArm", "LeftLowerArm"},
                            {"LeftLowerArm", "LeftHand"},
                            {"UpperTorso", "RightUpperArm"},
                            {"RightUpperArm", "RightLowerArm"},
                            {"RightLowerArm", "RightHand"},
                        }

                        if not boneEspLines[player] then
                            boneEspLines[player] = {lines = {}}
                            for _, joint in pairs(joints) do
                                local line, part0, part1 = createLine(joint[1], joint[2])
                                table.insert(boneEspLines[player].lines, line)
                            end
                        end

                        for i, joint in pairs(joints) do
                            local part0 = char:FindFirstChild(joint[1])
                            local part1 = char:FindFirstChild(joint[2])
                            local line = boneEspLines[player].lines[i]
                            if part0 and part1 then
                                local pos0, onScreen0 = get2DPos(part0.Position, camera)
                                local pos1, onScreen1 = get2DPos(part1.Position, camera)
                                if onScreen0 and onScreen1 then
                                    line.From = pos0
                                    line.To = pos1
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    elseif boneEspLines[player] then
                        for _, line in pairs(boneEspLines[player].lines) do
                            line:Remove()
                        end
                        boneEspLines[player] = nil
                    end
                end
            end

            boneEspConnection = RunService.RenderStepped:Connect(update)
        else
            if boneEspConnection then
                boneEspConnection:Disconnect()
                boneEspConnection = nil
            end
            if boneEspLines then
                for _, data in pairs(boneEspLines) do
                    for _, line in pairs(data.lines) do
                        line:Remove()
                    end
                end
                boneEspLines = nil
            end
        end
    end,
})

local Client = Window:CreateTab("💻 Client")

Client:CreateButton({
    Name = "Change Time of Day",
    Callback = function()
        game.Lighting.ClockTime = cycleTimes[currentIndex]
        currentIndex = currentIndex + 1
        if currentIndex > #cycleTimes then
            currentIndex = 1
        end
    end
})

Client:CreateToggle({
    Name = "Anti AFK Kick",
    CurrentValue = false,
    Callback = function(enabled)
        local vu = game:GetService("VirtualUser")
        if enabled then
            _G.afkConnection = game.Players.LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        else
            if _G.afkConnection then
                _G.afkConnection:Disconnect()
                _G.afkConnection = nil
            end
        end
    end
})

Client:CreateSection("Other")

Client:CreateToggle({
	Name = "Player Collision",
	CurrentValue = false,
	Callback = function(state)
		local enabled = state
		local function setCollision(c, collide)
			for _, part in pairs(c:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = collide
				end
			end
		end

		local conn
		if enabled then
			for _, pl in pairs(Players:GetPlayers()) do
				if pl ~= LocalPlayer and pl.Character then
					setCollision(pl.Character, false)
				end
			end
			conn = Players.PlayerAdded:Connect(function(pl)
				pl.CharacterAdded:Connect(function(c)
					if enabled then
						setCollision(c, false)
					end
				end)
			end)
		else
			for _, pl in pairs(Players:GetPlayers()) do
				if pl.Character then
					setCollision(pl.Character, true)
				end
			end
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
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

OP:CreateToggle({ -- No clue if this works , highly doubt it does. If it does then it'll only work in games with shit anticheat.
	Name = "God Mode",
	CurrentValue = false,
	Callback = function(state)
		local god = state
		local conn
		if state then
			if conn then conn:Disconnect() end
			conn = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HealthChanged:Connect(function()
				if god then
					local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.Health = hum.MaxHealth
					end
				end
			end)
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
	end
})

OP:CreateToggle({ -- No clue if this works , highly doubt it does. If it does then it'll only work in games with shit anticheat.
	Name = "Auto Heal",
	CurrentValue = false,
	Callback = function(state)
		local autoHeal = state
		local conn
		if state then
			if conn then conn:Disconnect() end
			conn = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HealthChanged:Connect(function()
				if autoHeal then
					local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health < 30 then
						hum.Health = 100
					end
				end
			end)
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
	end
})

OP:CreateToggle({
	Name = "Walk On Water",
	CurrentValue = false,
	Callback = function(state)
		local walkWater = state
		local conn
		local function set()
			local char = LocalPlayer.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local ray = Ray.new(hrp.Position, Vector3.new(0, -5, 0))
			local hit, pos = workspace:FindPartOnRay(ray, char)
			if hit and hit.Material == Enum.Material.Water then
				hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, pos.Y + 3, hrp.Position.Z))
			end
		end

		if state then
			conn = RunService.Heartbeat:Connect(function()
				if walkWater then
					set()
				end
			end)
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end
	end
})

OP:CreateSection("Misc")
OP:CreateButton({Name = "Unsuspend VC", Info = "If VC banned, unsuspends your voice chat.", Callback = function() game:GetService("VoiceChatService"):joinVoice() end})

local Scripts = Window:CreateTab("📎 Scripts")

Scripts:CreateButton({Name = "Update Chroma", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Chroma.lua"))() end})
Scripts:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
