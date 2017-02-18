PIN_R = 5
PIN_G = 6
PIN_B = 7

FADE_MS = 100

return function (connection, req)
  local getduty = pwm.getduty
  local setduty = pwm.setduty

  local arg = tonumber(req:match("r=([0-9]+)"))
  if arg then
    -- fade(getduty(PIN_R), arg, FADE_MS, function(val)
      setduty(PIN_R, arg)
    -- end)
  end

  arg = tonumber(req:match("g=([0-9]+)"))
  if arg then
    -- fade(getduty(PIN_G), arg, FADE_MS, function(val)
    var = arg
      setduty(PIN_G, arg)
    -- end)
  end

  arg = tonumber(req:match("b=([0-9]+)"))
  if arg then
    -- fade(getduty(PIN_B), arg, FADE_MS, function(val)
    var = arg
      setduty(PIN_B, arg)
    -- end)
  end

  -- Send back JSON response.
  connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n{'error':0, 'message':'OK'}")
  connection:close()
end

function fade(a, b, freq, callback)
  local inc = 10
  local timer = tmr.create()
  timer:alarm(30, tmr.ALARM_AUTO, function(timer)
    if a < b then
      callback(a)
      a = a + inc
    else
      callback(b)
      timer:unregister()
    end
  end)
end
