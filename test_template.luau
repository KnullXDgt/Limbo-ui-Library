--[[
    Limbo Hub UI Library Template
    Architecture & Features Skeleton aligned with Fish It 2.0.7
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
            FullWidth = true, -- Full width seperti diawal!
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

-- 5. Tab Main (Skeleton Lengkap Persis Fish It 2.0.7)
local MainTab = Window:CreateTab("Main", "house")

-- Section 1: Support Features
local SupportSection = Window:AddCollapsible(MainTab, "Support Features", true)

Window:AddToggle(SupportSection, "Auto Equip Rod", "Otomatis pegang pancingan saat tangan kosong", true, function(state)
    print(LIMBO_TAG .. " Auto Equip Rod:", state)
end, "Toggle_AutoEquipRod")

Window:AddToggle(SupportSection, "Anti Drown", "Mencegah karakter tenggelam dan kehabisan oksigen", true, function(state)
    print(LIMBO_TAG .. " Anti Drown:", state)
end, "Toggle_AntiDrown")

Window:AddToggle(SupportSection, "Walk On Water", "Berjalan di atas permukaan air laut", false, function(state)
    print(LIMBO_TAG .. " Walk On Water:", state)
end, "Toggle_WalkOnWater")

Window:AddToggle(SupportSection, "Freeze Character", "Mengunci posisi karakter agar tidak terseret arus", false, function(state)
    print(LIMBO_TAG .. " Freeze Character:", state)
end, "Toggle_FreezeCharacter")

-- Section 2: Auto Fishing (Legit Mode)
local FishingSection = Window:AddCollapsible(MainTab, "Auto Fishing (Legit)", true)

Window:AddToggle(FishingSection, "Auto Cast", "Otomatis melempar umpan ke air", true, function(state)
    print(LIMBO_TAG .. " Auto Cast:", state)
end, "Toggle_AutoCast")

Window:AddToggle(FishingSection, "Auto Reel", "Otomatis menarik pancingan saat ikan strike", true, function(state)
    print(LIMBO_TAG .. " Auto Reel:", state)
end, "Toggle_AutoReel")

Window:AddToggle(FishingSection, "Auto Shake", "Otomatis menyelesaikan minigame goyangan", true, function(state)
    print(LIMBO_TAG .. " Auto Shake:", state)
end, "Toggle_AutoShake")

Window:AddSlider(FishingSection, "Cast Delay", "Jeda waktu antara lemparan pancing", 0, 5, 1, function(value)
    print(LIMBO_TAG .. " Cast Delay:", value)
end, "Slider_CastDelay")

-- Section 3: Instant Catch Mode
local InstantSection = Window:AddCollapsible(MainTab, "Instant Catch (Blatant)", false)

Window:AddToggle(InstantSection, "Instant Catch", "Menangkap ikan langsung seketika saat melempar", false, function(state)
    print(LIMBO_TAG .. " Instant Catch:", state)
end, "Toggle_InstantCatch")

Window:AddSlider(InstantSection, "Catch Delay", "Jeda tangkap instan (detik)", 0, 3, 0.5, function(value)
    print(LIMBO_TAG .. " Instant Catch Delay:", value)
end, "Slider_CatchDelay")

-- Section 4: Auto Sell Items
local SellSection = Window:AddCollapsible(MainTab, "Auto Sell Items", false)

Window:AddToggle(SellSection, "Auto Sell", "Otomatis menjual ikan dan hasil tangkapan", false, function(state)
    print(LIMBO_TAG .. " Auto Sell:", state)
end, "Toggle_AutoSell")

Window:AddDropdown(SellSection, "Sell Mode", "Pilih metode penjualan otomatis", {"Delay Mode", "Inventory Count"}, false, "Inventory Count", function(val)
    print(LIMBO_TAG .. " Sell Mode:", val)
end, "Dropdown_SellMode")

Window:AddInput(SellSection, "Sell Target Count", "Jumlah ikan di tas sebelum auto sell", "100", function(val)
    print(LIMBO_TAG .. " Sell Target Count:", val)
end, "Input_SellTarget")

-- Section 5: Craft Minigame
local CraftSection = Window:AddCollapsible(MainTab, "Craft Minigame", false)

Window:AddToggle(CraftSection, "Auto Perfect Craft", "Otomatis menyelesaikan minigame craft 100% perfect", false, function(state)
    print(LIMBO_TAG .. " Auto Perfect Craft:", state)
end, "Toggle_AutoPerfectCraft")

Window:AddSlider(CraftSection, "Craft Delay", "Jeda klik perfect craft", 0.05, 0.5, 0.1, function(val)
    print(LIMBO_TAG .. " Craft Delay:", val)
end, "Slider_CraftDelay")

-- 6. Tab Teleport
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local TpSection = Window:AddCollapsible(TeleportTab, "Waypoints", true)
Window:AddDropdown(TpSection, "Select Location", "Pilih lokasi teleportasi", {"Spawn Point", "Moosewood Island", "Roslit Bay", "Sunken Ship", "Ancient Jungle"}, false, "Spawn Point", function(val)
    print(LIMBO_TAG .. " Teleport selected:", val)
end, "Dropdown_Location")

-- 7. Tab Settings
local SettingsTab = Window:CreateTab("Settings", "settings")
local SettingsSection = Window:AddCollapsible(SettingsTab, "Safety & Performance", true)
Window:AddToggle(SettingsSection, "Anti AFK", "Mencegah kick 20 menit dari Roblox", true, function(st)
    print(LIMBO_TAG .. " Anti AFK:", st)
end, "Toggle_AntiAFK")

Window:AddToggle(SettingsSection, "Potato Graphics", "Menghapus partikel dan render berat untuk hemat RAM", false, function(st)
    print(LIMBO_TAG .. " Potato Graphics:", st)
end, "Toggle_PotatoGraphics")

-- 8. Show Window & Loaded Feedback
Window:Show()

print(("%s %s Version %s Loaded"):format(LIMBO_TAG, GAME_NAME, VERSION))

Limbo:Notify({
    Title   = "Limbo HUB",
    Content = string.format("%s  %s", GAME_NAME, VERSION),
    Icon    = LIMBO_LOGO,
    Delay   = 4,
})
