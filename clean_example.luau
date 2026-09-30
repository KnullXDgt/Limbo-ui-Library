--[[
    Limbo Hub Clean API Example
    Using Limbo-ui-Library v2.0.7
    Full Validation + Clean OOP Wrapper + Auto Config Save
]]

local GAME_NAME = "Fish It"
local VERSION   = "2.0.7"
local LIMBO_TAG = "[LIMBO HUB]"

-- 1. Anti Multi-Instance
if getgenv().LimboHub and type(getgenv().LimboHub.Destroy) == "function" then
    pcall(function() getgenv().LimboHub:Destroy() end)
end

-- 2. Official Limbo Hub Authentication / Validation
local LIMBO_BASE_URL           = "https://limbohub.my.id"
local LIMBO_SESSION_ENDPOINT   = LIMBO_BASE_URL .. "/api/loader/session"
local LIMBO_VALIDATE_ENDPOINT  = LIMBO_BASE_URL .. "/api/loader/validate"
local LIMBO_GET_KEY_URL        = LIMBO_BASE_URL .. "/get-key"

local LimboPlayers     = game:GetService("Players")
local LimboHttpService = game:GetService("HttpService")

local function limboPostJson(url, payload)
    local req = (syn and syn.request) or (http and http.request) or request or http_request
    if not req then return nil, "No HTTP request function available" end
    local ok, res = pcall(function()
        return req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = LimboHttpService:JSONEncode(payload)
        })
    end)
    if not ok or not res then return nil, "HTTP Request Failed" end
    local b = res.Body or res.body
    local dok, parsed = pcall(function() return LimboHttpService:JSONDecode(b) end)
    return dok and parsed or nil, not dok and "Decode Failed" or nil
end

local function limboAuthorize()
    local scope = (getgenv and getgenv()) or _G
    local player = LimboPlayers.LocalPlayer
    local robloxUserId = player and string.format("%.0f", player.UserId) or "0"
    
    local config = scope.LimboConfig or scope.Config or {}
    local key = config.Key or config.key

    local response, err = limboPostJson(LIMBO_SESSION_ENDPOINT, {
        key = key,
        robloxUserId = robloxUserId,
        deviceId = (getgenv and getgenv().gethwid and getgenv().gethwid()) or "clean_client",
    })

    if not response and not key then
        return { keyType = "none", needsKeyWindow = true, source = "direct_guest" }
    elseif not response then
        return { keyType = "none", needsKeyWindow = true, source = "offline_fallback" }
    end

    if response.requiresKey or response.keyType == "none" then
        return { keyType = "none", needsKeyWindow = true, source = "direct_guest" }
    end

    return {
        keyType = response.keyType,
        ticket = response.adapterTicket,
        needsKeyWindow = false,
        source = response.keyType == "keyless" and "server_keyless" or "direct",
    }
end

local LimboSession = limboAuthorize()

local function LimboKeyValidator(enteredKey)
    if type(enteredKey) ~= "string" or enteredKey == "" then return false end
    local cleanKey = enteredKey:gsub("%s", "")
    local player = LimboPlayers.LocalPlayer
    local robloxUserId = player and string.format("%.0f", player.UserId) or "0"

    local response, err = limboPostJson(LIMBO_VALIDATE_ENDPOINT, {
        key = cleanKey,
        robloxUserId = robloxUserId,
        deviceId = "clean_client",
    })

    if response and response.success then
        LimboSession.keyType = response.keyType
        LimboSession.needsKeyWindow = false
        print("[LIMBO HUB] Key validated successfully: " .. tostring(response.keyType))
        return true
    end
    return false
end

if LimboSession and LimboSession.source == "server_keyless" then
    print("[LIMBO HUB] Keyless access is active (server_keyless)")
elseif LimboSession and LimboSession.needsKeyWindow then
    print("[LIMBO HUB] Key required - showing KeySystem window")
else
    print("[LIMBO HUB] Session authorized: " .. tostring(LimboSession and LimboSession.keyType or "active"))
end

-- 3. Load Library
local Limbo = loadstring(game:HttpGet("https://raw.githubusercontent.com/KnullXDgt/Limbo-ui-Library/main/source.luau"))()

-- 4. Create Window
local WindowConfig = {
    Title                 = "Limbo Hub",
    Subtitle              = GAME_NAME,
    Version               = "v" .. VERSION,
    ShowExecutor          = true,
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
}

if LimboSession and LimboSession.needsKeyWindow then
    WindowConfig.KeySystem = {
        Title = "Limbo Hub Access",
        Note = "Get a free key to start using Limbo Hub, or buy a premium key for instant access without the hassle",
        URL = LIMBO_GET_KEY_URL,
        SaveKey = true,
        KeyValidator = LimboKeyValidator,
    }
end

local Window = Limbo:CreateWindow(WindowConfig)
getgenv().LimboHub = Window

-- ============================================================
-- 5. CLEAN OOP API (GAMPANG, BERSIH, SEMUA OTOMATIS MASUK CONFIG)
-- ============================================================

-- Tab 1: Information
local InfoTab = Window:AddTab("Information", "info")
InfoTab:AddParagraph({
    Title = "Welcome to Limbo Hub",
    Content = "Limbo Hub delivers high-performance automation with minimalist anti-bloat UI.",
    Buttons = {
        {
            Title = "Copy Discord Link",
            Icon = "link",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/GtDHsXGJ4g")
                end
                Window:Notify({
                    Title = "Discord Copied",
                    Description = "Success",
                    Content = "Discord link copied to clipboard!",
                    Delay = 2.5
                })
            end
        }
    }
})

-- Tab 2: Main Features
local MainTab = Window:AddTab("Main", "fish")

-- Section: Auto Fishing
local FishSection = MainTab:AddSection("Auto Fishing (Legit)", true)

-- Semua Toggle ini otomatis masuk ke Config Save!
FishSection:AddToggle("Auto Cast", "Otomatis melempar umpan ke air", true, function(state)
    -- aksi toggle
end)

FishSection:AddToggle("Auto Reel", "Otomatis menarik pancingan saat strike", true, function(state)
    -- aksi toggle
end)

FishSection:AddToggle("Auto Shake", "Otomatis menyelesaikan minigame goyangan", true, function(state)
    -- aksi toggle
end)

-- Slider ini otomatis masuk ke Config Save!
FishSection:AddSlider("Cast Delay", "Jeda waktu antara lemparan pancing (detik)", 0, 5, 1, function(val)
    -- aksi slider
end)

-- Dropdown ini otomatis masuk ke Config Save!
FishSection:AddDropdown("Fish Target", "Pilih ikan target yang ingin dipancing", {
    "1x1x1x1 Shark",
    "Ancient Whale",
    "Sunken Kraken",
    "Golden Megalodon",
    "Abyssal Maw Angler"
}, false, "1x1x1x1 Shark", function(selected)
    -- aksi dropdown
end)

-- Section: Auto Sell
local SellSection = MainTab:AddSection("Auto Sell Items", false)

SellSection:AddToggle("Auto Sell", "Otomatis menjual ikan saat tas penuh", false, function(state)
    -- aksi toggle
end)

SellSection:AddDropdown("Sell Mode", "Pilih metode penjualan otomatis", {
    "Delay Mode",
    "Inventory Count"
}, false, "Inventory Count", function(mode)
    -- aksi dropdown
end)

-- Input ini otomatis masuk ke Config Save!
SellSection:AddInput("Sell Target Count", "Jumlah ikan di tas sebelum auto sell", "100", function(val)
    -- aksi input
end)

-- Tab 3: Teleport
local TeleportTab = Window:AddTab("Teleport", "map-pin")
local WaypointSection = TeleportTab:AddSection("Waypoints", true)

WaypointSection:AddDropdown("Select Location", "Pilih pulau atau lokasi tujuan", {
    "Spawn Point",
    "Moosewood Island",
    "Roslit Bay",
    "Sunken Ship",
    "Ancient Jungle"
}, false, "Spawn Point", function(loc)
    -- aksi teleport
end)

-- 6. Show Window (Instant Orvion Gen 2 style)
Window:Show()

print(("%s %s Version %s Loaded"):format(LIMBO_TAG, GAME_NAME, VERSION))
