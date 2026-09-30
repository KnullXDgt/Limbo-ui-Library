-- Test Template Limbo UI Library (Full WindUI Limbo Reproduction)
local Limbo = loadfile("/root/FishitWork/Limbo-ui-Library/source.luau")()

local Window = Limbo:CreateWindow({
    Title                 = "Limbo Hub",
    Subtitle              = "Fish It",
    Version               = "v2.0.7",
    ShowExecutor          = true,
    Theme                 = "Limbo",
    Center                = true,
    Draggable             = true,
    Resizable             = true,
    ToggleButton          = true,
    ConfigFolder          = "LimboFishIt",
    Watermark             = "rbxassetid://74613200492285",
    WatermarkTransparency = 0.88,
    WatermarkSize         = 285,
    Icon                  = "rbxassetid://97957114633547",
})

-- 1. Tab Information (Persis WindUI Limbo & Fish It 2.0.7)
local InfoTab = Window:CreateTab("Information", "info")

local DISCORD_INVITE = "https://discord.gg/GtDHsXGJ4g"

Window:AddParagraph(InfoTab, {
    Title = "Join Our Community",
    Desc = "Become part of the Limbo Hub community on Discord for the latest updates, script support, and exclusive releases. Copy the invite link below and join us today!",
    Buttons = {
        {
            Title = "Copy Discord Link",
            Height = 32,
            Radius = 6,
            Callback = function()
                local copy = setclipboard or toclipboard
                if copy then
                    copy(DISCORD_INVITE)
                    Limbo:Notify({
                        Title = "Limbo HUB",
                        Content = "Discord link copied",
                        Delay = 2.5
                    })
                else
                    print("[Limbo HUB] Discord invite:", DISCORD_INVITE)
                end
            end
        }
    }
})

-- Single Button di luar paragraph
Window:AddSingleButton(InfoTab, "Official Website", function()
    local copy = setclipboard or toclipboard
    if copy then copy("https://limbohub.my.id") end
    Limbo:Notify({
        Title = "Limbo HUB",
        Content = "Website link copied",
        Delay = 2.5
    })
end)

-- 2. Tab Main
local MainTab = Window:CreateTab("Main", "house")
local Section = Window:AddCollapsible(MainTab, "Automation Features", true)

Window:AddToggle(Section, "Auto Farm", "Otomatis farming koin di area", false, function(state)
    print("Auto Farm set to:", state)
end, "Toggle_AutoFarm")

Window:AddToggle(Section, "Auto Equip Rod", "Otomatis pegang pancingan saat tangan kosong", true, function(state)
    print("Auto Equip Rod set to:", state)
end, "Toggle_AutoEquipRod")

Window:AddSlider(Section, "Speed Multiplier", "Atur kecepatan jalan", 16, 100, 24, function(value)
    print("Speed set to:", value)
end, "Slider_Speed")

Window:AddDropdown(Section, "Select Mode", "Pilih metode operasi", {"Legit", "Blatant", "Instant", "Ultra"}, false, "Legit", function(value)
    print("Selected mode:", value)
end, "Dropdown_Mode")

-- 3. Tab Teleport
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local TpSection = Window:AddCollapsible(TeleportTab, "Waypoints", true)
Window:AddDropdown(TpSection, "Select Location", "Pilih lokasi teleportasi", {"Spawn Point", "Arena 1", "Shop Area", "Secret Zone"}, false, "Spawn Point", function(val)
    print("Teleport selected:", val)
end, "Dropdown_Location")

-- 4. Tab Settings
local SettingsTab = Window:CreateTab("Settings", "settings")
local SettingsSection = Window:AddCollapsible(SettingsTab, "Safety", true)
Window:AddToggle(SettingsSection, "Anti AFK", "Mencegah kick 20 menit dari Roblox", true, function(st)
    print("Anti AFK:", st)
end, "Toggle_AntiAFK")

Window:Show()
