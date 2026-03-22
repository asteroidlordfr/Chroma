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
        
        function Core.Utils.safeHttpGet(url) -- This HTTP request is **ONLY** used for fetching the answer list so we can update it at anytime, we will never use Chroma to harm our users.
            local success, result = pcall(function()
                return game:HttpGet(url)
            end)
            return success and result or nil
        end
        
        function Core.Utils.getRootPart(character)
            if not character then return nil end
            return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
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
        
        function Core.Utils.glitter()
            local char = Core.Utils.getCharacter()
            if char:FindFirstChild("HumanoidRootPart") then
                return char.HumanoidRootPart
            elseif char:FindFirstChild("Torso") then
                return char.Torso
            elseif char:FindFirstChild("UpperTorso") then
                return char.UpperTorso
            end
        end
        
        Core.Utils.ignoreList = {
            ":part/1/1/1", ":part/10/10/10", ":colorshifttop 10000 0 0", ":colorshiftbottom 10000 0 0",
            ":colorshifttop 0 10000 0", ":colorshiftbottom 0 10000 0", ":colorshifttop 0 0 10000", ":colorshiftbottom 0 0 10000"
        }
        
        function Core.Utils.checkIgnored(msg)
            for i = 1, #Core.Utils.ignoreList do
                if msg == Core.Utils.ignoreList[i] then
                    return true
                end
            end
            return false
        end
        
        Core.Utils.blockTypes = {"Oak Planks", "Bricks", "Dirt", "Cobblestone", "Oak Log", "Oak Leaves", "Glass", "Stone", "Yellow Wool", "White Wool", "TNT", "Sponge", "Sand", "Red Wool", "Pruple Wool", "Pink Wool", "Orange Wool", "Green Wool", "Blue Wool", "Bookshelf", "Clay", "Coal Ore", "Cyan Wool", "Diamond Block", "Diamond Ore", "Iron Ore", "Mossy Stone Bricks", "Magenta Wool", "Lime Wool", "iron Block", "Gold Block", "Gold Ore", "Magma", "Gray Wool", "Black Wool", "Glass"}
    end
}
