-- Restore RGB

if file.open("rgb", "r") then
  R = tonumber(file.readline())
  G = tonumber(file.readline())
  B = tonumber(file.readline())
  W = tonumber(file.readline())
  file.close()
  -- Initialize W in case it didn't exist. This would happen in case the state file is of old version
  if W==nil then W=1023 end

  -- Do not go "back to black"; go to white instead
  if R == 1023 and G == 1023 and B == 1023 and W == 1023 then R=0 G=0 B=0 W=0 end
  pwm.setup(5, 191, R)
  pwm.start(5)
  pwm.setup(6, 193, G)
  pwm.start(6)
  pwm.setup(7, 197, B)
  pwm.start(7)
  pwm.setup(2, 197, W)
  pwm.start(2)
end

function saveColor()
  local r = pwm.getduty(5)
  local g = pwm.getduty(6)
  local b = pwm.getduty(7)
  local w = pwm.getduty(2)
  if R ~= r or G ~= g or B ~= b or W ~= w then
    if file.open("rgb", "w") then
      file.writeline(r) R=r
      file.writeline(g) G=g
      file.writeline(b) B=b
      file.writeline(w) W=w
      file.close()
    end
  end
end

-- -- Begin WiFi configuration

local wifiConfig = {}

-- wifi.STATION         -- station: join a WiFi network
-- wifi.SOFTAP          -- access point: create a WiFi network
-- wifi.wifi.STATIONAP  -- both station and access point
wifiConfig.mode = wifi.STATION  -- both station and access point

wifiConfig.accessPointConfig = {}
wifiConfig.accessPointConfig.ssid = "ESP-"..node.chipid()   -- Name of the SSID you want to create
wifiConfig.accessPointConfig.pwd = "ESP-"..node.chipid()    -- WiFi password - at least 8 characters

wifiConfig.accessPointIpConfig = {}
wifiConfig.accessPointIpConfig.ip = "192.168.111.1"
wifiConfig.accessPointIpConfig.netmask = "255.255.255.0"
wifiConfig.accessPointIpConfig.gateway = "192.168.111.1"

wifiConfig.stationPointConfig = {}
wifiConfig.stationPointConfig.ssid = "dsl"        -- Name of the WiFi network you want to join
wifiConfig.stationPointConfig.pwd =  "0xdeadbeef"                -- Password for the WiFi network

-- Tell the chip to connect to the access point

wifi.setmode(wifiConfig.mode)
print('set (mode='..wifi.getmode()..')')

if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
    print('AP MAC: ',wifi.ap.getmac())
    wifi.ap.config(wifiConfig.accessPointConfig)
    wifi.ap.setip(wifiConfig.accessPointIpConfig)
end
if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
    print('Client MAC: ',wifi.sta.getmac())
    wifi.sta.config(wifiConfig.stationPointConfig)
end

print('chip: ',node.chipid())
print('heap: ',node.heap())

wifiConfig = nil
collectgarbage()

-- End WiFi configuration

-- Compile server code and remove original .lua files.
-- This only happens the first time afer the .lua files are uploaded.

local compileAndRemoveIfNeeded = function(f)
  if file.open(f) then
    file.close()
    print('Compiling:', f)
    node.compile(f)
    file.remove(f)
    collectgarbage()
  end
end

local serverFiles = {'httpserver.lua'}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil
collectgarbage()

-- Connect to the WiFi access point.
-- Once the device is connected, you may start the HTTP server.

if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then
  local joinCounter = 0
  local joinMaxAttempts = 5
  local t = tmr.create()
  t:alarm(3000, tmr.ALARM_AUTO, function()
    local ip = wifi.sta.getip()
    if ip == nil and joinCounter < joinMaxAttempts then
      print('Connecting to WiFi Access Point ...')
      joinCounter = joinCounter +1
    else
      if joinCounter == joinMaxAttempts then
         print('Failed to connect to WiFi Access Point.')
      else
        print('IP: ',ip)
        dofile("httpserver.lc")(80)
      end
      t:unregister()
      joinCounter = nil
      joinMaxAttempts = nil
      collectgarbage()

      t:alarm(5000, tmr.ALARM_AUTO, saveColor)
    end
  end
  )
end

-- Uncomment to automatically start the server in port 80
if (not not wifi.sta.getip()) or (not not wifi.ap.getip()) then
  --dofile("httpserver.lc")(80)
end

function ls()
  for k,v in pairs(file.list()) do print(k,v) end
end
