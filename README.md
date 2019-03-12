# Small HTTP server for NodeMCU
This small webserver supports the following HTTP verbs/methods:
* GET returns the contents of a file in flash
* PUT creates a new file in flash
* DELETE remove the file from flash
* POST executes the given lua script (may return a function that receives the payload)
* OPTIONS returns minimal CORS headers allowing POST from any origin

## Development
This project uses *direnv* and *nix*. Use `direnv allow` to be dropped into a shell with Python and other dependencies available.

The dependencies `esptool` and `nodemcu-uploader` are included as git submodules. Use `--recursive` during cloning to get the submodules, or do:
```
$ git submodule init
$ git submodule update
```

## Flash NodeMCU
This project requires NodeMCU (integer version) and needs at least the following modules: `adc`, `file`, `net`, `node`, `pwm`, `timer`, `wifi`. Get it from https://nodemcu-build.com

To flash a new firmware, pull GPIO0 to GND (or press the PROGRAM button, if any) while turning the ESP8266 ON.
This will start the ESP in flash mode. Connect TX and RX to a serial cable and use `esptool` to flash the firmware, for example:
```
$ esptool/esptool.py write_flash 0x00000 nodemcu-1.5.4.1-final-9-modules-2019-03-12-11-50-48-integer.bin
```
Add `--baud 115200` or `--port /dev/tty.usbmodem14101` (for example) to specify the baudrate and serial device, respectively.

## Installation
Clone the project and edit the Wi-Fi settings in `init.lua`. You can use the shell script `up` or execute the following:
```
$ python nodemcu-uploader/nodemcu-uploader.py upload init.lua httpserver.lua rgb.lua index.html
```
After uploading, connect the serial console (`screen /dev/ttyUSB0 9600` under most unix flavors) and reboot the device. The device will print its IP address in the console.

## Usage
Once those files have been uploaded you can manage your device with `curl`, for example to PUT new files on flash:
```
curl --upload-file example.lua http://serial.console.shows.ip/
```

To reboot your device (for example after uploading a new `init.lua` or `httpserver.lua`) use `curl` to POST anything to `/`:
```
curl --data anything http://serial.console.shows.ip/
```

## TODO
* Need a way to return flash contents/listing vs. `index.html`
