app = require("app")
device = require("device")
sys = require("sys")
local __WEBVIEW_STATUS_TEXT = "Autorun Đang chạy ..."
local __ok_webview_status, __webview_status = pcall(require, "webview")
local __WEBVIEW_STATUS_ID = 88
local __WEBVIEW_STATUS_HTML = [[
<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><style>
html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,sans-serif;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
#bar{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.58);color:#fff;border-radius:12px;font-size:17px;font-weight:700;text-align:center;white-space:nowrap;box-sizing:border-box}
</style></head><body><div id="bar">Autorun Đang chạy ...</div></body></html>
]]
function show_webview_status()
 if __ok_webview_status and __webview_status and type(__webview_status.show) == "function" then
  pcall(__webview_status.show, { id = __WEBVIEW_STATUS_ID, html = __WEBVIEW_STATUS_HTML, x = 1, y = 1, width = 748, height = 38, alpha = 1.0, corner_radius = 12, opaque = false, can_drag = false, ignores_hit = true })
 end
end
show_webview_status()
function __oc_toast_replacement(text, ...) if type(oc_status) == "function" then pcall(oc_status, __WEBVIEW_STATUS_TEXT) end; show_webview_status(); return nil end
sys = sys or {}
sys["toast"] = __oc_toast_replacement

touch = require("touch")
file = require("file")
screen = require("screen")

screen.init(0)



while (device.is_screen_locked()) do
 device.unlock_screen()
 sys.msleep(1000)
end

app.run("com.apple.springboard")
show_webview_status()
print("HOME_OK_1")

-- Bước 4: chờ 1 giây
sys.msleep(2000)

local function cleanSafariCookiesDir()
 local safariPath = app.data_path("com.apple.mobilesafari")
 if not safariPath or safariPath == "" then
  print("CLEAN_SAFARI_COOKIES_NO_SAFARI_PATH")
  return false
 end
 -- Chỉ dùng bundle id Safari để tìm đúng thư mục Cookies cần dọn.
 local cookieDir = safariPath .. "/Library/Cookies/"
 local okList, items = pcall(function() return file.list(cookieDir) end)
 if not okList or type(items) ~= "table" then
  print("CLEAN_SAFARI_COOKIES_LIST_ERR")
  return false
 end
 for _, name in pairs(items) do
  if name ~= "." and name ~= ".." then
   local path = cookieDir .. tostring(name)
   pcall(function() file.remove(path) end)
   pcall(function() os.remove(path) end)
   print("CLEAN_SAFARI_COOKIE_FILE_" .. tostring(name))
  end
 end
 print("CLEAN_SAFARI_COOKIES_DONE")
 return true
end

-- Bước 7 mới: ưu tiên mở Lid Copy. Nếu mở được app này thì bỏ qua load cookie Safari.
while true do
cleanSafariCookiesDir()
local lidcopyOpened = false
local okRunLidcopy = pcall(function()
 local r = app.run("com.local.lidcopy")
 if r == false or r == nil then
  lidcopyOpened = false
 else
  lidcopyOpened = true
 end
end)
if okRunLidcopy and lidcopyOpened then
 show_webview_status()
 print("OPEN_LIDCOPY_OK_SKIP_COOKIES")
 sys.msleep(3000)
else
 show_webview_status()
 print("OPEN_LIDCOPY_FAIL_LOAD_COOKIES")
 -- Load Cookies.binarycookies vào Safari
 local src = "/var/mobile/Media/1ferver/lua/examples/Cookies.binarycookies"

 local safariPath = app.data_path("com.apple.mobilesafari")
 local cookieDir = safariPath .. "/Library/Cookies/"
 local cookiePath = cookieDir .. "Cookies.binarycookies"

 -- Load cookie mới
 if file.exists(src) then
  local data = file.reads(src)
  if data then
   file.writes(cookiePath, data)
   show_webview_status()
   print("LOAD_COOKIES_OK")
  else
   show_webview_status()
   print("LOAD_COOKIES_READ_ERR")
  end
 else
  show_webview_status()
  print("LOAD_COOKIES_NOT_FOUND")
 end
end

touch.tap(381, 792)
sys.msleep(1500)
show_webview_status()
print("TAP_381_792")

sys.msleep(3000)

app.run("ch.xxtou.XXTExplorer")
show_webview_status()
print("OPEN_XXTOUCH")
sys.msleep(3000)

touch.tap(565, 1270)
print("TAP_565_1270_1")

sys.msleep(2000)
touch.tap(565, 1270)
print("TAP_565_1270_2")

sys.msleep(2000)
touch.tap(359, 1019)
print("TAP_359_1019")

local RES_DIR = "/var/mobile/Media/1ferver/lua/examples/"
local XXTE_SIGN_IMG = RES_DIR .. "XXTE_sign.PNG"
local XXTE_SIGN1_IMG = RES_DIR .. "XXTE_sign1.PNG"
local XXTE_ACTIVE1_IMG = RES_DIR .. "XXTE_active1.PNG"
local XXTE_ACTIVE2_IMG = RES_DIR .. "XXTE_active2.PNG"
local XXTE_PUCHAR_IMG = RES_DIR .. "XXTE_Puchar.png"

local function findImageAny(img, sim)
 local x, y = screen.find_image(img, sim or 82, 0, 0, 750, 1334)
 return x ~= -1 and y ~= -1, x, y
end

local function findImageAnyMulti(img)
 local sims = {88, 82, 76, 70}
 for _, sim in ipairs(sims) do
  local ok, x, y = findImageAny(img, sim)
  if ok then return true, x, y, sim end
 end
 return false, -1, -1, 0
end

local function waitImageForever(img, label, sim)
 while true do
  local ok, x, y = findImageAny(img, sim or 82)
  if ok then
   print("FOUND_" .. label)
   return x, y
  end
  show_webview_status()
  sys.msleep(500)
 end
end

local function tapUntilImageForever(tapX, tapY, img, label, sim)
 while true do
  local ok, x, y = findImageAny(img, sim or 82)
  if ok then
   print("FOUND_" .. label .. "_STOP_TAP")
   return x, y
  end
  print("TAP_UNTIL_" .. label .. "_" .. tostring(tapX) .. "_" .. tostring(tapY))
  touch.tap(tapX, tapY)
  show_webview_status()
  sys.msleep(800)
 end
end

local function waitSign1CaseFirst()
 -- Case 1 phải được xử lý trước. Chỉ nếu không thấy sign1 thì mới qua check case 2/3.
 local start = os.time()
 while os.time() - start < 8 do
  local sign1Ok = findImageAny(XXTE_SIGN1_IMG, 82)
  if sign1Ok then
   print("FOUND_XXTE_SIGN1_TAP_106_145")
   touch.tap(106, 145)
   sys.msleep(1500)
   return true
  end
  show_webview_status()
  sys.msleep(500)
 end
 print("NO_XXTE_SIGN1_PASS_CASE1")
 return false
end

local function checkActiveOrPucharOnce()
 local active1Ok, ax1, ay1, as1 = findImageAnyMulti(XXTE_ACTIVE1_IMG)
 local active2Ok, ax2, ay2, as2 = findImageAnyMulti(XXTE_ACTIVE2_IMG)
 if active1Ok and active2Ok then
  print("FOUND_XXTE_ACTIVE_DONE active1=" .. tostring(active1Ok) .. " sim1=" .. tostring(as1) .. " active2=" .. tostring(active2Ok) .. " sim2=" .. tostring(as2))
  return "active"
 end
 if active1Ok or active2Ok then
  print("PARTIAL_XXTE_ACTIVE active1=" .. tostring(active1Ok) .. " sim1=" .. tostring(as1) .. " active2=" .. tostring(active2Ok) .. " sim2=" .. tostring(as2))
 end

 local pucharOk = findImageAny(XXTE_PUCHAR_IMG, 82)
 if pucharOk then
  print("FOUND_XXTE_PUCHAR_TAP_359_923")
  touch.tap(359, 923)
  sys.msleep(500)
  return "puchar"
 end

 return "none"
end

local function waitActiveOrPucharConfirm()
 -- Sau khi case 1 đã qua, mới check case 2/3.
 local start = os.time()
 while os.time() - start < 30 do
  local case = checkActiveOrPucharOnce()
  if case ~= "none" then return case end
  show_webview_status()
  sys.msleep(700)
 end
 print("NO_ACTIVE_OR_PUCHAR_AFTER_30S_RETRY_STEP8")
 return "none"
end

local sign1RetryCount = 0
while true do
 print("STEP8_TAP_348_414_UNTIL_XXTE_SIGN")
 tapUntilImageForever(348, 414, XXTE_SIGN_IMG, "XXTE_SIGN", 82)
 print("TAP_498_789_AFTER_SIGN")
 touch.tap(498, 789)
 sys.msleep(500)

 local sign1Found = waitSign1CaseFirst()
 if sign1Found then
  sign1RetryCount = sign1RetryCount + 1
  if sign1RetryCount >= 3 then
   print("XXTE_SIGN1_3_TIMES_RESTART_FROM_STEP4")
   pcall(function() app.quit("ch.xxtou.XXTExplorer") end)
   sys.msleep(1500)
   sign1RetryCount = 0
   break
  end
 else
  -- Không thấy XXTE_sign1.PNG thì xem như đã qua case 1, rồi mới check case 2/3.
  sign1RetryCount = 0
  local case = waitActiveOrPucharConfirm()
  if case == "active" then
   print("AUTORUN_ACTIVE_DONE_STOP")
   return true
  elseif case == "puchar" then
   sign1RetryCount = 0
  elseif case == "none" then
   -- Không rơi vào case 2/3 thì lặp lại chu kỳ bước 8.
   sign1RetryCount = 0
  end
 end
end
end
