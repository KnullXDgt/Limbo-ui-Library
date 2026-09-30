--[[
    Limbo Hub UI Library Template
    Pure UI Template (Clean & Independent)
]]

local GAME_NAME       = "Fish It"
local VERSION         = "2.0.7"
local LIMBO_TAG       = "[LIMBO HUB]"
local LIMBO_LOGO      = "rbxassetid://97957114633547"
local LIMBO_WATERMARK = "rbxassetid://74613200492285"
local DISCORD_INVITE  = "https://discord.gg/GtDHsXGJ4g"

-- 1. Lifecycle Cleanup
if getgenv().LimboHub and type(getgenv().LimboHub.Destroy) == "function" then
    pcall(function()
        getgenv().LimboHub:Destroy()
    end)
    task.wait(0.1)
end

-- 2. Load Library
local Limbo = loadfile("/root/FishitWork/Limbo-ui-Library/source.luau")()
assert(Limbo and type(Limbo.CreateWindow) == "function", LIMBO_TAG .. " library did not return its API")

-- 3. Window Configuration (Dominan Abu-abu Monochrome Limbo)
local Window = Limbo:CreateWindow({
    Title                 = "Limbo Hub",
    Subtitle              = GAME_NAME,
    Version               = "v" .. VERSION,
    ShowExecutor          = true,
    Theme                 = "Limbo",
    Center                = true,
    Draggable             = true,
    Resizable             = true,
    ToggleButton          = true,
    ConfigFolder          = "LimboFishIt",
    Watermark             = LIMBO_WATERMARK,
    WatermarkTransparency = 0.88,
    WatermarkSize         = 285,
    Icon                  = LIMBO_LOGO,
})

getgenv().LimboHub = Window

-- 4. Tab Information
local InfoTab = Window:CreateTab("Information", "info")

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
                        Icon = LIMBO_LOGO,
                        Delay = 2.5
                    })
                else
                    warn(LIMBO_TAG .. " Clipboard API is unavailable: " .. DISCORD_INVITE)
                end
            end
        }
    }
})

-- 5. Tab Main
local MainTab = Window:CreateTab("Main", "house")
local Section = Window:AddCollapsible(MainTab, "Automation Features", true)

Window:AddToggle(Section, "Auto Farm", "Otomatis farming koin di area", false, function(state)
    print(LIMBO_TAG .. " Auto Farm set to:", state)
end, "Toggle_AutoFarm")

Window:AddToggle(Section, "Auto Equip Rod", "Otomatis pegang pancingan saat tangan kosong", true, function(state)
    print(LIMBO_TAG .. " Auto Equip Rod set to:", state)
end, "Toggle_AutoEquipRod")

Window:AddSlider(Section, "Speed Multiplier", "Atur kecepatan jalan", 16, 100, 24, function(value)
    print(LIMBO_TAG .. " Speed set to:", value)
end, "Slider_Speed")

Window:AddInput(Section, "Webhook URL", "Discord Webhook untuk notifikasi", "https://discord.com/api/...", function(value)
    print(LIMBO_TAG .. " Webhook input:", value)
end, "Input_Webhook")

Window:AddDropdown(Section, "Select Mode", "Pilih metode operasi", {"Legit", "Blatant", "Instant", "Ultra"}, false, "Legit", function(value)
    print(LIMBO_TAG .. " Selected mode:", value)
end, "Dropdown_Mode")

-- 6. Tab Teleport
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local TpSection = Window:AddCollapsible(TeleportTab, "Waypoints", true)
Window:AddDropdown(TpSection, "Select Location", "Pilih lokasi teleportasi", {"Spawn Point", "Arena 1", "Shop Area", "Secret Zone"}, false, "Spawn Point", function(val)
    print(LIMBO_TAG .. " Teleport selected:", val)
end, "Dropdown_Location")

-- 7. Tab Settings
local SettingsTab = Window:CreateTab("Settings", "settings")
local SettingsSection = Window:AddCollapsible(SettingsTab, "Safety", true)
Window:AddToggle(SettingsSection, "Anti AFK", "Mencegah kick 20 menit dari Roblox", true, function(st)
    print(LIMBO_TAG .. " Anti AFK:", st)
end, "Toggle_AntiAFK")

-- 8. Show Window & Loaded Feedback
Window:Show()

print(("%s %s Version %s Loaded"):format(LIMBO_TAG, GAME_NAME, VERSION))

Limbo:Notify({
    Title   = "Limbo HUB",
    Content = string.format("%s  %s", GAME_NAME, VERSION),
    Icon    = LIMBO_LOGO,
    Delay   = 4,
})
