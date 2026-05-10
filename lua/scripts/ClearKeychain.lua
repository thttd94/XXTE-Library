screen.init(0)

local SCRIPT_VERSION = "TT_TL_CLEAR_ALL_COMMANDS_V2"

local APPS = {
  { name = "TikTok Lite", bid = "com.ss.iphone.ugc.tiktok.lite" },
  { name = "TikTok",      bid = "com.ss.iphone.ugc.Ame" },
}

local function sleep(ms)
  sys.msleep(ms)
end

local function log(s)
  sys.log("[" .. SCRIPT_VERSION .. "] " .. tostring(s))
end

local function status(t)
  local msg = "Ver " .. SCRIPT_VERSION .. " : " .. tostring(t)
  sys.toast(msg, 0)
  log(t)
end

local function runStep(appName, name, fn)
  status(appName .. " | " .. name)
  local ok, ret = pcall(fn)
  if ok then
    log(appName .. " | " .. name .. " OK: " .. tostring(ret))
    sleep(900)
    return true
  else
    log(appName .. " | " .. name .. " ERR: " .. tostring(ret))
    status(appName .. " | " .. name .. " ERR")
    sleep(1200)
    return false
  end
end

local function clearOne(appInfo)
  local appName = appInfo.name
  local bid = appInfo.bid

  status("Quit " .. appName)
  pcall(function() app.quit(bid) end)
  sleep(1500)

  runStep(appName, "clear.keychain", function()
    return clear.keychain(bid)
  end)

  runStep(appName, "clear.all_keychain", function()
    return clear.all_keychain()
  end)

  runStep(appName, "clear.pasteboard", function()
    return clear.pasteboard()
  end)

  runStep(appName, "clear.cookies", function()
    return clear.cookies(bid)
  end)

  runStep(appName, "clear.caches", function()
    return clear.caches(bid)
  end)

  runStep(appName, "clear.app_data", function()
    return clear.app_data(bid)
  end)

  runStep(appName, "clear.idfav", function()
    return clear.idfav()
  end)

  status(appName .. " DONE")
  sleep(1000)
end

status("START clear TikTok Lite + TikTok")
for _, appInfo in ipairs(APPS) do
  clearOne(appInfo)
end
status("ALL DONE")
return true
