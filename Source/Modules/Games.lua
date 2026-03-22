--[[

© Chroma, 2026
Yet another Universal script for Roblox.

Fully open-sourced, and free forever.
I don't really know if I plan on long term support for this project, but I review pull requests and would be glad to add some.

Enjoying the script? Star us on GitHub: github.com/asteroidlordfr/Chroma
                                        ^^ you can also read our source code, open pull requests, and issues.
Comments are placed as **DEV COMMENTS**, it is meant to explain parts of the code, credit contributors and other purposes.

--]]

return {
    Initialize = function(Core, Window)
        local GamesTab = Window:CreateTab("🎲 Games")
        local state = {
            ChatSpyEnabled = false, ballesp = false, autoupgrade = false, highlights = {},
            AutoAnswer = false, collecting = false, Realistic = false, autorebirth = false,
            autofarmtoggle = false, activeThreads = {}, voxels = {}, spawnedBlocks = {PerfectCircle = {}, PlankSpammer = {}, PlankTower = {}},
            AnswersSent = false
        }
        
        local PlaceBlock = (Core.ReplicatedStorage:FindFirstChild("Remotes") and Core.ReplicatedStorage.Remotes:FindFirstChild("PlaceBlock"))
        
        local ReplicaSignal
        if Core.ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents") and Core.ReplicatedStorage.ReplicaRemoteEvents:FindFirstChild("Replica_ReplicaSignal") then
            ReplicaSignal = Core.ReplicatedStorage.ReplicaRemoteEvents.Replica_ReplicaSignal
        end
        
        local Answers = {}
        local s, r = pcall(function()
            return Core.Utils.loadAnswers("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Resources/LAW/Answers.txt")
        end)
        if s and type(r) == "table" then
            Answers = r
        end
        
        local function submitAnswers()
            if not ReplicaSignal then return end
            if not Answers or type(Answers) ~= "table" then return end
            for _, answer in ipairs(Answers) do
                ReplicaSignal:FireServer(2, "Answer", answer)
            end
        end
        
        local function onChatted(player, message)
            if not state.ChatSpyEnabled then return end
            if player == Core.LocalPlayer then return end
            if Core.Utils.checkIgnored(message) then return end
            Core.Utils.notify("[SPY] - "..player.Name, message, 5)
        end
        
        for _, player in ipairs(Core.Players:GetPlayers()) do
            player.Chatted:Connect(function(msg) onChatted(player, msg) end)
        end
        
        Core.Players.PlayerAdded:Connect(function(player)
            player.Chatted:Connect(function(msg) onChatted(player, msg) end)
        end)
        
        Core.game.DescendantAdded:Connect(function(obj)
            if state.AutoAnswer and obj:IsA("Sound") then
                task.defer(function()
                    for attempt = 1, 10 do
                        if not state.AutoAnswer then return end
                        local soundId = obj.SoundId
                        local assetId = soundId and soundId:match("%d+")
                        if assetId then
                            local s, info = pcall(function()
                                return Core.MarketplaceService:GetProductInfo(tonumber(assetId))
                            end)
                            if s and info and info.Name then
                                local name = info.Name
                                name = name:match("^(.-)%s*%(%d+%)$") or name
                                if not state.AutoAnswer then return end
                                if state.Realistic then
                                    local build = ""
                                    for i = 1, #name do
                                        build = name:sub(1, i)
                                        ReplicaSignal:FireServer("Type", build)
                                        task.wait(0.05)
                                    end
                                    ReplicaSignal:FireServer("Submit", name)
                                else
                                    ReplicaSignal:FireServer("Type", name)
                                    task.wait(0.1)
                                    ReplicaSignal:FireServer("Submit", name)
                                end
                            end
                            break
                        end
                    end
                end)
            end
        end)
        
        GamesTab:CreateSection("Murder Mystery 2")
        
        GamesTab:CreateButton({
            Name = "Expose Roles",
            Callback = function()
                for _,player in pairs(Core.Players:GetPlayers()) do
                    if player ~= Core.LocalPlayer then
                        local backpack = player:FindFirstChild("Backpack")
                        local character = player.Character
                        local isMurderer = (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
                        local isSheriff = (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun"))
                        if isMurderer then Core.Utils.notify("roles", player.Name .. " is murderer", 3)
                        elseif isSheriff then Core.Utils.notify("roles", player.Name .. " is sheriff", 3) end
                    end
                end
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Kill All [LMB]", CurrentValue = false,
            Callback = function(Value)
                local active = Value
                local holding = false
                if not active then return end
                Core.UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        holding = true
                        task.spawn(function()
                            local start = tick()
                            while holding and tick() - start < 2 do
                                local myChar = Core.Utils.getCharacter()
                                if myChar and Core.Utils.getRootPart(myChar) then
                                    local myPos = Core.Utils.getRootPart(myChar).CFrame
                                    for _,plr in pairs(Core.Players:GetPlayers()) do
                                        if plr ~= Core.LocalPlayer then
                                            local char = plr.Character
                                            if char and Core.Utils.getRootPart(char) then
                                                Core.Utils.getRootPart(char).CFrame = myPos
                                            end
                                        end
                                    end
                                end
                                Core.RunService.RenderStepped:Wait()
                            end
                        end)
                    end
                end)
                Core.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end
                end)
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Role ESP", CurrentValue = false,
            Callback = function(Value)
                local Highlights = {}
                local Running = Value
                local function clearHighlight(player)
                    if Highlights[player] then Highlights[player]:Destroy() Highlights[player] = nil end
                end
                local function setHighlight(player,color)
                    if not player.Character then return end
                    clearHighlight(player)
                    local h = Instance.new("Highlight")
                    h.FillColor = color
                    h.OutlineColor = color
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee = player.Character
                    h.Parent = player.Character
                    Highlights[player] = h
                end
                task.spawn(function()
                    while Running do
                        for _,player in pairs(Core.Players:GetPlayers()) do
                            if player ~= Core.LocalPlayer then
                                local backpack = player:FindFirstChild("Backpack")
                                local character = player.Character
                                local isMurderer = (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
                                local isSheriff = (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun"))
                                if isMurderer then setHighlight(player,Color3.fromRGB(255,0,0))
                                elseif isSheriff then setHighlight(player,Color3.fromRGB(0,0,255))
                                else clearHighlight(player) end
                            end
                        end
                        task.wait(0.5)
                    end
                    for _,h in pairs(Highlights) do h:Destroy() end
                    Highlights = {}
                end)
            end
        })
        
        GamesTab:CreateSection("Ball Simulator")
        
        GamesTab:CreateButton({
            Name = "Admin Panel",
            Callback = function()
                local gui = Core.LocalPlayer:WaitForChild("PlayerGui")
                local pcui = gui:WaitForChild("PCUI")
                local main = pcui:WaitForChild("PCMainFrame")
                local admin = main:WaitForChild("ADMIN")
                admin.Visible = true
                admin.Active = true
                admin.AutoButtonColor = true
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Collect All Balls", CurrentValue = false,
            Callback = function(value)
                state.collecting = value
                if not state.collecting then return end
                task.spawn(function()
                    while state.collecting do
                        local char = Core.Utils.getCharacter()
                        local hrp = Core.Utils.getRootPart(char)
                        local spawnedBalls = Core.workspace:WaitForChild("SpawnedBalls")
                        for _, obj in ipairs(spawnedBalls:GetChildren()) do
                            if not state.collecting then break end
                            if obj:IsA("BasePart") then obj.CFrame = hrp.CFrame
                            elseif obj:IsA("Model") then
                                if obj.PrimaryPart then obj:SetPrimaryPartCFrame(hrp.CFrame)
                                else
                                    local part = obj:FindFirstChildWhichIsA("BasePart", true)
                                    if part then obj:PivotTo(hrp.CFrame) end
                                end
                            end
                            task.wait(0.05)
                        end
                        task.wait(0.2)
                    end
                end)
            end
        })
        
        GamesTab:CreateButton({
            Name = "Unlock All Zones",
            Callback = function()
                local zones = Core.workspace:FindFirstChild("Zones")
                if zones then
                    local unlockzones = zones:FindFirstChild("UnlockZones")
                    if unlockzones then unlockzones:Destroy() end
                end
                local zoneparts = Core.workspace:FindFirstChild("ZoneParts")
                if zoneparts then zoneparts:Destroy() end
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Ball ESP", CurrentValue = false,
            Callback = function(value)
                state.ballesp = value
                if not state.ballesp then
                    for _, h in pairs(state.highlights) do if h then h:Destroy() end end
                    table.clear(state.highlights)
                    return
                end
                local spawnedBalls = Core.workspace:WaitForChild("SpawnedBalls")
                local function addesp(obj)
                    if state.highlights[obj] then return end
                    local color
                    if obj:IsA("BasePart") then color = obj.Color
                    elseif obj:IsA("Model") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        if not part then return end
                        color = part.Color
                    else return end
                    local h = Instance.new("Highlight")
                    h.FillColor = color
                    h.OutlineColor = color
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee = obj
                    h.Parent = obj
                    state.highlights[obj] = h
                end
                for _, obj in ipairs(spawnedBalls:GetChildren()) do addesp(obj) end
                spawnedBalls.ChildAdded:Connect(function(obj) if state.ballesp then task.wait() addesp(obj) end end)
            end
        })
        
        GamesTab:CreateLabel("Auto")
        
        GamesTab:CreateToggle({
            Name = "Auto Rebirth", CurrentValue = false,
            Callback = function(value)
                state.autorebirth = value
                if not state.autorebirth then return end
                task.spawn(function()
                    local rebirth = Core.ReplicatedStorage:WaitForChild("Events"):WaitForChild("Rebirth")
                    while state.autorebirth do rebirth:FireServer() task.wait(0.5) end
                end)
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Auto Upgrade", CurrentValue = false,
            Callback = function(value)
                state.autoupgrade = value
                if not state.autoupgrade then return end
                task.spawn(function()
                    local upgrade = Core.ReplicatedStorage:WaitForChild("Events"):WaitForChild("Upgrade")
                    local gui = Core.LocalPlayer:WaitForChild("PlayerGui")
                    local pcui = gui:WaitForChild("PCUI")
                    local main = pcui:WaitForChild("PCMainFrame")
                    local upgradesbg = main:WaitForChild("UpgradesBackground")
                    local upgradenames = {}
                    for _, v in ipairs(upgradesbg:GetChildren()) do
                        if v:IsA("TextButton") and v.Name ~= "Close" and v.Name ~= "MaxBuy" then table.insert(upgradenames, v.Name) end
                    end
                    while state.autoupgrade do
                        for _, name in ipairs(upgradenames) do
                            if not state.autoupgrade then break end
                            upgrade:FireServer(name)
                            task.wait(0.05)
                        end
                        task.wait(0.2)
                    end
                end)
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Autofarm", CurrentValue = false,
            Callback = function(value)
                state.autofarmtoggle = value
                local autofarm = Core.ReplicatedStorage:WaitForChild("Events"):WaitForChild("Autofarm")
                if Core.MarketplaceService:UserOwnsGamePassAsync(Core.LocalPlayer.UserId, 1371011476) then
                    autofarm:FireServer(state.autofarmtoggle)
                else
                    state.autofarmtoggle = false
                    Core.MarketplaceService:PromptGamePassPurchase(Core.LocalPlayer, 1371011476)
                end
            end
        })
        
        GamesTab:CreateLabel("Gamepasses")
        
        GamesTab:CreateButton({
            Name = "Jeep",
            Callback = function()
                local char = Core.Utils.getCharacter()
                local hrp = Core.Utils.getRootPart(char)
                local assets = Core.ReplicatedStorage:WaitForChild("Assets")
                local jeep = assets:WaitForChild("JeepM"):Clone()
                jeep.Parent = Core.workspace
                local offset = hrp.CFrame.LookVector * 12
                local spawnCFrame = hrp.CFrame + offset
                if jeep:IsA("Model") then
                    if jeep.PrimaryPart then jeep:SetPrimaryPartCFrame(spawnCFrame)
                    else jeep:PivotTo(spawnCFrame) end
                elseif jeep:IsA("BasePart") then jeep.CFrame = spawnCFrame end
            end
        })
        
        GamesTab:CreateButton({
            Name = "Unlock VIP Zone",
            Callback = function()
                local zones = Core.workspace:FindFirstChild("Zones")
                if zones then
                    local unlockzones = zones:FindFirstChild("UnlockZones")
                    if unlockzones then unlockzones:Destroy() end
                end
                local zoneparts = Core.workspace:FindFirstChild("ZoneParts")
                if zoneparts then zoneparts:Destroy() end
            end
        })
        
        GamesTab:CreateSection("Longest Answer Wins")
        
        GamesTab:CreateButton({Name = "Answer", Info = "Sends all answers", Callback = function() submitAnswers() end})
        
        GamesTab:CreateToggle({
            Name = "Auto Answer", CurrentValue = false,
            Callback = function(stateVal)
                state.AnswersSent = stateVal
                task.spawn(function() while state.AnswersSent do submitAnswers() task.wait(0.5) end end)
            end
        })
        
        GamesTab:CreateSection("Steal a Brainrot")
        
        local antiKnockbackConn
        GamesTab:CreateToggle({
            Name = "Anti Knockback", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    antiKnockbackConn = Core.RunService.Heartbeat:Connect(function()
                        local char = Core.Utils.getCharacter()
                        if not char then return end
                        local root = Core.Utils.getRootPart(char)
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
                elseif antiKnockbackConn then antiKnockbackConn:Disconnect() antiKnockbackConn = nil end
            end
        })
        
        GamesTab:CreateSlider({
            Name = "Undetected Speed", Range = {0, 100}, Increment = 1, Suffix = " studs", CurrentValue = 0,
            Callback = function(speed)
                if antiKnockbackConn then antiKnockbackConn:Disconnect() antiKnockbackConn = nil end
                if speed > 0 then
                    antiKnockbackConn = Core.RunService.Heartbeat:Connect(function()
                        local char = Core.Utils.getCharacter()
                        if not char then return end
                        local root = Core.Utils.getRootPart(char)
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
        
        if Core.game.PlaceId == 127742093697776 then
            GamesTab:CreateSection("Plants vs Brainrots")
            local player = Core.LocalPlayer
            local humanoid = player.Character or player.CharacterAdded:Wait():WaitForChild("Humanoid")
            local seedsFrame = player.PlayerGui.Main.Seeds.Frame.ScrollingFrame
            local gearsFrame = player.PlayerGui.Main.Gears.Frame.ScrollingFrame
            local dataRemoteEvent = (Core.ReplicatedStorage:FindFirstChild("BridgeNet2") and Core.ReplicatedStorage.BridgeNet2:FindFirstChild("dataRemoteEvent"))
            local useItemRemote = (Core.ReplicatedStorage:FindFirstChild("Remotes") and Core.ReplicatedStorage.Remotes:FindFirstChild("UseItem"))
            
            GamesTab:CreateToggle({
                Name = "Auto Buy [BEST SEEDS]", CurrentValue = false,
                Callback = function(val)
                    local running = val
                    spawn(function() while running do for _, itemFrame in ipairs(seedsFrame:GetChildren()) do if itemFrame:IsA("Frame") and itemFrame:FindFirstChild("Stock") and string.match(itemFrame.Name,"Premium") then local amount = tonumber(itemFrame.Stock.Text:match("x(%d+)")) or 0 for i = 1, amount do dataRemoteEvent:FireServer({itemFrame.Name, "\b"}) end end end task.wait(1) end end)
                end
            })
            GamesTab:CreateToggle({
                Name = "Auto Buy [BAD SEEDS]", CurrentValue = false,
                Callback = function(val)
                    local running = val
                    spawn(function() while running do for _, itemFrame in ipairs(seedsFrame:GetChildren()) do if itemFrame:IsA("Frame") and itemFrame:FindFirstChild("Stock") and not string.match(itemFrame.Name,"Premium") then local amount = tonumber(itemFrame.Stock.Text:match("x(%d+)")) or 0 for i = 1, amount do dataRemoteEvent:FireServer({itemFrame.Name, "\b"}) end end end task.wait(1) end end)
                end
            })
            GamesTab:CreateToggle({
                Name = "Auto Buy [GEARS]", CurrentValue = false,
                Callback = function(val)
                    local running = val
                    spawn(function() while running do for _, itemFrame in ipairs(gearsFrame:GetChildren()) do if itemFrame:IsA("Frame") and itemFrame:FindFirstChild("Stock") then local amount = tonumber(itemFrame.Stock.Text:match("x(%d+)")) or 0 for i = 1, amount do dataRemoteEvent:FireServer({itemFrame.Name, "\026"}) end end end task.wait(1) end end)
                end
            })
            GamesTab:CreateToggle({
                Name = "Auto Frost Grenade All", CurrentValue = false,
                Callback = function(val)
                    local running = val
                    spawn(function() while running do for _, brainrot in ipairs(Core.workspace.ScriptedMap.Brainrots:GetChildren()) do local progress = brainrot:GetAttribute("Progress") or 0 if progress > 0.6 then local tool for _, container in ipairs({player.Character, player.Backpack}) do for _, item in ipairs(container:GetChildren()) do if item:IsA("Tool") and string.match(item.Name, "^%[x%d+%] Frost Grenade$") then tool = item end end end if tool then humanoid:EquipTool(tool) local bp = brainrot.PrimaryPart or brainrot:FindFirstChildWhichIsA("BasePart") if bp then useItemRemote:FireServer({{Toggle=true, Tool=tool, Time=0.5, Pos=bp.Position}}) end end end end task.wait(2) end end)
                end
            })
        end
        
        GamesTab:CreateSection("Voxels")
        
        local function spawnLoop(toggleName, loopFunc)
            if state.activeThreads[toggleName] then return end
            state.activeThreads[toggleName] = task.spawn(loopFunc)
        end
        
        local function stopLoop(toggleName)
            if state.activeThreads[toggleName] then state.activeThreads[toggleName] = nil end
        end
        
        GamesTab:CreateToggle({
            Name = "Perfect Circle", CurrentValue = false,
            Callback = function(enabled)
                state.voxels.PerfectCircle = enabled
                if not enabled then
                    for _, blockPos in ipairs(state.spawnedBlocks.PerfectCircle) do PlaceBlock:FireServer(Core.workspace["1Grass"], Enum.NormalId.Top, blockPos, "Air") end
                    state.spawnedBlocks.PerfectCircle = {}
                    stopLoop("PerfectCircle")
                    return
                end
                spawnLoop("PerfectCircle", function()
                    local step = 3
                    local typeIndex = 1
                    while state.voxels.PerfectCircle do
                        local rootPos = Core.Utils.glitter().Position
                        for x = -20, 20, step do
                            for z = -20, 20, step do
                                local offset = Vector3.new(x, 0, z)
                                if offset.Magnitude <= 20 and offset.Magnitude >= 20 - step then
                                    local blockPos = rootPos + offset
                                    PlaceBlock:FireServer(Core.workspace["1Grass"], Enum.NormalId.Top, blockPos, Core.Utils.blockTypes[typeIndex])
                                    table.insert(state.spawnedBlocks.PerfectCircle, blockPos)
                                    typeIndex = typeIndex % #Core.Utils.blockTypes + 1
                                end
                            end
                        end
                        task.wait(0.05)
                    end
                end)
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Plank Spammer", CurrentValue = false,
            Callback = function(enabled)
                state.voxels.PlankSpammer = enabled
                if not enabled then
                    for _, blockPos in ipairs(state.spawnedBlocks.PlankSpammer) do PlaceBlock:FireServer(Core.workspace["1Grass"], Enum.NormalId.Top, blockPos, "Air") end
                    state.spawnedBlocks.PlankSpammer = {}
                    stopLoop("PlankSpammer")
                    return
                end
                spawnLoop("PlankSpammer", function()
                    local typeIndex = 1
                    while state.voxels.PlankSpammer do
                        local blockPos = Core.Utils.glitter().Position
                        PlaceBlock:FireServer(Core.workspace["1Grass"], Enum.NormalId.Top, blockPos, Core.Utils.blockTypes[typeIndex])
                        table.insert(state.spawnedBlocks.PlankSpammer, blockPos)
                        typeIndex = typeIndex % #Core.Utils.blockTypes + 1
                        task.wait(0.02)
                    end
                end)
            end
        })
        
        GamesTab:CreateToggle({
            Name = "Plank Tower", CurrentValue = false,
            Callback = function(enabled)
                state.voxels.PlankTower = enabled
                if not enabled then
                    for _, blockPos in ipairs(state.spawnedBlocks.PlankTower) do PlaceBlock:FireServer(Core.workspace["1Grass"], Enum.NormalId.Top, blockPos, "Air") end
                    state.spawnedBlocks.PlankTower = {}
                    stopLoop("PlankTower")
                    return
                end
                spawnLoop("PlankTower", function()
                    local yOffset = 0
                    local typeIndex = 1
                    while state.voxels.PlankTower do
                        local blockPos = Core.Utils.glitter().Position + Vector3.new(0, yOffset, 0)
                        PlaceBlock:FireServer(Core.workspace["1Grass"], Enum.NormalId.Top, blockPos, Core.Utils.blockTypes[typeIndex])
                        table.insert(state.spawnedBlocks.PlankTower, blockPos)
                        yOffset = yOffset + 4
                        typeIndex = typeIndex % #Core.Utils.blockTypes + 1
                        task.wait(0.05)
                    end
                end)
            end
        })
        
        local isSlapBattles = Core.game.PlaceId == 6403373529 or Core.game.PlaceId == 124596094333302
        
        if isSlapBattles then
            GamesTab:CreateSection("Slap Battles")
            
            local gloveHits = {
                ["Default"] = Core.ReplicatedStorage.b, ["Extended"] = Core.ReplicatedStorage.b, ["T H I C K"] = Core.ReplicatedStorage.GeneralHit,
                ["Squid"] = Core.ReplicatedStorage.GeneralHit, ["Gummy"] = Core.ReplicatedStorage.GeneralHit, ["RNG"] = Core.ReplicatedStorage.GeneralHit,
                ["Tycoon"] = Core.ReplicatedStorage.GeneralHit, ["Charge"] = Core.ReplicatedStorage.GeneralHit, ["Baller"] = Core.ReplicatedStorage.GeneralHit,
                ["Tableflip"] = Core.ReplicatedStorage.GeneralHit, ["Booster"] = Core.ReplicatedStorage.GeneralHit, ["Shield"] = Core.ReplicatedStorage.GeneralHit,
                ["Track"] = Core.ReplicatedStorage.GeneralHit, ["Goofy"] = Core.ReplicatedStorage.GeneralHit, ["Confusion"] = Core.ReplicatedStorage.GeneralHit,
                ["Elude"] = Core.ReplicatedStorage.GeneralHit, ["Glitch"] = Core.ReplicatedStorage.GeneralHit, ["Snowball"] = Core.ReplicatedStorage.GeneralHit,
                ["fish"] = Core.ReplicatedStorage.GeneralHit, ["Killerfish"] = Core.ReplicatedStorage.GeneralHit, ["🗿"] = Core.ReplicatedStorage.GeneralHit,
                ["Obby"] = Core.ReplicatedStorage.GeneralHit, ["Voodoo"] = Core.ReplicatedStorage.GeneralHit, ["Leash"] = Core.ReplicatedStorage.GeneralHit,
                ["Flamarang"] = Core.ReplicatedStorage.GeneralHit, ["Berserk"] = Core.ReplicatedStorage.GeneralHit, ["Quake"] = Core.ReplicatedStorage.GeneralHit,
                ["Rattlebones"] = Core.ReplicatedStorage.GeneralHit, ["Chain"] = Core.ReplicatedStorage.GeneralHit, ["Ping Pong"] = Core.ReplicatedStorage.GeneralHit,
                ["Whirlwind"] = Core.ReplicatedStorage.GeneralHit, ["Slicer"] = Core.ReplicatedStorage.GeneralHit, ["Counter"] = Core.ReplicatedStorage.GeneralHit,
                ["Hammer"] = Core.ReplicatedStorage.GeneralHit, ["Excavator"] = Core.ReplicatedStorage.GeneralHit, ["Home Run"] = Core.ReplicatedStorage.GeneralHit,
                ["Psycho"] = Core.ReplicatedStorage.GeneralHit, ["Kraken"] = Core.ReplicatedStorage.GeneralHit, ["Gravity"] = Core.ReplicatedStorage.GeneralHit,
                ["Lure"] = Core.ReplicatedStorage.GeneralHit, ["Jebaited"] = Core.ReplicatedStorage.GeneralHit, ["Meteor"] = Core.ReplicatedStorage.GeneralHit,
                ["Tinkerer"] = Core.ReplicatedStorage.GeneralHit, ["Guardian Angel"] = Core.ReplicatedStorage.GeneralHit, ["Sun"] = Core.ReplicatedStorage.GeneralHit,
                ["Necromancer"] = Core.ReplicatedStorage.GeneralHit, ["Zombie"] = Core.ReplicatedStorage.GeneralHit, ["Dual"] = Core.ReplicatedStorage.GeneralHit,
                ["Alchemist"] = Core.ReplicatedStorage.GeneralHit, ["Parry"] = Core.ReplicatedStorage.GeneralHit, ["Druid"] = Core.ReplicatedStorage.GeneralHit,
                ["Oven"] = Core.ReplicatedStorage.GeneralHit, ["Jester"] = Core.ReplicatedStorage.GeneralHit, ["Ferryman"] = Core.ReplicatedStorage.GeneralHit,
                ["Scythe"] = Core.ReplicatedStorage.GeneralHit, ["Blackhole"] = Core.ReplicatedStorage.GeneralHit, ["Santa"] = Core.ReplicatedStorage.GeneralHit,
                ["Grapple"] = Core.ReplicatedStorage.GeneralHit, ["Iceskate"] = Core.ReplicatedStorage.GeneralHit, ["Pan"] = Core.ReplicatedStorage.GeneralHit,
                ["Blasphemy"] = Core.ReplicatedStorage.GeneralHit, ["Blink"] = Core.ReplicatedStorage.GeneralHit, ["Ultra Instinct"] = Core.ReplicatedStorage.GeneralHit,
                ["Admin"] = Core.ReplicatedStorage.GeneralHit, ["Prop"] = Core.ReplicatedStorage.GeneralHit, ["Joust"] = Core.ReplicatedStorage.GeneralHit,
                ["Slapstick"] = Core.ReplicatedStorage.GeneralHit, ["Firework"] = Core.ReplicatedStorage.GeneralHit, ["Run"] = Core.ReplicatedStorage.GeneralHit,
                ["Beatdown"] = Core.ReplicatedStorage.GeneralHit, ["L.O.L.B.O.M.B"] = Core.ReplicatedStorage.GeneralHit, ["Glovel"] = Core.ReplicatedStorage.GeneralHit,
                ["Chicken"] = Core.ReplicatedStorage.GeneralHit, ["Divebomb"] = Core.ReplicatedStorage.GeneralHit, ["Lamp"] = Core.ReplicatedStorage.GeneralHit,
                ["Pocket"] = Core.ReplicatedStorage.GeneralHit, ["BONK"] = Core.ReplicatedStorage.GeneralHit, ["Knockoff"] = Core.ReplicatedStorage.GeneralHit,
                ["Divert"] = Core.ReplicatedStorage.GeneralHit, ["Frostbite"] = Core.ReplicatedStorage.GeneralHit, ["Sbeve"] = Core.ReplicatedStorage.GeneralHit,
                ["Plank"] = Core.ReplicatedStorage.GeneralHit, ["Golem"] = Core.ReplicatedStorage.GeneralHit, ["Spoonful"] = Core.ReplicatedStorage.GeneralHit,
                ["Grab"] = Core.ReplicatedStorage.GeneralHit, ["the schlop"] = Core.ReplicatedStorage.GeneralHit, ["UFO"] = Core.ReplicatedStorage.GeneralHit,
                ["el gato"] = Core.ReplicatedStorage.GeneralHit, ["Siphon"] = Core.ReplicatedStorage.GeneralHit, ["Hive"] = Core.ReplicatedStorage.GeneralHit,
                ["Wrench"] = Core.ReplicatedStorage.GeneralHit, ["Hunter"] = Core.ReplicatedStorage.GeneralHit, ["Relude"] = Core.ReplicatedStorage.GeneralHit,
                ["Avatar"] = Core.ReplicatedStorage.GeneralHit, ["Demolition"] = Core.ReplicatedStorage.GeneralHit, ["Shotgun"] = Core.ReplicatedStorage.GeneralHit,
                ["Beachball"] = Core.ReplicatedStorage.GeneralHit, ["ZZZZZZZ"] = Core.ReplicatedStorage.ZZZZZZZHit, ["Brick"] = Core.ReplicatedStorage.BrickHit,
                ["Snow"] = Core.ReplicatedStorage.SnowHit, ["Pull"] = Core.ReplicatedStorage.PullHit, ["Flash"] = Core.ReplicatedStorage.FlashHit,
                ["Spring"] = Core.ReplicatedStorage.springhit, ["Swapper"] = Core.ReplicatedStorage.HitSwapper, ["Bull"] = Core.ReplicatedStorage.BullHit,
                ["Dice"] = Core.ReplicatedStorage.DiceHit, ["Ghost"] = Core.ReplicatedStorage.GhostHit, ["Stun"] = Core.ReplicatedStorage.HtStun,
                ["Za Hando"] = Core.ReplicatedStorage.zhramt, ["Fort"] = Core.ReplicatedStorage.Fort, ["Magnet"] = Core.ReplicatedStorage.MagnetHIT,
                ["Pusher"] = Core.ReplicatedStorage.PusherHit, ["Anchor"] = Core.ReplicatedStorage.hitAnchor, ["Space"] = Core.ReplicatedStorage.HtSpace,
                ["Boomerang"] = Core.ReplicatedStorage.BoomerangH, ["Speedrun"] = Core.ReplicatedStorage.Speedrunhit, ["Mail"] = Core.ReplicatedStorage.MailHit,
                ["Golden"] = Core.ReplicatedStorage.GoldenHit, ["MR"] = Core.ReplicatedStorage.MisterHit, ["Reaper"] = Core.ReplicatedStorage.ReaperHit,
                ["Replica"] = Core.ReplicatedStorage.ReplicaHit, ["Defense"] = Core.ReplicatedStorage.DefenseHit, ["Killstreak"] = Core.ReplicatedStorage.KSHit,
                ["Reverse"] = Core.ReplicatedStorage.ReverseHit, ["Shukuchi"] = Core.ReplicatedStorage.ShukuchiHit, ["Duelist"] = Core.ReplicatedStorage.DuelistHit,
                ["woah"] = Core.ReplicatedStorage.woahHit, ["Ice"] = Core.ReplicatedStorage.IceHit, ["Adios"] = Core.ReplicatedStorage.hitAdios,
                ["Blocked"] = Core.ReplicatedStorage.BlockedHit, ["Engineer"] = Core.ReplicatedStorage.engiehit, ["Rocky"] = Core.ReplicatedStorage.RockyHit,
                ["Conveyor"] = Core.ReplicatedStorage.ConvHit, ["STOP"] = Core.ReplicatedStorage.STOP, ["Phantom"] = Core.ReplicatedStorage.PhantomHit,
                ["Wormhole"] = Core.ReplicatedStorage.WormHit, ["Acrobat"] = Core.ReplicatedStorage.AcHit, ["Plague"] = Core.ReplicatedStorage.PlagueHit,
                ["[REDACTED]"] = Core.ReplicatedStorage.ReHit, ["bus"] = Core.ReplicatedStorage.hitbus, ["Phase"] = Core.ReplicatedStorage.PhaseH,
                ["Warp"] = Core.ReplicatedStorage.WarpHt, ["Bomb"] = Core.ReplicatedStorage.BombHit, ["Bubble"] = Core.ReplicatedStorage.BubbleHit,
                ["Jet"] = Core.ReplicatedStorage.JetHit, ["Shard"] = Core.ReplicatedStorage.ShardHIT, ["potato"] = Core.ReplicatedStorage.potatohit,
                ["CULT"] = Core.ReplicatedStorage.CULTHit, ["bob"] = Core.ReplicatedStorage.bobhit, ["Buddies"] = Core.ReplicatedStorage.buddiesHIT,
                ["Spy"] = Core.ReplicatedStorage.SpyHit, ["Detonator"] = Core.ReplicatedStorage.DetonatorHit, ["Rage"] = Core.ReplicatedStorage.GRRRR,
                ["Trap"] = Core.ReplicatedStorage.traphi, ["Orbit"] = Core.ReplicatedStorage.Orbihit, ["Hybrid"] = Core.ReplicatedStorage.HybridCLAP,
                ["Slapple"] = Core.ReplicatedStorage.SlappleHit, ["Disarm"] = Core.ReplicatedStorage.DisarmH, ["Dominance"] = Core.ReplicatedStorage.DominanceHit,
                ["Link"] = Core.ReplicatedStorage.LinkHit, ["Rojo"] = Core.ReplicatedStorage.RojoHit, ["rob"] = Core.ReplicatedStorage.robhit,
                ["Rhythm"] = Core.ReplicatedStorage.rhythmhit, ["Nightmare"] = Core.ReplicatedStorage.nightmarehit, ["Hitman"] = Core.ReplicatedStorage.HitmanHit,
                ["Thor"] = Core.ReplicatedStorage.ThorHit, ["Retro"] = Core.ReplicatedStorage.RetroHit, ["Cloud"] = Core.ReplicatedStorage.CloudHit,
                ["Null"] = Core.ReplicatedStorage.NullHit, ["spin"] = Core.ReplicatedStorage.spinhit, ["Kinetic"] = Core.ReplicatedStorage.HtStun,
                ["Recall"] = Core.ReplicatedStorage.HtStun, ["Balloony"] = Core.ReplicatedStorage.HtStun, ["Sparky"] = Core.ReplicatedStorage.HtStun,
                ["Boogie"] = Core.ReplicatedStorage.HtStun, ["Coil"] = Core.ReplicatedStorage.HtStun, ["Diamond"] = Core.ReplicatedStorage.DiamondHit,
                ["Megarock"] = Core.ReplicatedStorage.DiamondHit, ["Moon"] = Core.ReplicatedStorage.CelestialHit, ["Jupiter"] = Core.ReplicatedStorage.CelestialHit,
                ["Mitten"] = Core.ReplicatedStorage.MittenHit, ["Hallow Jack"] = Core.ReplicatedStorage.HallowHIT, ["OVERKILL"] = Core.ReplicatedStorage.Overkillhit,
                ["The Flex"] = Core.ReplicatedStorage.FlexHit, ["Custom"] = Core.ReplicatedStorage.CustomHit, ["God's Hand"] = Core.ReplicatedStorage.Godshand,
                ["Error"] = Core.ReplicatedStorage.Errorhit
            }
            
            local function getGloveRemote()
                local gloveName = Core.LocalPlayer.leaderstats.Glove.Value
                return gloveHits[gloveName] or gloveHits["Default"]
            end
            
            local function getRandomTarget()
                local valid = {}
                for _, p in pairs(Core.Players:GetPlayers()) do
                    if p ~= Core.LocalPlayer and p.Character and Core.Utils.getRootPart(p.Character) and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("entered") then
                        table.insert(valid, p)
                    end
                end
                if #valid > 0 then return valid[math.random(1, #valid)] end
            end
            
            local slapDelay = 0.2
            local Reach = 13
            local farmConn, slapConnTask, running = nil, nil, false
            
            GamesTab:CreateToggle({
                Name = "Autofarm Slapples", CurrentValue = false,
                Callback = function(enabled)
                    if farmConn then farmConn:Disconnect() farmConn = nil end
                    if enabled then
                        farmConn = Core.RunService.Heartbeat:Connect(function()
                            local char = Core.Utils.getCharacter()
                            if not char or not char:FindFirstChild("entered") or not Core.Utils.getRootPart(char) then return end
                            local slapples = Core.workspace.Arena and Core.workspace.Arena.island5 and Core.workspace.Arena.island5.Slapples
                            if slapples then
                                for _, v in pairs(slapples:GetChildren()) do
                                    if v:FindFirstChild("Glove") and v.Glove:FindFirstChildWhichIsA("TouchTransmitter") then
                                        if v.Name == "Slapple" or v.Name == "GoldenSlapple" then
                                            firetouchinterest(Core.Utils.getRootPart(char), v.Glove, 0)
                                            firetouchinterest(Core.Utils.getRootPart(char), v.Glove, 1)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            })
            
            GamesTab:CreateToggle({
                Name = "Autofarm Slaps", CurrentValue = false,
                Callback = function(enabled)
                    if slapConnTask then pcall(function() task.cancel(slapConnTask) end) slapConnTask = nil end
                    running = enabled
                    if running then
                        slapConnTask = task.spawn(function()
                            while running do
                                local char = Core.Utils.getCharacter()
                                local root = Core.Utils.getRootPart(char)
                                if not root then task.wait(1) continue end
                                local target = getRandomTarget()
                                if target and target.Character and Core.Utils.getRootPart(target.Character) then
                                    Core.Utils.getRootPart(char).CFrame = Core.Utils.getRootPart(target.Character).CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                                    local dist = (Core.Utils.getRootPart(char).Position - Core.Utils.getRootPart(target.Character).Position).Magnitude
                                    if dist <= Reach then
                                        local remote = getGloveRemote()
                                        if remote then pcall(function() remote:FireServer(Core.Utils.getRootPart(target.Character), true) end) end
                                    end
                                end
                                task.wait(slapDelay)
                            end
                        end)
                    end
                end
            })
            
            GamesTab:CreateButton({
                Name = "Get Badge Gloves [TRICKHUB]",
                Callback = function()
                    local lobby = Core.workspace:FindFirstChild("Lobby")
                    if not lobby then warn("Lobby not found") return end
                    local networkFolder = Core.ReplicatedStorage:FindFirstChild("_NETWORK")
                    if networkFolder and lobby then
                        for _, obj in ipairs(networkFolder:GetChildren()) do
                            for _, v in pairs(lobby:GetChildren()) do
                                if obj:IsA("RemoteEvent") and v:IsA("MeshPart") then obj:FireServer(v.Name) end
                            end
                        end
                    end
                end
            })
        end
        
        GamesTab:CreateSection("a literal baseplate")
        
        GamesTab:CreateToggle({
            Name = "Anti Fling", CurrentValue = false,
            Callback = function(stateVal)
                local enabled = stateVal
                local function setCollision(c, collide)
                    if not c then return end
                    for _, part in pairs(c:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = collide end end
                end
                local conn
                if enabled then
                    for _, pl in pairs(Core.Players:GetPlayers()) do if pl ~= Core.LocalPlayer and pl.Character then setCollision(pl.Character, false) end end
                    conn = Core.Players.PlayerAdded:Connect(function(pl)
                        pl.CharacterAdded:Connect(function(c) if enabled then setCollision(c, false) end end)
                    end)
                else
                    for _, pl in pairs(Core.Players:GetPlayers()) do if pl.Character then setCollision(pl.Character, true) end end
                    if conn then conn:Disconnect() conn = nil end
                end
            end
        })
        
        GamesTab:CreateSection("Da Hood")
        
        GamesTab:CreateToggle({
            Name = "Chat Spy", CurrentValue = false,
            Callback = function(val)
                state.ChatSpyEnabled = val
                Core.Utils.notify("Chat Spy", "Chat Spy " .. (state.ChatSpyEnabled and "Enabled" or "Disabled"), 3)
            end
        })
    end
}
