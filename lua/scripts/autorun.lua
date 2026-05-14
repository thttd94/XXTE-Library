app = require("app")
device = require("device")
sys = require("sys")
touch = require("touch")
file = require("file")
screen = require("screen")

screen.init(0)

while (device.is_screen_locked()) do
 device.unlock_screen()
 sys.msleep(1000)
end

app.run("com.apple.springboard")
sys.toast("HOME_OK_1")
print("HOME_OK_1")

-- Bước 4: chờ 1 giây
sys.msleep(2000)

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
sys.msleep(1500)
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

local function isColorSet1Visible()
 local x, y = screen.find_color({
  {175, 561, 0x000000},
  {585, 563, 0x000000},
  {341, 615, 0x000000},
  {269, 792, 0x007aff},
  {508, 784, 0x007aff},
 }, 95, 0, 0, 0, 0)

 return x ~= -1 and y ~= -1
end

local function isColorSet2Visible()
 local x, y = screen.find_color({
  {65, 138, 0x007aff},
  {634, 140, 0x007aff},
  {612, 142, 0x007aff},
 }, 95, 0, 0, 0, 0)

 return x ~= -1 and y ~= -1
end

local function step17()
 -- Bước 17: đợi 3s rồi tap tọa độ 200,415
 sys.msleep(3000)
 touch.tap(200, 415)
 print("TAP_200_415")
end

local function waitColorSet1AndTap()
 -- Bước 18: đợi bộ màu thứ nhất xuất hiện.
 -- Nếu xuất hiện thì tap 505,789.
 -- Nếu không xuất hiện trong 10s thì dừng vòng lặp.
 local startWait = sys.mtime()

 while sys.mtime() - startWait < 10000 do
  if isColorSet1Visible() then
   print("FOUND_COLOR_SET_1")
   touch.tap(505, 789)
   print("TAP_505_789")
   return true
  end

  sys.msleep(500)
 end

 print("COLOR_SET_1_NOT_FOUND_STOP")
 return false
end

local function waitColorSet2Stable3sWithin10s()
 -- Sau khi tap 505,789: đợi tối đa 10s cho bộ màu thứ 2 xuất hiện.
 -- Khi xuất hiện, phải giữ/xuất hiện liên tục đủ 3s thì mới tap 80,142.
 local startWait = sys.mtime()
 local stableStart = nil

 while sys.mtime() - startWait < 10000 do
  if isColorSet2Visible() then
   if stableStart == nil then
    stableStart = sys.mtime()
    print("COLOR_SET_2_APPEARED")
   end

   if sys.mtime() - stableStart >= 3000 then
    print("COLOR_SET_2_STABLE_3S")
    return true
   end
  else
   if stableStart ~= nil then
    print("COLOR_SET_2_DISAPPEARED_RESET")
   end
   stableStart = nil
  end

  sys.msleep(300)
 end

 print("COLOR_SET_2_NOT_STABLE_3S_IN_10S")
 return false
end

while true do
 step17()

 -- Lặp lại bước 17 cho tới khi điểm ảnh/bộ màu ở bước 18 không còn xuất hiện thì dừng.
 if not waitColorSet1AndTap() then
  break
 end

 if waitColorSet2Stable3sWithin10s() then
  touch.tap(80, 142)
  print("TAP_80_142")

  -- Đợi 3s rồi quay lại bước 17.
  sys.msleep(3000)
 else
  break
 end
end

return true
