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
        local AnimTab = Window:CreateTab("⚡ Animations")
        
        AnimTab:CreateToggle({
            Name = "Jerk Off",
            CurrentValue = false,
            Callback = function(state)
                local char = Core.Utils.getCharacter()
                local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
                local backpack = Core.LocalPlayer:FindFirstChildWhichIsA("Backpack")
                
                if not humanoid or not backpack then return end
                
                local jerkRunning = false
                local jerkTrack, jerkTool
                
                local function isR15()
                    return humanoid.RigType == Enum.HumanoidRigType.R15
                end
                
                local function stopJerk()
                    jerkRunning = false
                    if jerkTrack then
                        jerkTrack:Stop()
                        jerkTrack = nil
                    end
                end
                
                if state then
                    jerkRunning = true
                    jerkTool = Instance.new("Tool")
                    jerkTool.Name = "my willy"
                    jerkTool.ToolTip = "stop playing with your sausage"
                    jerkTool.RequiresHandle = false
                    jerkTool.Parent = backpack
                    
                    jerkTool.Equipped:Connect(function()
                        jerkRunning = true
                        task.spawn(function()
                            while jerkRunning do
                                if not jerkTrack then
                                    local anim = Instance.new("Animation")
                                    anim.AnimationId = not isR15() and "rbxassetid://72042024" or "rbxassetid://698251653" -- Credits to EdgeIY
                                    jerkTrack = humanoid:LoadAnimation(anim)
                                end
                                jerkTrack:Play()
                                jerkTrack:AdjustSpeed(isR15() and 0.7 or 0.65)
                                jerkTrack.TimePosition = 0.6
                                task.wait(0.1)
                                while jerkTrack and jerkTrack.TimePosition < (isR15() and 0.7 or 0.65) do
                                    task.wait(0.1)
                                end
                                if jerkTrack then
                                    jerkTrack:Stop()
                                    jerkTrack = nil
                                end
                            end
                        end)
                    end)
                    
                    jerkTool.Unequipped:Connect(stopJerk)
                    humanoid.Died:Connect(stopJerk)
                    jerkTool:Equip()
                else
                    stopJerk()
                    if jerkTool then
                        jerkTool:Destroy()
                        jerkTool = nil
                    end
                end
            end
        })
    end
}
