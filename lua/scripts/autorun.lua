app = require("app")
device = require("device")
sys = require("sys")
touch = require("touch")

while (device.is_screen_locked()) do
    device.unlock_screen()
    sys.msleep(1000)
end

app.run("com.apple.springboard")
sys.toast("HOME_OK_1")
print("HOME_OK_1")

-- Sau Home lần đầu, đợi 3s rồi Home thêm lần nữa cho chắc
sys.msleep(3000)
app.run("com.apple.springboard")
sys.toast("HOME_OK_2")
print("HOME_OK_2")

-- Sau Home lần 2, đợi 10s rồi tap 381,792; các tiến trình sau vẫn tiếp tục
sys.msleep(10000)
touch.tap(381, 792)
sys.msleep(500)
sys.toast("Đã tap 381,792", 0)
print("TAP_381_792")

-- Đợi thêm cho đủ 5 phút sau khi về Home rồi mới mở XXTouch
sys.msleep((5 * 60 * 1000) - 10500)

app.run("ch.xxtou.XXTExplorer")
sys.toast("OPEN_XXTOUCH")
print("OPEN_XXTOUCH")

-- Mở app xong đợi 5s, tap 565,1270
sys.msleep(5000)
touch.tap(565, 1270)
print("TAP_565_1270_1")

-- Sau 2s tap lại 565,1270 lần nữa
sys.msleep(2000)
touch.tap(565, 1270)
print("TAP_565_1270_2")

-- Sau 2s tap 359,1019
sys.msleep(2000)
touch.tap(359, 1019)
print("TAP_359_1019")

-- Đợi 30s rồi đóng XXTouch
sys.msleep(30000)
app.close("ch.xxtou.XXTExplorer")
sys.toast("CLOSE_XXTOUCH")
print("CLOSE_XXTOUCH")
