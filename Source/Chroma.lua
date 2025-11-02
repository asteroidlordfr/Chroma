local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/refs/heads/main/Source/Rayfield.lua'))()
local Window = Rayfield:CreateWindow({
   Name = "Chroma",
   LoadingTitle = "Open-sourced Roblox universal cheat.",
   LoadingSubtitle = "Licensed under GPLv3",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, 
      FileName = "Chroma"
   },
   KeySystem = false, 
})

local Tab = Window:CreateTab("Credits") 
local Button = Tab:CreateButton({
   Name = "AsteroidLord",
   Info = "Owner and Developer of Chroma", 
   Callback = function()
   end,
})
