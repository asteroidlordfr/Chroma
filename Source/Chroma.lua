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

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Library.lua'))()
local MODULE_BASE = "https://raw.githubusercontent.com/asteroidlordfr/Chroma/main/Source/Modules/"

local function loadModule(moduleName)
    local url = MODULE_BASE .. moduleName .. ".lua"
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not success or not result then
        return nil
    end
    local func = loadstring(result)
    if not func then
        return nil
    end
    local ok, module = pcall(func)
    if ok then
        return module
    end
    return nil
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
    Camera = workspace.CurrentCamera,
    workspace = workspace,
    game = game,
}

Core.Character = Core.LocalPlayer.Character or Core.LocalPlayer.CharacterAdded:Wait()
Core.Humanoid = Core.Character:WaitForChild("Humanoid")

local Modules = {
    Movement = loadModule("Movement"),
    Visuals = loadModule("Visuals"),
    Client = loadModule("Client"),
    Animations = loadModule("Animations"),
    Combat = loadModule("Combat"),
    Game = loadModule("Games"),
    OP = loadModule("OP"),
    Scripts = loadModule("Scripts"),
}

local ModuleOrder = {
    "Movement",
    "Visuals",
    "Client",
    "Animations",
    "Combat",
    "Game",
    "OP",
    "Scripts"
}

local Window = Library:CreateWindow({
   Name = "🟢 Chroma",
   LoadingTitle = "An open-sourced Roblox universal cheat.",
   LoadingSubtitle = "Licensed under GPLv3",
   Theme = "Ocean",
   ConfigurationSaving = {Enabled = true, FolderName = "ChromaConfigs", FileName = "Chroma"},
   KeySystem = false,
})

for _, name in ipairs(ModuleOrder) do
    local module = Modules[name]
    if module and type(module) == "table" and module.Initialize then
        module.Initialize(Core, Window)
    end
end
