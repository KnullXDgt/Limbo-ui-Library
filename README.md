# Limbo UI Library

Lightweight, high-performance, and mobile-friendly UI library for Roblox executors.

## Key Highlights
- **Ultra Lightweight**: Minimal memory footprint (~30 MB Lua heap), engineered for low-spec devices and multi-instance cloud emulators (Redfinger/Termux).
- **Native Layout Engine**: Automatic container sizing and responsive UI scaling without heavy `CanvasGroup` rendering leaks.
- **Fluent Component Architecture**: Direct method chaining on Tabs and Sections for clean, readable code.
- **Built-in Configuration Manager**: Seamless JSON-based saving, loading, autoloading, and multi-profile config management.
- **Full Icon Ecosystem**: Built-in support for Lucide icons via simple name aliases.

---

## Quick Start

```lua
local Limbo = loadstring(game:HttpGet("https://raw.githubusercontent.com/KnullXDgt/Limbo-ui-Library/main/source.luau"))()

local Window = Limbo:CreateWindow({
    Title        = "Limbo Hub",
    Subtitle     = "Game Title",
    Version      = "v1.0.0",
    Theme        = "Darker",
    Center       = true,
    Draggable    = true,
    Resizable    = false,
    AutoScale    = true,
    ToggleButton = true,
    ConfigFolder = "LimboConfig",
})

-- Create a Tab
local MainTab = Window:Tab({
    Title = "Main",
    Icon  = "house",
})

-- Create a Collapsible Section
local FishingSection = MainTab:Section({
    Title  = "Automation",
    Opened = true,
})

-- Add Elements directly to Section
local AutoCastToggle = FishingSection:Toggle({
    Title    = "Auto Cast",
    Desc     = "Automatically cast rod when hand is ready",
    Value    = true,
    Callback = function(state)
        print("Auto Cast:", state)
    end,
})

FishingSection:Slider({
    Title    = "Cast Delay",
    Desc     = "Delay interval between casts in seconds",
    Min      = 0,
    Max      = 5,
    Value    = 1.5,
    Callback = function(val)
        print("Delay:", val)
    end,
})

FishingSection:Dropdown({
    Title    = "Select Target",
    Desc     = "Choose your preferred target",
    Values   = { "Target A", "Target B", "Target C" },
    Multi    = false,
    Value    = "Target A",
    Callback = function(selected)
        print("Selected:", selected)
    end,
})

FishingSection:Input({
    Title       = "Custom Value",
    Desc        = "Enter custom numerical target",
    Placeholder = "e.g. 100",
    Callback    = function(text)
        print("Input text:", text)
    end,
})

FishingSection:Button({
    Title    = "Execute Action",
    Desc     = "Trigger one-time instant routine",
    Icon     = "mouse-pointer-click",
    Callback = function()
        Window:Notify({
            Title   = "Action",
            Content = "Routine executed successfully!",
            Delay   = 3,
        })
    end,
})

-- Horizontal Button Grid (HStack)
local Row = FishingSection:HStack()
Row:Button({
    Title    = "Option 1",
    Callback = function()
        print("Option 1 clicked")
    end,
})
Row:Button({
    Title    = "Option 2",
    Callback = function()
        print("Option 2 clicked")
    end,
})

-- Dynamic Status Paragraph
local StatusPara = MainTab:Paragraph({
    Title = "Routine Status",
    Desc  = "Idle",
})

-- Update paragraph dynamically
StatusPara:SetDesc("Running (1/1)")

-- Show Window
Window:Show()
```

---

## Component API Reference

### Window Options
| Parameter | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Limbo UI"` | Main window header title |
| `Subtitle` | string | `"Game"` | Subtitle displayed alongside title |
| `Version` | string | `nil` | Version badge label |
| `Theme` | string | `"Darker"` | Default theme palette |
| `Center` | boolean | `true` | Centers window on viewport upon spawn |
| `Draggable` | boolean | `true` | Allows dragging window across viewport |
| `AutoScale` | boolean | `true` | Automatically scales interface to mobile viewports |
| `ToggleButton` | boolean | `true` | Shows quick-toggle floating bubble button |
| `ConfigFolder` | string | `"LimboConfig"` | Target folder name in executor storage |

### Section Elements
- `Section:Toggle({ Title, Desc, Value, Callback, Flag })`
- `Section:Slider({ Title, Desc, Min, Max, Value, Callback, Flag })`
- `Section:Dropdown({ Title, Desc, Values, Multi, Value, Callback, Flag })`
- `Section:Input({ Title, Desc, Placeholder, Callback, Flag })`
- `Section:Button({ Title, Desc, Icon, Callback })`
- `Section:Paragraph({ Title, Desc, Buttons })`
- `Section:HStack()` -> Returns row container to add multiple horizontal buttons via `:Button({...})`
- `Section:ColorPicker({ Title, Desc, Default, Callback, Flag })`
- `Section:Keybind({ Title, Desc, Default, Callback, Flag })`
- `Section:Divider(Title)`

### Dynamic Methods
- `Toggle:Set(boolean)`
- `Slider:Set(number)`
- `Dropdown:Set(string | table)` / `Dropdown:Select(val)` / `Dropdown:Refresh(options)`
- `Input:Set(string)`
- `Paragraph:SetTitle(string)` / `Paragraph:SetDesc(string)` / `Paragraph:Set(string)`
- `Window:SelectTab(tabIndexOrName)`
- `Window:Notify({ Title, Content, Delay, Color, Icon })`
