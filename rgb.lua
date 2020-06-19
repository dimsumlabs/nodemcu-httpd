PIN_R = 5
PIN_G = 6
PIN_B = 7

FADE_MS = 8
INTERVAL = 5
getduty = pwm.getduty
setduty = pwm.setduty

function fade(pin, x, tid)
  local a = getduty(pin)
  local mult = 1
  if a>x then mult = -1 end

  tmr.alarm(tid, FADE_MS, tmr.ALARM_AUTO, function()
    if math.abs(x-a) <= INTERVAL then
      setduty(pin, x)
      tmr.unregister(tid)
    elseif a~=x then
      setduty(pin, a)
      a = a + (INTERVAL * mult)
    end
  end)
end

return function (connection, req)
  local r = tonumber(req:match("r=([0-9]+)"))
  local g = tonumber(req:match("g=([0-9]+)"))
  local b = tonumber(req:match("b=([0-9]+)"))

  if r then
    fade(PIN_R, r, 0)
  end

  if g then
    fade(PIN_G, g, 1)
  end

  if b then
    fade(PIN_B, b, 2)
  end

  -- Send back JSON response.
  connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n{'error':0, 'message':'OK'}")
  connection:close()
end
