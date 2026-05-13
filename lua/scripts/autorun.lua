app = require("app")
device = require("device")
sys = require("sys")
touch = require("touch")
file = require("file")

while (device.is_screen_locked()) do
 device.unlock_screen()
 sys.msleep(1000)
end

app.run("com.apple.springboard")
sys.toast("HOME_OK_1")
print("HOME_OK_1")

-- Bước 4: chờ 5 giây
sys.msleep(5000)

-- Bước mới: load Cookies.binarycookies vào Safari
local src = "/var/mobile/Media/1ferver/lua/examples/Cookies.binarycookies"

local safariPath = app.data_path("com.apple.mobilesafari")
local cookiePath = safariPath .. "/Library/Cookies/Cookies.binarycookies"
local backupPath = safariPath .. "/Library/Cookies/Cookies_backup.binarycookies"

-- backup file cookie cũ
if file.exists(cookiePath) then
 local old = file.reads(cookiePath)
 if old then
  file.writes(backupPath, old)
 end
end

-- load cookie mới
if file.exists(src) then
 local data = file.reads(src)
 if data then
  file.writes(cookiePath, data)
  sys.toast("Load cookies xong", 0)
  print("LOAD_COOKIES_OK")
 else
  sys.toast("Không đọc được file cookie nguồn", 0)
  print("LOAD_COOKIES_READ_ERR")
 end
else
 sys.toast("Không tìm thấy file cookie nguồn", 0)
 print("LOAD_COOKIES_NOT_FOUND")
end

touch.tap(381, 792)
sys.msleep(500)
sys.toast("Đã tap 381,792", 0)
print("TAP_381_792")

sys.msleep(3000)

app.run("ch.xxtou.XXTExplorer")
sys.toast("OPEN_XXTOUCH")
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

return true
