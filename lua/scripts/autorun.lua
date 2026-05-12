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


sys.msleep(10000)
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

