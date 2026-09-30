-- Limbo UI Library - Example Script
-- Load the library
local Limbo = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/KnullXDgt/Limbo-ui-Library/main/source.luau"
))()

-- Create window
local Window = Limbo:CreateWindow({
    Title          = "Limbo Hub",
    Subtitle       = "Fish It",
    Theme          = "Darker",
    Center         = true,
    Draggable      = true,
    Resizable      = true,
    ToggleButton   = true,
    ConfigFolder   = "LimboFishIt",
    -- BackgroundImage = "rbxthumb://type=Asset&id=93432513909214&w=420&h=420",
})

-- Create tabs
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

-- Add Welcome Card (optional)
Window:AddWelcomeCard(MainTab)

-- Collapsible section
local Section = Window:AddCollapsible(MainTab, "General", true)

Window:AddToggle(Section, "Enable Feature", "Toggle the main feature on/off", false, function(state)
    print("Enable Feature:", state)
end)

Window:AddSlider(Section, "Speed", "Movement speed multiplier", 0, 100, 16, function(value)
    print("Speed:", value)
end)

Window:AddInput(Section, "Player Name", "Target player name", "Enter name...", function(value)
    print("Player Name:", value)
end)

Window:AddDropdown(Section, "Mode", "Select operation mode",
    {"Fast", "Balanced", "Safe"}, false, "Balanced",
    function(value)
        print("Mode:", value)
    end
)

Window:AddButtonGrid(Section,
    { Title = "Start", Callback = function()
        Limbo:Notify({ Title = "Started", Description = "OK", Content = "Feature started!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
    end },
    { Title = "Stop", Callback = function()
        Limbo:Notify({ Title = "Stopped", Description = "OK", Content = "Feature stopped.", Color = Color3.fromRGB(150,150,170), Delay = 3 })
    end }
)

-- Settings tab
Window:AddToggle(SettingsTab, "Anti AFK", "Prevent auto-kick", false, function(state) end)
Window:AddToggle(SettingsTab, "Show FPS", "Display FPS counter", false, function(state) end)
