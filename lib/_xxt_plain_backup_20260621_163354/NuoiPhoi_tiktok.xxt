-- NuoiPhoi_tiktok.lua
-- Stage 1: clean TikTok + TikTok Lite, then open AppStore TikTok link
-- Created by OpenClaw/Cún

screen.init(0)

local SCRIPT_VERSION = "NuoiPhoi_TikTok_Stage1_v1"
local BASE_DIR = "/var/mobile/Media/1ferver/lua/examples/"
local OC_STATUS_PATH = BASE_DIR .. "oc_status.txt"
local APPSTORE_TIKTOK_URL = "https://apps.apple.com/jp/app/tiktok-global-video-community/id1235601864?l=en-US"

local APPS = {
    { name = "TikTok",      bid = "com.ss.iphone.ugc.Ame" },
    { name = "TikTok Lite", bid = "com.ss.iphone.ugc.tiktok.lite" },
}

local function sleep(ms)
    sys.msleep(ms)
end

local function write_status(msg)
    local line = tostring(os.time()) .. "|" .. tostring(msg or "")
    local f = io.open(OC_STATUS_PATH, "w")
    if f then
        f:write(line)
        f:close()
    end
end

local function log(msg)
    msg = tostring(msg or "")
    pcall(function() sys.log("[" .. SCRIPT_VERSION .. "] " .. msg) end)
    pcall(function() write_status(msg) end)
    pcall(function() sys.toast(msg, 0) end)
end

local function safe_step(label, fn)
    log(label)
    local ok, ret = pcall(fn)
    if ok then
        log(label .. " -> OK: " .. tostring(ret))
        sleep(500)
        return true, ret
    else
        log(label .. " -> ERR: " .. tostring(ret))
        sleep(1000)
        return false, ret
    end
end

local function quit_app(appInfo)
    safe_step("Quit " .. appInfo.name, function()
        return app.quit(appInfo.bid)
    end)
    sleep(800)
end

local function clear_app(appInfo)
    local name = appInfo.name
    local bid = appInfo.bid

    safe_step(name .. " | clear.keychain", function()
        return clear.keychain(bid)
    end)

    safe_step(name .. " | clear.cookies", function()
        return clear.cookies(bid)
    end)

    safe_step(name .. " | clear.caches", function()
        return clear.caches(bid)
    end)

    safe_step(name .. " | clear.app_data", function()
        return clear.app_data(bid)
    end)

    -- global/device-level cleanup; called per requested flow
    safe_step(name .. " | clear.pasteboard", function()
        return clear.pasteboard()
    end)

    safe_step(name .. " | clear.idfav", function()
        return clear.idfav()
    end)

    safe_step(name .. " | final app.quit", function()
        return app.quit(bid)
    end)

    sleep(1000)
end

local function open_appstore_tiktok()
    safe_step("Open AppStore TikTok URL", function()
        return app.open_url(APPSTORE_TIKTOK_URL)
    end)
    sleep(5000)
end

-- =========================
-- MAIN: STAGE 1
-- =========================
log("START " .. SCRIPT_VERSION)

-- close both apps first
for _, appInfo in ipairs(APPS) do
    quit_app(appInfo)
end

sleep(1500)

-- clean both apps
for _, appInfo in ipairs(APPS) do
    clear_app(appInfo)
end

-- open AppStore TikTok link
open_appstore_tiktok()

log("STAGE 1 DONE")
return true
