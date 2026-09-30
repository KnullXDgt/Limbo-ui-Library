--[[
    Limbo UI Library - Official Example Script
    Repository: https://github.com/KnullXDgt/Limbo-ui-Library
    Supports both Modern OOP Chaining and Functional API styles.
]]

-- 1. Load the Library
local Limbo = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/KnullXDgt/Limbo-ui-Library/main/source.luau"
))()

-- 2. Create Window
local Window = Limbo:CreateWindow({
    Title                 = "Limbo Hub",
    Subtitle              = "Official Example",
    Version               = "v2.0.7",
    Theme                 = "Darker",
    Center                = true,
    Draggable             = true,
    Resizable             = false,
    AutoScale             = true,
    ToggleButton          = true,
    Watermark             = "rbxassetid://74613200492285",
    WatermarkTransparency = 0.88,
    WatermarkSize         = 285,
    Icon                  = "rbxassetid://97957114633547",
    ConfigFolder          = "LimboHub",
})

-- 3. Information Tab (Community & Links)
local InfoTab = Window:AddTab("Information", "info")

InfoTab:AddParagraph({
    Title = "Welcome to Limbo UI",
    Desc = "Lightweight, beautiful, and ultra-high-performance UI engine for Roblox scripts. Built with zero CanvasGroup leaks and native C++ sizing.",
    Buttons = {
        {
            Title = "Copy Discord Link",
            FullWidth = true,
            Height = 26,
            Radius = 6,
            Callback = function()
                local copy = setclipboard or toclipboard
                if copy then
                    copy("https://discord.gg/GtDHsXGJ4g")
                    Window:Notify({
                        Title = "Clipboard",
                        Content = "Discord link copied to clipboard!",
                        Delay = 2.5
                    })
                end
            end
        }
    }
})

-- 4. Main Tab (Interactive Elements Showcase)
local MainTab = Window:AddTab("Main", "house")

-- Section 1: Auto Fishing / Core Features
local FeatureSec = MainTab:AddSection("Core Automation", true)

FeatureSec:AddToggle("Auto Cast", "Automatically casts the fishing rod into water", true, function(state)
    -- Toggle callback
end)

FeatureSec:AddToggle("Auto Reel", "Automatically pulls rod when strike detected", true, function(state)
    -- Toggle callback
end)

FeatureSec:AddSlider("Cast Delay", "Cooldown between rod casts (seconds)", 0, 5, 1, function(value)
    -- Slider callback
end)

FeatureSec:AddDropdown("Target Species", "Select target species to track or farm", {
    "1x1x1x1 Shark",
    "Ancient Whale",
    "Sunken Kraken",
    "Golden Megalodon",
    "Abyssal Maw Angler"
}, false, "1x1x1x1 Shark", function(selected)
    -- Dropdown callback
end)

-- Section 2: Management & Input
local ActionSec = MainTab:AddSection("Actions & Values", false)

ActionSec:AddInput("Target Count", "Threshold amount before auto-action triggers", "100", function(text)
    -- Input callback
end)

ActionSec:AddButton("Instant Action", "Executes an immediate manual task", "mouse-pointer-click", function()
    Window:Notify({
        Title = "Action Executed",
        Content = "Manual task completed successfully!",
        Delay = 2
    })
end)

ActionSec:AddButtonGrid(
    { Title = "Start All", Callback = function() Window:Notify({Title = "Status", Content = "All systems started"}) end },
    { Title = "Stop All", Callback = function() Window:Notify({Title = "Status", Content = "All systems stopped"}) end }
)

-- 5. Settings Tab (Customization & Keys)
local SettingsTab = Window:AddTab("Settings", "settings")
local SafetySec = SettingsTab:AddSection("Safety & System", true)

SafetySec:AddToggle("Anti AFK", "Prevents 20-minute client idle disconnection", true, function(state)
    -- Anti AFK
end)

SafetySec:AddKeybind("Toggle UI Key", "Keyboard shortcut to toggle window visibility", Enum.KeyCode.RightControl, function(key)
    -- Keybind callback
end)

SafetySec:AddColorPicker("Accent Color", "Custom color accent for UI elements", Color3.fromRGB(150, 150, 170), function(color)
    -- ColorPicker callback
end)

-- 6. Show Window (Instant Orvion Gen 2 style)
Window:Show()

Window:Notify({
    Title   = "Limbo UI",
    Content = "Example script loaded successfully!",
    Delay   = 3,
})
