return function (connection, req)
  local ms = tonumber(req:match("ms=([0-9]+)"))
  if not ms then
    if lastms then ms=5 lastms=nil else ms=0 lastms=true end
  end

  connection:send("HTTP/1.0 302 Found\r\nLocation: /\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n"..ms)
  connection:close()

  tmr.stop(0)
  tmr.stop(1)
  if ms > 0 then
    saveColor()
    local lastdelta = 0;
    local setduty = pwm.setduty

    local function sample()
      local delta = 1024 - adc.read(0)
      if delta < lastdelta - 10 then delta = lastdelta - 10 end
      if delta ~= lastdelta then
        lastdelta = delta
        local a = R + delta
        if a > 1023 then a = 1023 end
        setduty(5, a)
        a = G + delta
        if a > 1023 then a = 1023 end
        setduty(6, a)
        a = B + delta
        if a > 1023 then a = 1023 end
        setduty(7, a)
      end
      --connection:send(delta..",\n")
    end

    tmr.alarm(1, ms, 1, sample)
  else
    -- Restore the old color
    pwm.setduty(5, R)
    pwm.setduty(6, G)
    pwm.setduty(7, B)
    tmr.alarm(0, 5000, 1, saveColor)
  end
end
