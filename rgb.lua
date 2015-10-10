return function (connection, req)
   local arg = tonumber(req:match("r=([0-9]+)"));
   if arg then
     pwm.setduty(5, arg);
   end

   local arg = tonumber(req:match("g=([0-9]+)"));
   if arg then
     pwm.setduty(6, arg);
   end

   local arg = tonumber(req:match("b=([0-9]+)"));
   if arg then
     pwm.setduty(7, arg);
   end

   -- Send back JSON response.
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n")
   connection:send('{"error":0, "message":"OK"}')
   connection:close()
end
