-- Limbo UI Library - Developer Examples
-- Architecture: Pure Lua Fluent OOP (Tab -> Section -> Elements)
-- Zero wrapper metatables. Ultra-lightweight memory footprint (~30 MB).
-- This file demonstrates every component, method, event callback, and dynamic API.

-- Step 1: Initialize & Load The Library
local Limbo = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/KnullXDgt/Limbo-ui-Library/main/source.luau"
))()

-- Step 2: Create Window
-- Configuration options passed as a single clean table.
local Window = Limbo:CreateWindow({
    Title                 = "Limbo Hub",
    Subtitle              = "Game Automation",
    Version               = "v2.0.0",
    Theme                 = "Darker",
    Center                = true,
    Draggable             = true,
    Resizable             = false,
    AutoScale             = true,
    ToggleButton          = true,
    ConfigFolder          = "LimboConfig",
    Watermark             = "rbxassetid://74613200492285",
    WatermarkTransparency = 0.94,
})

-- Step 3: Tabs Creation
-- Icon uses Lucide icon aliases directly (e.g. "house", "info", "settings", "map-pin", "scroll-text")
local InfoTab       = Window:Tab({ Title = "Information", Icon = "info" })
local MainTab       = Window:Tab({ Title = "Main",        Icon = "house" })
local TeleportTab   = Window:Tab({ Title = "Teleport",    Icon = "map-pin" })
local ElementsTab   = Window:Tab({ Title = "All Elements",Icon = "layers" })

-- Step 4: Information Tab (Paragraph with Action Buttons)
-- Dynamic Paragraph: supports live updates (:SetTitle, :SetDesc, :Set) and action buttons
local CommunityCard = InfoTab:Paragraph({
    Title   = "Join Our Community",
    Desc    = "Join the official Limbo Hub Discord for script updates and direct support.",
    Buttons = {
        {
            Title     = "Copy Discord Link",
            FullWidth = true,
            Height    = 26,
            Radius    = 6,
            Callback  = function()
                local copy = setclipboard or toclipboard
                if copy then
                    copy("https://discord.gg/GtDHsXGJ4g")
                    Window:Notify({
                        Title   = "Limbo HUB",
                        Content = "Discord invite link copied to clipboard!",
                        Delay   = 3,
                    })
                end
            end
        }
    }
})

-- Dynamic Text Paragraph Example (Great for live quest trackers or status logs)
local StatusTracker = InfoTab:Paragraph({
    Title = "Live Automation Status",
    Desc  = "Status: Waiting for game data (0/1)...",
})

-- Dynamic updates:
-- StatusTracker:SetDesc("Status: In Progress (1/2)")
-- StatusTracker:SetTitle("Updated Title")
-- StatusTracker:Set("Short syntax updates desc directly")

-- Step 5: Main Tab (Sections, Toggles, Sliders, Dropdowns)

-- Section 1: Support Automation (Collapsible)
local SupportSec = MainTab:Section({
    Title  = "Support Features",
    Opened = true,
})

-- Toggle Component:
-- Title, Desc (optional), Value (boolean default), Callback (state), Flag (config ID)
local AutoEquipToggle = SupportSec:Toggle({
    Title    = "Auto Equip Rod",
    Desc     = "Automatically equips fishing rod when hand is empty",
    Value    = true,
    Callback = function(state)
        print("[Toggle Callback] Auto Equip Rod:", state)
    end,
    Flag     = "Toggle_AutoEquipRod",
})

-- Programmatically updating a Toggle:
-- AutoEquipToggle:Set(false)

SupportSec:Toggle({
    Title    = "Anti Drown",
    Desc     = "Prevents character oxygen depletion underwater",
    Value    = true,
    Callback = function(state)
        print("[Toggle Callback] Anti Drown:", state)
    end,
    Flag     = "Toggle_AntiDrown",
})

-- Section 2: Fishing Settings (Sliders & Precision Input)
local FishingSec = MainTab:Section({
    Title  = "Fishing Configurations",
    Opened = true,
})

-- Slider Component:
-- Min, Max, Value (default), Callback (currentValue), Flag
local CastDelaySlider = FishingSec:Slider({
    Title    = "Cast Delay",
    Desc     = "Interval between consecutive cast actions (seconds)",
    Min      = 0,
    Max      = 5,
    Value    = 1.5,
    Callback = function(val)
        print("[Slider Callback] Cast Delay:", val)
    end,
    Flag     = "Slider_CastDelay",
})

-- Programmatically updating a Slider:
-- CastDelaySlider:Set(2.5)

-- Dropdown Component:
-- Values (array of options), Multi (true/false), Value (default string or array), Callback
local ModeDropdown = FishingSec:Dropdown({
    Title    = "Fishing Mode",
    Desc     = "Select your preferred automation strategy",
    Values   = { "Legit Mode", "Fast Catch", "Instant Blatant" },
    Multi    = false,
    Value    = "Legit Mode",
    Callback = function(selected)
        print("[Dropdown Callback] Selected mode:", selected)
    end,
    Flag     = "Dropdown_FishingMode",
})

-- Programmatically updating Dropdown:
-- ModeDropdown:Set("Fast Catch")
-- ModeDropdown:Select("Instant Blatant")
-- ModeDropdown:Refresh({ "Option A", "Option B" }, "Option A")

-- Multi-Select Dropdown Component:
local WeatherDropdown = FishingSec:Dropdown({
    Title    = "Target Weather",
    Desc     = "Select multiple weather conditions to trigger alerts",
    Values   = { "Clear", "Storm", "Fog", "Wind", "Eclipse" },
    Multi    = true,
    Value    = { "Storm", "Wind" },
    Callback = function(selectedList)
        print("[Multi-Dropdown Callback] Active weathers:", table.concat(selectedList, ", "))
    end,
    Flag     = "Dropdown_TargetWeather",
})

-- Step 6: Teleport Tab & Horizontal Buttons (HStack Grid)
local WaypointSec = TeleportTab:Section({
    Title  = "Island Teleports",
    Opened = true,
})

local LocationDropdown = WaypointSec:Dropdown({
    Title    = "Select Destination",
    Desc     = "Choose island or secret landmark",
    Values   = { "Spawn Island", "Moosewood Island", "Roslit Bay", "Ancient Jungle", "Sunken Ship" },
    Multi    = false,
    Value    = "Spawn Island",
    Callback = function(loc)
        print("Selected destination:", loc)
    end,
    Flag     = "Dropdown_Destination",
})

-- HStack Component:
-- Creates an automatic horizontal row where added buttons share row width equally
-- 2 buttons = 50% - 50%
-- 3 buttons = 33% - 33% - 33%
local ActionRow = WaypointSec:HStack()

ActionRow:Button({
    Title    = "Teleport Now",
    Callback = function()
        Window:Notify({
            Title   = "Teleport",
            Content = "Teleporting to " .. tostring(LocationDropdown.Value) .. "...",
            Delay   = 2.5,
        })
    end,
})

ActionRow:Button({
    Title    = "Refresh List",
    Callback = function()
        LocationDropdown:Refresh({
            "Spawn Island",
            "Moosewood Island",
            "Roslit Bay",
            "Ancient Jungle",
            "Sunken Ship",
            "Secret Cave"
        }, "Spawn Island")
        Window:Notify({
            Title   = "Locations",
            Content = "Location catalog refreshed!",
            Delay   = 2,
        })
    end,
})

-- Step 7: All Elements Tab (Input, Keybind, ColorPicker, Divider)
local MiscSec = ElementsTab:Section({
    Title  = "Miscellaneous Controls",
    Opened = true,
})

-- Text Input Component:
local WebhookInput = MiscSec:Input({
    Title       = "Discord Webhook URL",
    Desc        = "Enter full webhook link for event reporting",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback    = function(text)
        print("[Input Callback] Webhook URL set to:", text)
    end,
    Flag        = "Input_WebhookURL",
})

-- Keybind Component:
local ToggleKeybind = MiscSec:Keybind({
    Title    = "UI Toggle Key",
    Desc     = "Press any keyboard key to change shortcut",
    Default  = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("[Keybind Callback] New toggle key:", key.Name)
    end,
    Flag     = "Keybind_UIToggle",
})

-- ColorPicker Component:
local AccentColorPicker = MiscSec:ColorPicker({
    Title        = "Custom Accent Color",
    Desc         = "Expand RGB sliders to pick theme color",
    Default      = Color3.fromRGB(255, 0, 224),
    Callback     = function(color)
        print("[ColorPicker Callback] New color:", color)
    end,
    Flag         = "Color_Accent",
})

-- Divider Component (Separates visual sections):
MiscSec:Divider("Advanced Automation Parameters")

-- Single Button Component:
MiscSec:SingleButton("Execute Deep Diagnostic", function()
    print("Diagnostics initiated...")
    Window:Notify({
        Title   = "Diagnostics",
        Content = "All systems functioning with zero memory leaks.",
        Delay   = 3,
    })
end)

-- Step 8: Show Window & Global Notifications
-- Show Window (Hidden by default until all tabs finish constructing)
Window:Show()

-- Global Notification Popups:
Window:Notify({
    Title   = "Limbo HUB",
    Content = "Fish It Automation Suite Loaded Successfully!",
    Icon    = "rbxassetid://97957114633547",
    Delay   = 3.5,
})

-- Quick Reference to Window Methods:
-- Window:SelectTab(1)
-- Window:SelectTab("Main")
-- Window:Toggle()
-- Window:SetTheme("Darker")
-- Window:Destroy()
