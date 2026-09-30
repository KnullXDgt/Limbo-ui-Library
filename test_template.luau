--[[
    Limbo Hub UI Library Template
    Architecture & Keyless Auth Lifecycle aligned with Fish It 2.0.7 & WindUI Limbo
]]

local GAME_NAME       = "Fish It"
local VERSION         = "2.0.7"
local LIMBO_TAG       = "[LIMBO HUB]"
local LIMBO_LOGO      = "rbxassetid://97957114633547"
local LIMBO_WATERMARK = "rbxassetid://74613200492285"
local DISCORD_INVITE  = "https://discord.gg/GtDHsXGJ4g"

-- Backend Endpoints
local LIMBO_BASE_URL          = "https://limbohub.my.id"
local LIMBO_SESSION_ENDPOINT  = LIMBO_BASE_URL .. "/api/loader/session"
local LIMBO_GET_KEY_URL       = LIMBO_BASE_URL .. "/get-key"

local LimboPlayers = game:GetService("Players")
local LimboHttpService = game:GetService("HttpService")
local RbxAnalytics = game:FindService("RbxAnalyticsService")
local LimboAccessScope = (getgenv and getgenv()) or _G

local function limboRequestFunction()
    local scope = (getgenv and getgenv()) or _G
    local candidates = {
        rawget(scope, "request"),
        (syn and syn.request),
        (http and http.request),
        (fluxus and fluxus.request),
        rawget(scope, "http_request"),
    }
    for _, candidate in ipairs(candidates) do
        if type(candidate) == "function" then
            return candidate
        end
    end
    return nil
end

local function limboPostJson(url, payload)
    local send = limboRequestFunction()
    if not send then
        return nil, "Your executor does not expose an HTTP request function."
    end
    local ok, response = pcall(send, {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = LimboHttpService:JSONEncode(payload),
    })
    if not ok then
        return nil, "Network request failed: " .. tostring(response)
    end
    local body = (type(response) == "table" and (response.Body or response.body)) or response
    if type(body) ~= "string" or body == "" then
        return nil, "Empty response from the server."
    end
    local decoded
    local decodeOk = pcall(function()
        decoded = LimboHttpService:JSONDecode(body)
    end)
    if not decodeOk or type(decoded) ~= "table" then
        return nil, "Unexpected server response."
    end
    return decoded, nil
end

local function limboDeviceId()
    local parts = {}
    if RbxAnalytics then
        local ok, id = pcall(function() return RbxAnalytics:GetClientId() end)
        if ok and type(id) == "string" and #id > 0 then
            table.insert(parts, id)
        end
    end
    local scope = (getgenv and getgenv()) or _G
    for _, getter in ipairs({ "gethwid", "get_hwid" }) do
        local fn = rawget(scope, getter)
        if type(fn) == "function" then
            local ok, val = pcall(fn)
            if ok and type(val) == "string" and #val > 0 then
                table.insert(parts, val)
                break
            end
        end
    end
    return table.concat(parts, ":")
end

-- Keyless / Session Authorization
local function limboAuthorize()
    local player = LimboPlayers.LocalPlayer
    local robloxUserId = string.format("%.0f", player and player.UserId or 0)
    local scope = (getgenv and getgenv()) or _G
    local config = scope.LimboConfig or scope.Config or {}
    local key = config.Key or config.key

    local response, err = limboPostJson(LIMBO_SESSION_ENDPOINT, {
        key = key,
        robloxUserId = robloxUserId,
        deviceId = limboDeviceId(),
    })

    if response and response.success then
        if response.keyType == "keyless" then
            print(string.format("%s Keyless access is active (server_keyless) - key window skipped.", LIMBO_TAG))
            return { keyType = "keyless", needsKeyWindow = false, ticket = response.adapterTicket }
        elseif response.keyType == "premium" then
            print(string.format("%s Premium verified - key window skipped.", LIMBO_TAG))
            return { keyType = "premium", needsKeyWindow = false, ticket = response.adapterTicket }
        end
    end

    if response and (response.requiresKey or response.keyType == "none") then
        print(string.format("%s Key required - showing key window.", LIMBO_TAG))
        return { keyType = "none", needsKeyWindow = true }
    end

    -- Fallback jika offline/error
    return { keyType = "keyless", needsKeyWindow = false }
end

local LimboSession = limboAuthorize()

-- 1. Lifecycle Cleanup
if getgenv().LimboHub and type(getgenv().LimboHub.Destroy) == "function" then
    pcall(function()
        getgenv().LimboHub:Destroy()
    end)
    task.wait(0.1)
end

-- 2. Load Library & Validation
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

-- 4. Tab Information (Persis WindUI Limbo & Fish It 2.0.7)
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
