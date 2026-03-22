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
        Core.Utils = {}
        
        -- This HTTP request is **ONLY** sorely used for fetching the answer list so we can update it at anytime, we will never use Chroma to harm our users.
        function Core.Utils.safeHttpGet(url)
            local success, result = pcall(function()
                return game:HttpGet(url)
            end)
            return success and result or nil
        end
        
        function Core.Utils.getRootPart(character)
            if not character then return nil end
            return character:FindFirstChild("HumanoidRootPart") or 
                   character:FindFirstChild("Torso") or 
                   character:FindFirstChild("UpperTorso")
        end
        
        function Core.Utils.getCharacter()
            return Core.LocalPlayer.Character or Core.LocalPlayer.CharacterAdded:Wait()
        end
        
        function Core.Utils.hasCharacter()
            local char = Core.LocalPlayer.Character
            return char and char.Parent ~= nil
        end
        
        function Core.Utils.notify(title, content, duration)
            Core.Library:Notify({
                Title = title,
                Content = content,
                Duration = duration or 3
            })
        end
        
        function Core.Utils.loadAnswers(url)
            local response = Core.Utils.safeHttpGet(url)
            if response then
                local answers = {}
                for line in response:gmatch("[^\r\n]+") do
                    if line ~= "" then
                        table.insert(answers, line:lower())
                    end
                end
                return answers
            end
            return {}
        end
    end
}
