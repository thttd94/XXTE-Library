local BID = "com.brd.earnapp"

local INFO_PATH  = "/var/mobile/Media/1ferver/eapp_watchdog_info.json"
local STATE_PATH = "/var/mobile/Media/1ferver/eapp_watchdog_state.json"
local LOG_PATH   = "/var/mobile/Media/1ferver/eapp_watchdog.log"

local CHECK_INTERVAL_MS = 10000
local RESTART_WAIT_MS = 5000
local STARTUP_OCR_WINDOW_SECONDS = 60
local ERROR_OCR_INTERVAL_SECONDS = 30 * 60
local BRDSDK_CLEAN_INTERVAL_SECONDS = 20 * 60 * 60
local START_STUCK_SECONDS = 60

local app = require("app")
local sys = require("sys")
local screen = require("screen")
local touch = require("touch")

local restart_count = 0
local loop_count = 0
local last_action = "start"
local last_reason = ""
local last_front_bid = ""
local last_user = "Loading..."
local last_total = "Loading..."
local last_wan = "Loading..."
local last_run_ts = os.time()
local last_error_ocr_ts = 0
local last_brdsdk_clean_ts = os.time()
local start_seen_since = nil

local function now_s()
  return os.time()
end

local function msleep(ms)
  sys.msleep(ms)
end

local function esc(s)
  s = tostring(s or "")
  s = s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r')
  return s
end

local function log(msg)
  local f = io.open(LOG_PATH, "a")
  if f then
    f:write(os.date("%Y-%m-%d %H:%M:%S"), " ", tostring(msg or ""), "\n")
    f:close()
  end
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return "" end
  local s = f:read("*a") or ""
  f:close()
  return s
end

local function write_file(path, s)
  local f = io.open(path, "w")
  if f then
    f:write(s or "")
    f:close()
  end
end

local function json_get(txt, key)
  txt = tostring(txt or "")
  key = tostring(key or "")
  local pat = '"' .. key .. '"%s*:%s*"(.-)"'
  local v = txt:match(pat)
  if v then return v end
  local pat2 = '"' .. key .. '"%s*:%s*([%d%.%-]+)'
  v = txt:match(pat2)
  if v then return v end
  return nil
end

local function load_info()
  local txt = read_file(INFO_PATH)
  if txt ~= "" then
    local u = json_get(txt, "user") or json_get(txt, "email")
    local t = json_get(txt, "total") or json_get(txt, "account_balance")
    local ip = json_get(txt, "wan") or json_get(txt, "ip") or json_get(txt, "ea_wan_ip")
    if u and u ~= "" then last_user = u end
    if t and t ~= "" then
      local s = tostring(t)
      local n = tonumber((s:gsub('%s*%$%s*$', '')))
      if n then
        last_total = string.format("%.2f $", n)
      elseif s:find('%$') then
        last_total = s
      else
        last_total = s .. " $"
      end
    end
    if ip and ip ~= "" then last_wan = ip end
  end
end

local function write_state()
  local js = string.format(
    '{"ts":%d,"time":"%s","bundle":"%s","front_bid":"%s","user":"%s","total":"%s","wan":"%s","action":"%s","reason":"%s","restart_count":%d,"loop_count":%d}',
    now_s(),
    esc(os.date("%Y-%m-%d %H:%M:%S")),
    esc(BID),
    esc(last_front_bid),
    esc(last_user),
    esc(last_total),
    esc(last_wan),
    esc(last_action),
    esc(last_reason),
    restart_count,
    loop_count
  )
  write_file(STATE_PATH, js)
end

local function top_html()
  return [[
<html><head><meta name="viewport" content="width=device-width, initial-scale=1">
<style>
html,body{margin:0;padding:0;background:rgba(0,0,0,.88);color:#fff;font-family:-apple-system,Arial;font-size:18px;font-weight:700;overflow:hidden;}
.box{padding:7px 12px;line-height:1.28;}
.ok{color:#54ff7a}.label{color:#ffd166}.v{color:#fff}
</style></head><body><div class="box">
<div class="ok">Script &#273;ang ch&#7841;y...</div>
<div><span class="label">User :</span> <span class="v">]] .. esc(last_user) .. [[</span></div>
<div><span class="label">Total :</span> <span class="v">]] .. esc(last_total) .. [[</span></div>
<div><span class="label">IP:</span> <span class="v">]] .. esc(last_wan) .. [[</span></div>
</div></body></html>]]
end

local function update_top_webview()
  local w, h = 750, 1334
  pcall(function()
    if screen and type(screen.size) == "function" then
      local sw, sh = screen.size()
      if sw and sh then w, h = sw, sh end
    end
  end)
  pcall(function()
    webview.show{
      html = top_html(),
      x = 0,
      y = 0,
      width = w,
      height = 250,
      corner_radius = 0,
      alpha = 0.95,
      animation_duration = 0,
      level = 999999,
      opaque = false,
      ignores_hit = true,
      can_drag = false,
    }
  end)
end

local function front_bid()
  local ok, bid = pcall(app.front_bid)
  if ok and bid then return tostring(bid) end
  return ""
end

local function ocr_region(x, y, w, h)
  if not screen or type(screen.ocr_text) ~= "function" then return "" end
  local texts = {}
  local calls = {
    function() return screen.ocr_text(x, y, x + w, y + h) end,
    function() return screen.ocr_text{ x = x, y = y, width = w, height = h } end,
  }
  for _, fn in ipairs(calls) do
    local ok, res = pcall(fn)
    if ok and res then
      if type(res) == "table" then
        for _, v in pairs(res) do texts[#texts + 1] = tostring(v or "") end
      else
        texts[#texts + 1] = tostring(res or "")
      end
    end
  end
  return table.concat(texts, " "):lower()
end

local function ocr_error_ssl_region()
  -- Vung popup SSL/Error theo Anh Thai: x 315-430, y 551-616. Them margin nho de lech may van bat duoc.
  local txt = ocr_region(290, 520, 180, 130)
  if txt:find("error", 1, true) or txt:find("ssl", 1, true) or txt:find("certificate", 1, true) or txt:find("cert", 1, true) then
    return true, txt
  end
  return false, txt
end

local function ocr_continue_start_startup()
  -- Chi quet trong 60s dau sau app.run/restart. Khong dung trong trang thai on dinh de tranh nong may.
  local txt1 = ocr_region(0, 730, 750, 604)
  if txt1:find("continue", 1, true) and (txt1:find("earning", 1, true) or txt1:find("earn", 1, true)) then
    return "continue", txt1
  end
  local txt2 = ocr_region(0, 980, 750, 354)
  if txt2:find("start", 1, true) then
    return "start", txt2
  end
  return nil, txt1 .. " " .. txt2
end

local function tap_continue_earning_button()
  local sw, sh = 750, 1334
  pcall(function()
    if screen and type(screen.size) == "function" then
      local w, h = screen.size()
      if w and h then sw, sh = w, h end
    end
  end)
  local x = math.floor(sw / 2)
  local y = math.floor(sh * 0.935)
  pcall(touch.tap, x, y)
  return x, y
end

local function clean_brdsdk_logs()
  local ok, earnPath = pcall(function()
    return app.data_path(BID)
  end)
  if not ok or not earnPath or earnPath == "" then
    log("clean brdsdk skipped: no data path")
    return false
  end

  local brdsdkPath = earnPath .. "/Library/Application Support/brdsdk"
  local cmd =
    'BASE="' .. brdsdkPath .. '"; ' ..
    'if [ ! -d "$BASE" ]; then echo NO_BRDSDK; exit 0; fi; ' ..
    'for x in "$BASE"/*; do ' ..
    'case "$x" in "$BASE/db") echo KEEP_DB ;; *) rm -rf "$x"; echo RM "$x" ;; esac; ' ..
    'done; ' ..
    'if [ -d "$BASE/db" ]; then echo DB_EXISTS; else echo DB_MISSING; fi'

  pcall(function() app.quit(BID) end)
  msleep(1500)

  local f = io.popen(cmd .. " 2>&1")
  local out = ""
  if f then
    out = f:read("*a") or ""
    f:close()
  end

  log("clean brdsdk path=" .. brdsdkPath .. " result=" .. out:gsub("\n", " | "))
  pcall(app.run, BID)
  last_run_ts = now_s()
  return true
end

local function restart_earnapp(reason)
  last_action = "restart"
  last_reason = tostring(reason or "")
  restart_count = restart_count + 1
  start_seen_since = nil
  log("restart EarnApp reason=" .. last_reason)
  write_state()

  pcall(app.quit, BID)
  msleep(RESTART_WAIT_MS)
  pcall(app.run, BID)
  last_run_ts = now_s()
end

log("EApp watchdog optimized started BID=" .. BID)
load_info()
update_top_webview()
write_state()

while true do
  loop_count = loop_count + 1
  load_info()
  update_top_webview()

  local bid = front_bid()
  last_front_bid = bid

  if bid ~= BID then
    restart_earnapp("front_bid=" .. tostring(bid ~= "" and bid or "unknown"))
  else
    local ts = now_s()
    local since_run = ts - last_run_ts
    local handled = false

    -- Continue/Start OCR chi trong 60s dau sau app.run/restart.
    if since_run <= STARTUP_OCR_WINDOW_SECONDS then
      local kind, txt = ocr_continue_start_startup()
      if kind == "continue" then
        local cx, cy = tap_continue_earning_button()
        start_seen_since = nil
        last_action = "tap_continue"
        last_reason = "startup OCR Continue earning tap at " .. tostring(cx) .. "," .. tostring(cy)
        log(last_reason)
        write_state()
        handled = true
      elseif kind == "start" then
        if not start_seen_since then start_seen_since = ts end
        local stuck_s = ts - start_seen_since
        if stuck_s >= START_STUCK_SECONDS then
          restart_earnapp("startup OCR Start stuck " .. tostring(stuck_s) .. "s")
          handled = true
        else
          last_action = "wait_start"
          last_reason = "startup Start OCR seen " .. tostring(stuck_s) .. "s/" .. tostring(START_STUCK_SECONDS) .. "s"
          write_state()
          handled = true
        end
      else
        start_seen_since = nil
      end
    end

    -- Error/SSL OCR: chi quet vung nho moi 30 phut/lần, khong quet full man hinh.
    if not handled and (ts - last_brdsdk_clean_ts >= BRDSDK_CLEAN_INTERVAL_SECONDS) then
      last_brdsdk_clean_ts = ts
      last_action = "clean_brdsdk"
      last_reason = "auto clean brdsdk every 20h"
      write_state()
      clean_brdsdk_logs()
      handled = true
    end

    if not handled and (ts - last_error_ocr_ts >= ERROR_OCR_INTERVAL_SECONDS) then
      last_error_ocr_ts = ts
      local hit, txt = ocr_error_ssl_region()
      if hit then
        restart_earnapp("30m small-region OCR Error/SSL")
        handled = true
      end
    end

    if not handled then
      last_action = "ok"
      last_reason = ""
      write_state()
    end
  end

  msleep(CHECK_INTERVAL_MS)
end
