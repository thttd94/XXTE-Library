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

-- Bước 7 mới: ưu tiên mở Lid Copy. Nếu mở được app này thì bỏ qua load cookie Safari.
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
 local cookiePath = safariPath .. "/Library/Cookies/Cookies.binarycookies"
 local backupPath = safariPath .. "/Library/Cookies/Cookies_backup.binarycookies"

 -- Backup file cookie cũ
 if file.exists(cookiePath) then
  local old = file.reads(cookiePath)
  if old then
   file.writes(backupPath, old)
  end
 end

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

local function isDoneColorVisible()
 local x, y = screen.find_color({
  {568,296,0x7e7e80},
  {569,293,0x7e7e80},
  {570,289,0x7e7e80},
  {572,285,0x7e7e80},
  {576,277,0x7e7e80},
  {578,281,0x7e7e80},
  {581,289,0x7e7e80},
  {576,290,0x7e7e80},
  {583,294,0x7e7e80},
  {588,292,0x7e7e80},
  {588,288,0x7e7e80},
  {591,284,0x909092},
  {594,282,0x7e7e80},
  {599,284,0x7e7e80},
  {599,294,0x7e7e80},
  {605,281,0x929193},
  {608,281,0x7e7e80},
  {612,281,0x929193},
  {608,278,0x7e7e80},
  {607,284,0x7e7e80},
  {607,290,0x7e7e80},
  {609,296,0x7e7e80},
  {611,296,0x7e7e80},
  {629,296,0x7e7e80},
  {631,294,0x7e7e80},
  {632,288,0x818183},
  {634,285,0x7e7e80},
  {624,283,0x7e7e80},
  {625,288,0x7e7e80},
  {668,288,0x7e7e80},
  {671,288,0x969597},
  {676,288,0x969597},
  {679,286,0x7e7e80},
  {674,282,0x7e7e80},
  {677,296,0x7e7e80},
  {674,297,0x7e7e80},
  {686,292,0x7e7e80},
  {691,297,0x7e7e80},
  {698,292,0x7e7e80},
  {697,288,0x7e7e80},
  {697,278,0x7e7e80},
  {557,322,0x7e7e80},
  {568,323,0x7e7e80},
  {569,329,0x818183},
  {568,335,0x7e7e80},
  {564,340,0x7e7e80},
  {561,340,0x7e7e80},
  {635,333,0x7e7e80},
  {654,323,0x7e7e80},
  {653,322,0x7e7e80},
  {647,319,0x7e7e80},
  {643,321,0x7e7e80},
  {642,324,0x7e7e80},
  {642,329,0x7e7e80},
  {645,334,0x7e7e80},
  {650,334,0x7e7e80},
  {653,332,0x7e7e80},
  {658,327,0x99989a},
  {662,321,0x7e7e80},
  {667,320,0x7e7e80},
  {671,324,0x7e7e80},
  {671,329,0x7e7e80},
  {667,334,0x7e7e80},
  {663,332,0xfcfbfc},
  {661,332,0x7e7e80},
  {699,328,0x818183},
  {699,330,0x818183},
  {699,333,0x818183},
  {698,334,0x7e7e80},
 },95,0,0,0,0)
 return x ~= -1 and y ~= -1
end

local function findLogoutColor()
 local x, y = screen.find_color({
  {264,652,0xe74c3c},
  {264,658,0xe74c3c},
  {264,669,0xe74c3c},
  {264,672,0xe74c3c},
  {268,672,0xe74c3c},
  {273,671,0xe74c3c},
  {285,672,0xe74c3c},
  {292,665,0xe74c3c},
  {285,657,0xe74c3c},
  {279,664,0xe74c3c},
  {298,662,0xe74c3c},
  {304,657,0xe74c3c},
  {310,660,0xe74c3c},
  {310,673,0xe74c3c},
  {304,677,0xe74c3c},
  {336,669,0xe74c3c},
  {346,658,0xe74c3c},
  {355,657,0xe74c3c},
  {355,663,0xe74c3c},
  {357,672,0xe74e3e},
  {375,665,0xe74c3c},
  {385,665,0xe74c3c},
  {379,665,0xe74c3c},
  {380,652,0xe74c3c},
  {397,657,0xe74c3c},
  {392,664,0xe74c3c},
  {402,671,0xe74c3c},
  {409,666,0xe74c3c},
  {415,657,0xe74c3c},
  {420,669,0xe74c3c},
  {427,663,0xe74c3c},
  {433,657,0xe74c3c},
  {439,662,0xe74c3c},
  {434,671,0xe74c3c},
  {457,667,0xe74c3c},
  {456,659,0xe74c3c},
  {482,657,0xe74c3c},
  {483,669,0xe74c3c},
 },95,0,0,0,0)
 if x ~= -1 and y ~= -1 then return true, x, y end
 return false, -1, -1
end

local function doNewTapSequence(closeAfterFirst)
 touch.tap(303, 420)
 print("TAP_303_420")
 sys.msleep(1500)
 touch.tap(481, 794)
 print("TAP_481_794")
 if closeAfterFirst then
  sys.msleep(1000)
  touch.tap(37, 145)
  print("TAP_37_145")
  sys.msleep(3000)
 end
end

doNewTapSequence(true)

while true do
 doNewTapSequence(false)

 -- Không chờ cứng 5s rồi check một lần nữa, vì máy lag dễ ra chậm và bị miss.
 -- Chờ vô hạn tới khi gặp OK; nếu gặp logout thì xử lý rồi quay lại lượt tap/check mới.
 while true do
  if isDoneColorVisible() then
   print("FOUND_DONE_COLOR_OK")
   return true
  end

  local logoutOk, logoutX, logoutY = findLogoutColor()
  if logoutOk then
   print("FOUND_LOGOUT_COLOR_TAP_264_652")
   touch.tap(264, 652)
   print("TAP_LOGOUT_264_652")
   sys.msleep(3000)
   break
  end

  sys.msleep(500)
 end
end
