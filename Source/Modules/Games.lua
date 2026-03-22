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
        
        -- Murder Mystery 2
        GamesTab:CreateSection("Murder Mystery 2")
        
        GamesTab:CreateButton({
            Name = "Expose Roles",
            Callback = function()
                for _, player in pairs(Core.Players:GetPlayers()) do
                    if player ~= Core.LocalPlayer then
                        local backpack = player:FindFirstChild("Backpack")
                        local character = player.Character
                        
                        local isMurderer = (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
                        local isSheriff = (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun"))
                        
                        if isMurderer then
                            Core.Utils.notify("Roles", player.Name .. " is murderer", 3)
                        elseif isSheriff then
                            Core.Utils.notify("Roles", player.Name .. " is sheriff", 3)
                        end
                    end
                end
            end
        })
        
        -- Longest Answer Wins
        GamesTab:CreateSection("Longest Answer Wins")
        
        local Answers = Core.Utils.loadAnswers("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Resources/LAW/Answers.txt")
        local ReplicaSignal
        
        if Core.ReplicatedStorage:FindFirstChild("ReplicaRemoteEvents") then
            ReplicaSignal = Core.ReplicatedStorage.ReplicaRemoteEvents:FindFirstChild("Replica_ReplicaSignal")
        end
        
        local function submitAnswers()
            if not ReplicaSignal then return end
            for _, answer in ipairs(Answers) do
                ReplicaSignal:FireServer(2, "Answer", answer)
            end
        end
        
        GamesTab:CreateButton({
            Name = "Answer",
            Info = "Sends all answers",
            Callback = submitAnswers
        })
        
        local autoAnswerRunning = false
        
        GamesTab:CreateToggle({
            Name = "Auto Answer",
            CurrentValue = false,
            Callback = function(state)
                autoAnswerRunning = state
                task.spawn(function()
                    while autoAnswerRunning do
                        submitAnswers()
                        task.wait(0.5)
                    end
                end)
            end
        })
        
        -- Slap Battles
        local isSlapBattles = Core.Game.PlaceId == 6403373529 or Core.Game.PlaceId == 124596094333302
        
        if isSlapBattles then
            GamesTab:CreateSection("Slap Battles")
            
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
            
            local function getGloveRemote()
                local gloveName = Core.LocalPlayer.leaderstats and Core.LocalPlayer.leaderstats.Glove and Core.LocalPlayer.leaderstats.Glove.Value
                return gloveHits[gloveName] or gloveHits["Default"]
            end
            
            local farmConn, slapConnTask
            local running = false
            local slapDelay = 0.2
            local Reach = 13
            
            GamesTab:CreateToggle({
                Name = "Autofarm Slapples",
                CurrentValue = false,
                Callback = function(enabled)
                    if farmConn then
                        farmConn:Disconnect()
                        farmConn = nil
                    end
                    if enabled then
                        farmConn = Core.RunService.Heartbeat:Connect(function()
                            local char = Core.Utils.getCharacter()
                            if not char or not char:FindFirstChild("entered") then return end
                            local root = Core.Utils.getRootPart(char)
                            if not root then return end
                            
                            local slapples = workspace:FindFirstChild("Arena") and workspace.Arena:FindFirstChild("island5") and workspace.Arena.island5:FindFirstChild("Slapples")
                            if slapples then
                                for _, v in pairs(slapples:GetChildren()) do
                                    if v:FindFirstChild("Glove") and v.Glove:FindFirstChildWhichIsA("TouchTransmitter") then
                                        if v.Name == "Slapple" or v.Name == "GoldenSlapple" then
                                            firetouchinterest(root, v.Glove, 0)
                                            firetouchinterest(root, v.Glove, 1)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            })
            
            GamesTab:CreateToggle({
                Name = "Autofarm Slaps",
                CurrentValue = false,
                Callback = function(enabled)
                    if slapConnTask then
                        pcall(function() task.cancel(slapConnTask) end)
                        slapConnTask = nil
                    end
                    
                    running = enabled
                    
                    if running then
                        slapConnTask = task.spawn(function()
                            while running do
                                local char = Core.Utils.getCharacter()
                                local root = Core.Utils.getRootPart(char)
                                if not root then
                                    task.wait(1)
                                    continue
                                end
                                
                                -- Get random target
                                local targets = {}
                                for _, p in pairs(Core.Players:GetPlayers()) do
                                    if p ~= Core.LocalPlayer and p.Character and Core.Utils.getRootPart(p.Character) then
                                        table.insert(targets, p)
                                    end
                                end
                                
                                if #targets > 0 then
                                    local target = targets[math.random(1, #targets)]
                                    local targetRoot = Core.Utils.getRootPart(target.Character)
                                    if targetRoot then
                                        root.CFrame = targetRoot.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                                        local dist = (root.Position - targetRoot.Position).Magnitude
                                        if dist <= Reach then
                                            local remote = getGloveRemote()
                                            if remote then
                                                pcall(function()
                                                    remote:FireServer(targetRoot, true)
                                                end)
                                            end
                                        end
                                    end
                                end
                                task.wait(slapDelay)
                            end
                        end)
                    end
                end
            })
        end
    end
}
