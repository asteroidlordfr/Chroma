--[[

© Chroma, 2026
Yet another Universal script for Roblox.

Fully open-sourced, and free forever.
I don't really know if I plan on long term support for this project, but I review pull requests and would be glad to add some.

Enjoying the script? Star us on GitHub: github.com/asteroidlordfr/Chroma
                                        ^^ you can also read our source code, open pull requests, and issues.
Comments are placed as **DEV COMMENTS**, it is meant to explain parts of the code, credit contributors and other purposes.

--]]

repeat task.wait() until game:IsLoaded()
task.wait(0.3)

local MODULE_BASE = "https://github.com/asteroidlordfr/Chroma/raw/main/Source/Modules/"

local function loadModule(moduleName)
    local url = MODULE_BASE .. moduleName .. ".lua"
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return loadstring(result)()
    else
        warn("[X] Chroma: Failed to load module " .. moduleName)
        return nil
    end
end

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Library.lua'))()
if not Library then
    error("[X] Chroma: Failed to load Rayfield, for some reason?")
end

local Core = {
    Library = Library,
    Players = game:GetService("Players"),
    LocalPlayer = game:GetService("Players").LocalPlayer,
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    VirtualUser = game:GetService("VirtualUser"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    MarketplaceService = game:GetService("MarketplaceService"),
    TextChatService = game:GetService("TextChatService"),
}

Core.Character = Core.LocalPlayer.Character or Core.LocalPlayer.CharacterAdded:Wait()
Core.Humanoid = Core.Character:WaitForChild("Humanoid")

local Modules = {
    Utils = loadModule("Utils"),
    Movement = loadModule("Movement"),
    Visuals = loadModule("Visuals"),
    Combat = loadModule("Combat"),
    Games = loadModule("Games"),
    Animations = loadModule("Animations"),
    Client = loadModule("Client"),
    AntiCheat = loadModule("AntiCheat"),
}

local Window = Library:CreateWindow({
    Name = "🟢 Chroma",
    LoadingTitle = "An open-sourced Roblox universal cheat.",
    LoadingSubtitle = "Licensed under GPLv3",
    Theme = "Ocean",
    ConfigurationSaving = {Enabled = true, FolderName = "ChromaConfigs", FileName = "Chroma"},
    KeySystem = false,
})

for name, module in pairs(Modules) do
    if module and module.Initialize then
        module.Initialize(Core, Window)
    end
end

print("[V] Chroma: Chroma has loaded successfully!")
