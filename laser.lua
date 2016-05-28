-- Configure LASER control pin
gpio.mode(1, gpio.OUTPUT)

local rfid = "unknown"

local function laseron()
  print("laser on");
  gpio.write(1, gpio.HIGH)
end
local function laseroff()
  print("laser off");
  gpio.write(1, gpio.LOW)

  -- send OFF time to server
  local connection = net.createConnection(net.TCP, 0)
  local function onconnect(connection)
    connection:send("GET /api.php?off=1&group=laser&rfid="..rfid.." HTTP/1.1\r\nHost: door\r\nConnection: close\r\n\r\n")
    connection:close()
    connection = nil
  end
  connection:on("connection", onconnect)
  connection:connect(80, "door")
end
laseroff()

-- Configure card detect pin
gpio.mode(2, gpio.INPUT, gpio.PULLUP)
gpio.trig(2, "up", laseroff)

local function onrfid(data)
  local card = data:reverse():sub(2)
  local salt = "d51e10354f570d35a54d2bc2c01f5fcb8725fb0bf6a58c7db02c5379f81a8a76"
  rfid = crypto.toHex(crypto.hash("sha256",crypto.toHex(crypto.hash("sha256",card))..salt))
  print(rfid)
  if rfid == "5860f03f58d8b64a9f597dec1244ab2ff5d2f615791008b6a88a533b9436be10" then
    laseron()
  else
    -- Query the server for permission
    local connection = net.createConnection(net.TCP, 0)

    local function onreceive(connection, header)
      if header:sub(10, 11) == "20" then
        laseron()
      else
        laseroff()
      end
      connection:close()
      connection = nil
    end
    connection:on("receive", onreceive)

    local function onconnect(connection)
      connection:send("GET /api.php?group=laser&rfid="..rfid.." HTTP/1.1\r\nHost: door\r\nConnection: close\r\n\r\n")
    end
    connection:on("connection", onconnect)

    connection:connect(80, "door")
  end
end
uart.on("data", 9, onrfid, 0)

