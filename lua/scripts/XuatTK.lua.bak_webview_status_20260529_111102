screen.init(0)

local SCRIPT_VERSION = "Session Export 3.1"

local OUT_COOKIES = "/var/mobile/Media/1ferver/archives/tiktok_main_cookies.binarycookies"
local OUT_ARCHIVER = "/var/mobile/Media/1ferver/archives/tiktok_main_ttaccountSDKUserInfo.archiver"
local OUT_SECUID = "/var/mobile/Media/1ferver/archives/tiktok_main_sec_uid_storage_file"
local OUT_PLIST = "/var/mobile/Media/1ferver/archives/tiktok_main_com.ss.iphone.ugc.Ame.plist"

local function status(t, holdMs)
  sys.toast("Ver " .. SCRIPT_VERSION .. " : " .. t, 0)
  sys.msleep(holdMs or 1800)
end

local function readAll(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local data = f:read("*a")
  f:close()
  return data
end

local function writeAll(path, data)
  local f = io.open(path, "wb")
  if not f then return false end
  f:write(data)
  f:close()
  return true
end

local function resolveGlob(pattern)
  local p = io.popen("echo " .. pattern)
  if not p then return nil end
  local out = p:read("*l") or ""
  p:close()
  if out == "" or string.find(out, "*", 1, true) then return nil end
  return string.match(out, "^([^%s]+)")
end

local function exportOne(label, patterns, outPath)
  local src = nil
  for _, pattern in ipairs(patterns) do
    src = resolveGlob(pattern)
    if src then break end
  end
  if not src then status(label .. " miss", 2600) return false end

  local data = readAll(src)
  if not data then status(label .. " read lỗi", 2600) return false end
  if not writeAll(outPath, data) then status(label .. " write lỗi", 2600) return false end
  status(label .. " OK", 2200)
  return true
end

local ok = 0
if exportOne("cookies", {
  "/private/var/mobile/Containers/Data/Application/*/Library/Cookies/Cookies.binarycookies",
  "/var/mobile/Containers/Data/Application/*/Library/Cookies/Cookies.binarycookies"
}, OUT_COOKIES) then ok = ok + 1 end
if exportOne("archiver", {
  "/private/var/mobile/Containers/Data/Application/*/Documents/ttaccountSDKUserInfo.archiver",
  "/var/mobile/Containers/Data/Application/*/Documents/ttaccountSDKUserInfo.archiver"
}, OUT_ARCHIVER) then ok = ok + 1 end
if exportOne("sec_uid", {
  "/private/var/mobile/Containers/Shared/AppGroup/*/sec_uid_storage_file",
  "/var/mobile/Containers/Shared/AppGroup/*/sec_uid_storage_file"
}, OUT_SECUID) then ok = ok + 1 end
if exportOne("plist", {
  "/private/var/mobile/Containers/Data/Application/*/Library/Preferences/com.ss.iphone.ugc.Ame.plist",
  "/var/mobile/Containers/Data/Application/*/Library/Preferences/com.ss.iphone.ugc.Ame.plist"
}, OUT_PLIST) then ok = ok + 1 end

status("Xong " .. tostring(ok) .. "/4", 5000)
