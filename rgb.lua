return function (connection, req)
  local setduty = pwm.setduty

  local arg = tonumber(req:match("r=([0-9]+)"))
  if arg then
    setduty(5, arg)
  end

  arg = tonumber(req:match("g=([0-9]+)"))
  if arg then
    setduty(6, arg)
  end

  arg = tonumber(req:match("b=([0-9]+)"))
  if arg then
    setduty(7, arg)
  end

  arg = tonumber(req:match("w=([0-9]+)"))
  if arg then
    setduty(2, arg)
  end

  -- Send back JSON response.
  connection:on("sent", function(c)
      c:close()
  end
  )
  connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n{'error':0, 'message':'OK'}")
end
