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
        local ScriptsTab = Window:CreateTab("📎 Scripts")
        
        ScriptsTab:CreateButton({Name = "Update Chroma", Callback = function() loadstring(Core.Utils.safeHttpGet("https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Chroma.lua"))() end})
        ScriptsTab:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(Core.Utils.safeHttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
        ScriptsTab:CreateButton({Name = "Dex Explorer", Callback = function() loadstring(Core.Utils.safeHttpGet("https://raw.githubusercontent.com/LorekeeperZinnia/Dex/master/main.lua"))() end})
    end
}
