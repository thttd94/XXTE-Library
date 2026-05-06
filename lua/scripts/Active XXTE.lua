app = require("app")
file = require("file")
sys = require("sys")

-- Nguồn cookie mới: file Cookies.binarycookies đặt sẵn trong thư mục examples của 1ferver
local src = "/var/mobile/Media/1ferver/lua/examples/Cookies.binarycookies"

local safariPath = app.data_path("com.apple.mobilesafari")
local cookiePath = safariPath .. "/Library/Cookies/Cookies.binarycookies"
local backupPath = safariPath .. "/Library/Cookies/Cookies_backup.binarycookies"

-- backup file cũ
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
        sys.alert("Load cookies xong\nNguồn: " .. src .. "\nĐích: " .. cookiePath)
    else
        sys.alert("Không đọc được file cookie nguồn:\n" .. src)
    end
else
    sys.alert("Không tìm thấy file cookie nguồn:\n" .. src)
end

return true
