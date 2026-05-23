-- Extract PNG assets embedded as base64 from TikTok Lite CampaignRootFolder JSON
-- Output: /var/mobile/Media/1ferver/lua/images/tiktok_lite_assets/

local app = require("app")
local sys = require("sys")
local file = require("file")

local BID_LITE = "com.ss.iphone.ugc.tiktok.lite"
local OUT_DIR = "/var/mobile/Media/1ferver/lua/images/tiktok_lite_assets"

local function toast(s)
    s = tostring(s or "")
    if sys and sys.toast then sys.toast(s, 1) end
    if nLog then pcall(nLog, s) end
end

local function exists(path)
    local f = io.open(path, "rb")
    if f then f:close(); return true end
    return false
end

local function mkdir_p(path)
    os.execute("mkdir -p " .. string.format("%q", path))
end

local function read_all(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
end

local function write_bin(path, data)
    local f = io.open(path, "wb")
    if not f then return false end
    f:write(data)
    f:close()
    return true
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64_decode(data)
    data = tostring(data or ''):gsub('%s', '')
    data = data:gsub('[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x,1,true)-1)
        for i=6,1,-1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function safe_name(s)
    s = tostring(s or "asset")
    s = s:gsub("[^%w%._%-]+", "_")
    if #s > 80 then s = s:sub(1,80) end
    if s == "" then s = "asset" end
    return s
end

local function shell_find_json(root)
    local cmd = "find " .. string.format("%q", root) .. " -type f \\( -name '*.json' -o -name '*.txt' \\) 2>/dev/null"
    local p = io.popen(cmd)
    local list = {}
    if p then
        for line in p:lines() do
            if line and line ~= "" then table.insert(list, line) end
        end
        p:close()
    end
    return list
end

local function get_data_path()
    -- XXTouch versions differ; try common APIs first, then broad container search.
    local candidates = {}
    if app then
        for _, fn in ipairs({"data_path", "dataPath", "container", "bundle_container"}) do
            if type(app[fn]) == "function" then
                local ok, p = pcall(app[fn], BID_LITE)
                if ok and p and tostring(p) ~= "" then table.insert(candidates, tostring(p)) end
            end
        end
    end

    -- Fallback: scan app containers for TikTok Lite CampaignRootFolder.
    local scan_cmd = "find /private/var/mobile/Containers/Data/Application /var/mobile/Containers/Data/Application -maxdepth 4 -type d -name CampaignRootFolder 2>/dev/null"
    local pp = io.popen(scan_cmd)
    if pp then
        for line in pp:lines() do
            if line and line ~= "" then
                local root = line:gsub("/Documents/CampaignRootFolder$", "")
                table.insert(candidates, root)
            end
        end
        pp:close()
    end

    -- Prefer path that actually has Documents/CampaignRootFolder.
    for _, p in ipairs(candidates) do
        if exists(p .. "/Documents/CampaignRootFolder") then return p end
    end
    return candidates[1]
end

local function extract_from_json(path, index)
    local s = read_all(path)
    if not s or #s == 0 then return 0 end

    local count = 0
    local campaign = path:match("CampaignRootFolder/([^/]+)/") or "root"
    local jsonname = path:match("([^/]+)$") or ("json" .. index)
    jsonname = jsonname:gsub("%.json$", "")

    -- Pattern 1: data:image/png;base64,...
    for b64 in s:gmatch("data:image/png;base64,([A-Za-z0-9+/=]+)") do
        count = count + 1
        local data = base64_decode(b64)
        if data and #data > 20 and data:sub(1,8) == "\137PNG\r\n\026\n" then
            local out = OUT_DIR .. "/" .. safe_name(campaign .. "_" .. jsonname .. "_png_" .. count .. ".png")
            write_bin(out, data)
        end
    end

    -- Pattern 2: sometimes escaped data URL in JSON
    for b64 in s:gmatch("data:image%%/png;base64,([A-Za-z0-9+/=]+)") do
        count = count + 1
        local data = base64_decode(b64)
        if data and #data > 20 and data:sub(1,8) == "\137PNG\r\n\026\n" then
            local out = OUT_DIR .. "/" .. safe_name(campaign .. "_" .. jsonname .. "_png_" .. count .. ".png")
            write_bin(out, data)
        end
    end

    -- Save interesting JSON path list hints
    if s:find("受け取る", 1, true) or s:lower():find("claim", 1, true) or s:lower():find("coin", 1, true) or s:lower():find("reward", 1, true) then
        local hint = OUT_DIR .. "/_interesting_json_paths.txt"
        local f = io.open(hint, "a")
        if f then f:write(path .. "\n"); f:close() end
    end

    return count
end

mkdir_p(OUT_DIR)
local data_root = get_data_path()
if not data_root then
    toast("Khong tim thay data TikTok Lite")
    return
end

toast("TikTok Lite data: " .. data_root)
local campaign_root = data_root .. "/Documents/CampaignRootFolder"
local search_root = exists(campaign_root) and campaign_root or data_root
local jsons = shell_find_json(search_root)

toast("Dang quet " .. #jsons .. " JSON/TXT")
local total = 0
for i, p in ipairs(jsons) do
    total = total + extract_from_json(p, i)
    if i % 20 == 0 then toast("Da quet " .. i .. "/" .. #jsons .. ", asset " .. total) end
end

toast("Xong: " .. total .. " PNG -> " .. OUT_DIR)
