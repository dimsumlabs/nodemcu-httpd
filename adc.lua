return function (connection, req)
  local ms = tonumber(req:match("ms=([0-9]+)"))
  if ms then
    connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n")
    connection:close()

    tmr.stop(1)
    if ms > 0 then
      tmr.stop(0)
      saveColor()
      local last = 0;
      local setduty = pwm.setduty
      local function sample()
        local delta = 1024 - adc.read(0)
        if delta ~= last then
          last = delta
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
  else
    -- Send back JSON response.
    connection:send("HTTP/1.0 400 Bad Request\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n{'missing':'ms'}")
    connection:close()
  end
end
