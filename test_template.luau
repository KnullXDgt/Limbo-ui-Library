-- Test Template Limbo UI Library (Full Limbo Theme - Neon Magenta #FF00E0)
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
    Watermark             = "https://raw.githubusercontent.com/aleyn6969/limbo/refs/heads/main/assets/limbo-watermark-v2.png",
    WatermarkTransparency = 0.94,
    WatermarkSize         = 285,
    Icon                  = "rbxthumb://type=Asset&id=93432513909214&w=420&h=420",
})

-- Create tabs (Sidebar kiri)
local MainTab = Window:CreateTab("Main", "house")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- Collapsible Section di Tab Main
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

Window:AddInput(Section, "Webhook URL", "Discord Webhook untuk notifikasi", "https://discord.com/api/...", function(value)
    print("Webhook input:", value)
end, "Input_Webhook")

Window:AddDropdown(Section, "Select Mode", "Pilih metode operasi", {"Legit", "Blatant", "Instant", "Ultra"}, false, "Legit", function(value)
    print("Selected mode:", value)
end, "Dropdown_Mode")

Window:AddButtonGrid(Section,
    {
        Title = "Test Notif",
        Callback = function()
            Limbo:Notify({
                Title = "Limbo Hub",
                Subtitle = "Automation",
                Content = "Notifikasi dengan penanda Neon Magenta Limbo!",
                Delay = 3
            })
        end
    },
    {
        Title = "Clear Notif",
        Callback = function()
            Limbo:Notify({
                Title = "Config",
                Description = "Config cleared",
                Content = "Semua pengaturan berhasil di-reset!",
                Delay = 3
            })
        end
    }
)

-- Teleport Tab
local TpSection = Window:AddCollapsible(TeleportTab, "Waypoints", true)
Window:AddDropdown(TpSection, "Select Location", "Pilih lokasi teleportasi", {"Spawn Point", "Arena 1", "Shop Area", "Secret Zone"}, false, "Spawn Point", function(val)
    print("Teleport selected:", val)
end, "Dropdown_Location")

-- Settings Tab
local SettingsSection = Window:AddCollapsible(SettingsTab, "Safety", true)
Window:AddToggle(SettingsSection, "Anti AFK", "Mencegah kick 20 menit dari Roblox", true, function(st)
    print("Anti AFK:", st)
end, "Toggle_AntiAFK")

Window:AddToggle(SettingsSection, "Show Real-Ping", "Menampilkan panel ping dan waktu", false, function(st)
    print("Show Real-Ping:", st)
end, "Toggle_RealPing")

Window:Show()

-- Tampilkan notifikasi awal
task.delay(0.5, function()
    Limbo:Notify({
        Title = "Limbo Hub",
        Subtitle = "Loaded",
        Description = "Ready",
        Content = "Welcome to Limbo Hub v" .. Limbo.Version,
        Delay = 3
    })
end)
