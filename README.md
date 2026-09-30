# Limbo UI Library

Lightweight, high-performance, and mobile-friendly UI library for Roblox executors.

## Features
- **Ultra Lightweight**: Minimal memory footprint (~20 MB vs ~90 MB on standard UI libraries), optimized for multi-instance (Redfinger/cloud phones).
- **Classic Sidebar Layout**: Clean vertical tab bar on the left with integrated search and user profile welcome footer.
- **Race-Condition Free Toggles**: Clean cancellation of running animations preventing toggle desync during config loading.
- **Built-in Config System**: Automatic JSON config save/load and autoload support.
- **Zero Heavy Render Cost**: No CanvasGroups or excessive UIStrokes that cause memory leaks on mobile/emulators.

## Quick Start
```lua
local Limbo = loadstring(game:HttpGet("https://raw.githubusercontent.com/KnullXDgt/Limbo-ui-Library/main/source.luau"))()

local Window = Limbo:CreateWindow({
    Title          = "Limbo Hub",
    Subtitle       = "Fish It",
    Theme          = "Darker",
    Center         = true,
    Draggable      = true,
    Resizable      = true,
    ToggleButton   = true,
    ConfigFolder   = "LimboFishIt",
})

local MainTab = Window:CreateTab("Main")
local Section = Window:AddCollapsible(MainTab, "General", true)

Window:AddToggle(Section, "Enable Feature", "Toggle the main feature on/off", false, function(state)
    print("State:", state)
end)
```
