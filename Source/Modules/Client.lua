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
        local ClientTab = Window:CreateTab("💻 Client")
        local state = {currentIndex = 1, cycleTimes = {6, 12, 18, 0}, afkConnection = nil}
        
        ClientTab:CreateButton({
            Name = "Change Time of Day",
            Callback = function()
                Core.game.Lighting.ClockTime = state.cycleTimes[state.currentIndex]
                state.currentIndex = state.currentIndex + 1
                if state.currentIndex > #state.cycleTimes then state.currentIndex = 1 end
            end
        })
        
        ClientTab:CreateToggle({
            Name = "Anti AFK Kick", CurrentValue = false,
            Callback = function(enabled)
                if enabled then
                    state.afkConnection = Core.LocalPlayer.Idled:Connect(function()
                        Core.VirtualUser:Button2Down(Vector2.new(0,0), Core.Camera.CFrame)
                        task.wait(1)
                        Core.VirtualUser:Button2Up(Vector2.new(0,0), Core.Camera.CFrame)
                    end)
                elseif state.afkConnection then state.afkConnection:Disconnect() state.afkConnection = nil end
            end
        })
        
        ClientTab:CreateSection("Other")
        
        ClientTab:CreateToggle({
            Name = "Player Collision", CurrentValue = false,
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
    end
}
