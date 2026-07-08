screen.init(0)
local __WEBVIEW_STATUS_TEXT = "Nhập TK Đang chạy ..."
local __ok_webview_status, __webview_status = pcall(require, "webview")
local __WEBVIEW_STATUS_ID = 88
local __WEBVIEW_STATUS_HTML = [[
<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><style>
html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,sans-serif;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
#bar{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.58);color:#fff;border-radius:12px;font-size:17px;font-weight:700;text-align:center;white-space:nowrap;box-sizing:border-box}
</style></head><body><div id="bar">Nhập TK Đang chạy ...</div></body></html>
]]
function show_webview_status()
 if __ok_webview_status and __webview_status and type(__webview_status.show) == "function" then
  pcall(__webview_status.show, { id = __WEBVIEW_STATUS_ID, html = __WEBVIEW_STATUS_HTML, x = 1, y = 1, width = 748, height = 38, alpha = 1.0, corner_radius = 12, opaque = false, can_drag = false, ignores_hit = true })
 end
end
show_webview_status()
function __oc_toast_replacement(text, ...) if type(oc_status) == "function" then pcall(oc_status, __WEBVIEW_STATUS_TEXT) end; show_webview_status(); return nil end
sys = sys or {}
if not sys.msleep then pcall(function() sys = require("sys") end) end
sys["toast"] = __oc_toast_replacement

local BIN_DIR = "/var/mobile/Media/1ferver/res"
local TIKTOK_DIR = BIN_DIR .. "/Tiktok"
local LITE_DIR = BIN_DIR .. "/Tiktok Lite"

local function q(s) return "'" .. tostring(s):gsub("'", "'\\''") .. "'" end
local ok_lfs,lfs=pcall(require,"lfs")
local ok_file,file=pcall(require,"file")
local function mkdirp(p)
  local cur=""
  for part in tostring(p or ""):gmatch("[^/]+") do
    cur=cur.."/"..part
    if ok_lfs and lfs and lfs.mkdir then pcall(lfs.mkdir,cur) end
    if ok_file and file and file.mkdir then pcall(file.mkdir,cur) end
  end
  pcall(function() os.execute("mkdir -p " .. q(p) .. " 2>/dev/null") end)
end
local function status(t, holdMs) show_webview_status(); if sys and sys.msleep then sys.msleep(holdMs or 1200) end end
local function readAll(path) local f=io.open(path,"rb"); if not f then return nil end; local d=f:read("*a"); f:close(); return d end
local function writeAll(path,data) mkdirp((path:match("^(.+)/[^/]+$") or BIN_DIR)); local f=io.open(path,"wb"); if not f then return false end; f:write(data); f:close(); return true end
local function resolveGlob(pattern)
  local p=io.popen("echo " .. tostring(pattern) .. " 2>/dev/null")
  if not p then return nil end
  local out=p:read("*l") or ""
  p:close()
  if out=="" or string.find(out,"*",1,true) then return nil end
  return string.match(out,"^([^%s]+)")
end
local function findDataDir(plistName)
  local patterns={
    "/private/var/mobile/Containers/Data/Application/*/Library/Preferences/"..plistName,
    "/var/mobile/Containers/Data/Application/*/Library/Preferences/"..plistName,
  }
  for _,pat in ipairs(patterns) do
    local plist=resolveGlob(pat)
    if plist then return plist:match("^(.+)/Library/Preferences/[^/]+$") end
  end
  return nil
end
local function findAppGroupFile(fileName)
  local patterns={
    "/private/var/mobile/Containers/Shared/AppGroup/*/"..fileName,
    "/var/mobile/Containers/Shared/AppGroup/*/"..fileName,
  }
  for _,pat in ipairs(patterns) do local f=resolveGlob(pat); if f then return f end end
  return nil
end

local SCRIPT_VERSION = "Session Import 4.0 Tiktok+Lite"
mkdirp(TIKTOK_DIR); mkdirp(LITE_DIR)

local function importPath(label, src, dst)
  local data=readAll(src)
  if not data then status(label .. " nguồn miss", 1500); return false end
  if not writeAll(dst,data) then status(label .. " write lỗi", 1500); return false end
  status(label .. " OK", 700); return true
end

local okMain=0
local mainDir=findDataDir("com.ss.iphone.ugc.Ame.plist")
if mainDir then
  if importPath("Tiktok cookies", TIKTOK_DIR.."/Cookies.binarycookies", mainDir.."/Library/Cookies/Cookies.binarycookies") then okMain=okMain+1 end
  if importPath("Tiktok archiver", TIKTOK_DIR.."/ttaccountSDKUserInfo.archiver", mainDir.."/Documents/ttaccountSDKUserInfo.archiver") then okMain=okMain+1 end
  if importPath("Tiktok plist", TIKTOK_DIR.."/com.ss.iphone.ugc.Ame.plist", mainDir.."/Library/Preferences/com.ss.iphone.ugc.Ame.plist") then okMain=okMain+1 end
else
  status("Tiktok data miss", 1200)
end
local secDst=findAppGroupFile("sec_uid_storage_file")
if secDst and importPath("Tiktok sec_uid", TIKTOK_DIR.."/sec_uid_storage_file", secDst) then okMain=okMain+1 end

local okLite=0
local liteDir=findDataDir("com.ss.iphone.ugc.tiktok.lite.plist")
if liteDir then
  if importPath("Lite cookies", LITE_DIR.."/Cookies.binarycookies", liteDir.."/Library/Cookies/Cookies.binarycookies") then okLite=okLite+1 end
  if importPath("Lite archiver", LITE_DIR.."/ttaccountSDKUserInfo.archiver", liteDir.."/Documents/ttaccountSDKUserInfo.archiver") then okLite=okLite+1 end
  if importPath("Lite plist", LITE_DIR.."/com.ss.iphone.ugc.tiktok.lite.plist", liteDir.."/Library/Preferences/com.ss.iphone.ugc.tiktok.lite.plist") then okLite=okLite+1 end
else
  status("Lite data miss", 1200)
end

os.execute("killall -9 cfprefsd 2>/dev/null || true; sync")
status("Xong Tiktok "..tostring(okMain).."/4 Lite "..tostring(okLite).."/3", 500)
show_webview_status()
if sys and type(sys.alert)=="function" then
  sys.alert("Nhập TK OK\nTiktok: "..tostring(okMain).."/4\nTiktok Lite: "..tostring(okLite).."/3")
else
  status("Nhập TK OK - Tiktok "..tostring(okMain).."/4 Lite "..tostring(okLite).."/3", 10000)
end
