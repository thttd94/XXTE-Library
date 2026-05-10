screen.init(0)

local SCRIPT_VERSION = "Session Import 3.1"

local IN_COOKIES = "/var/mobile/Media/1ferver/archives/tiktok_main_cookies.binarycookies"
local IN_ARCHIVER = "/var/mobile/Media/1ferver/archives/tiktok_main_ttaccountSDKUserInfo.archiver"
local IN_SECUID = "/var/mobile/Media/1ferver/archives/tiktok_main_sec_uid_storage_file"
local IN_PLIST = "/var/mobile/Media/1ferver/archives/tiktok_main_com.ss.iphone.ugc.Ame.plist"

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

local function importFile(label, inPath, patterns)
  local data = readAll(inPath)
  if not data then status(label .. " nguồn miss", 3000) return false end
  local dst = nil
  for _, pattern in ipairs(patterns) do
    dst = resolveGlob(pattern)
    if dst then break end
  end
  if not dst then status(label .. " đích miss", 3000) return false end
  if not writeAll(dst, data) then status(label .. " write lỗi", 3000) return false end
  status(label .. " OK", 2200)
  return true
end

local function importIntoDir(label, inPath, dirPatterns, fileName)
  local data = readAll(inPath)
  if not data then status(label .. " nguồn miss", 3000) return false end
  local dir = nil
  for _, pattern in ipairs(dirPatterns) do
    dir = resolveGlob(pattern)
    if dir then break end
  end
  if not dir then status(label .. " thư mục miss", 3000) return false end
  if not writeAll(dir .. "/" .. fileName, data) then status(label .. " write lỗi", 3000) return false end
  status(label .. " OK", 2200)
  return true
end

local ok = 0
if importFile("cookies", IN_COOKIES, {
  "/private/var/mobile/Containers/Data/Application/*/Library/Cookies/Cookies.binarycookies",
  "/var/mobile/Containers/Data/Application/*/Library/Cookies/Cookies.binarycookies"
}) or importIntoDir("cookies", IN_COOKIES, {
  "/private/var/mobile/Containers/Data/Application/*/Library/Cookies",
  "/var/mobile/Containers/Data/Application/*/Library/Cookies"
}, "Cookies.binarycookies") then ok = ok + 1 end

if importFile("archiver", IN_ARCHIVER, {
  "/private/var/mobile/Containers/Data/Application/*/Documents/ttaccountSDKUserInfo.archiver",
  "/var/mobile/Containers/Data/Application/*/Documents/ttaccountSDKUserInfo.archiver"
}) or importIntoDir("archiver", IN_ARCHIVER, {
  "/private/var/mobile/Containers/Data/Application/*/Documents",
  "/var/mobile/Containers/Data/Application/*/Documents"
}, "ttaccountSDKUserInfo.archiver") then ok = ok + 1 end

if importFile("sec_uid", IN_SECUID, {
  "/private/var/mobile/Containers/Shared/AppGroup/*/sec_uid_storage_file",
  "/var/mobile/Containers/Shared/AppGroup/*/sec_uid_storage_file"
}) or importIntoDir("sec_uid", IN_SECUID, {
  "/private/var/mobile/Containers/Shared/AppGroup/*",
  "/var/mobile/Containers/Shared/AppGroup/*"
}, "sec_uid_storage_file") then ok = ok + 1 end

if importFile("plist", IN_PLIST, {
  "/private/var/mobile/Containers/Data/Application/*/Library/Preferences/com.ss.iphone.ugc.Ame.plist",
  "/var/mobile/Containers/Data/Application/*/Library/Preferences/com.ss.iphone.ugc.Ame.plist"
}) or importIntoDir("plist", IN_PLIST, {
  "/private/var/mobile/Containers/Data/Application/*/Library/Preferences",
  "/var/mobile/Containers/Data/Application/*/Library/Preferences"
}, "com.ss.iphone.ugc.Ame.plist") then ok = ok + 1 end

status("Xong " .. tostring(ok) .. "/4", 5000)
