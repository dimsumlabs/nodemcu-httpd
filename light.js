var HOSTS = [
  'helios2.lan',
  'helios.lan'
];
var host = HOSTS[0];

var canvas = document.getElementById('colorspace');
var btn1 = document.getElementById('btn-1');
var btn2 = document.getElementById('btn-2');
var ctx = canvas.getContext('2d');

drawCanvas();

function changeHost(id) {
  this.host = HOSTS[id];
  if(id) {
    btn1.disabled = false;
    btn2.disabled = true;
  } else {
    btn1.disabled = true;
    btn2.disabled = false;
  }
}

function sendColour(rgb) {
  var params = [
    'r=' + rgb[0],
    'g=' + rgb[1],
    'b=' + rgb[2]
  ].join('&');

  var req = new XMLHttpRequest();
  console.log(params);
  req.open("POST", 'http://' + host + '/rgb.lua?' + params, true);
  req.send();
}

function colourCorrect(v) {
  return Math.round(1023-(v*v)/64);
}

function handleEvent(clientX, clientY) {
  var data = ctx.getImageData(clientX, clientY, 1, 1).data;
  var rgb = [];
  for(var i=0; i<3; i++) {
    rgb[i] = colourCorrect(data[i]);
  }
  sendColour(rgb);
}

canvas.addEventListener("touchmove", function(event){
  handleEvent(event.touches[0].clientX, event.touches[0].clientY);
}, false);

var mouseDown = false;
document.ontouchmove = function(e) {e.preventDefault()};
canvas.addEventListener('mousedown', function(event) {
  if (event.button == 0) {
    handleEvent(event.x, event.y);
    mouseDown = true;
  }
}, false);

document.addEventListener('mouseup', function(event) {
  if (event.button == 0) {
    mouseDown = false;
  }
}, false);

canvas.addEventListener('mousemove', function(event) {
  if (mouseDown) {
    handleEvent(event.x, event.y);
  }
}, false);

function drawCanvas(brightness = 100) {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  var brt = Math.round((brightness / 100) * 255);
  var colours = ctx.createLinearGradient(30, 0, canvas.width, 0);
  for(var i=0; i <= 360; i+=10) {
    colours.addColorStop(i/360, 'hsl(' + i + ', 100%, '+ brightness/2 + '%)');
  }

  ctx.fillStyle = colours;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  var luminance = ctx.createLinearGradient(0, 0, 0, canvas.height);
  luminance.addColorStop(0.0, 'rgba(' + brt + ',' + brt + ',' + brt + ',' + brightness/100 + ')');
  luminance.addColorStop(0.5, 'rgba(255,255,255,0)');
  luminance.addColorStop(0.5, 'rgba(0,0,0,0)');
  luminance.addColorStop(1,  '#000000');

  ctx.fillStyle = luminance;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

