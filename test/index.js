var app = require('electron').app;
var BrowserWindow = require('electron').BrowserWindow;
var path = require('path');
require('colors');

var mainWindow = null;

app.on('window-all-closed', function() {
  app.quit();
});

var flashLoader = require('..');
flashLoader.debug(
  console.log.bind(console, '[INFO] %s'.cyan),
  console.error.bind(console, '[ERROR] %s'.bold.red));
var ppapi_flash_path = path.join(__dirname);
flashLoader.addSource(ppapi_flash_path, '1.2.3.4');
flashLoader.addSource('@chrome');
flashLoader.addSource('@system');
flashLoader.load();

app.on('ready', function() {
  mainWindow = new BrowserWindow({
    'width': 416,
    'height': 380,
    'web-preferences': {'plugins': true}
  });
  var url;
  url = 'file://' + __dirname + '/index.html';
  // url = 'http://www.adobe.com/software/flash/about/';
  // url = 'https://helpx.adobe.com/flash-player.html';
  mainWindow.loadURL(url);
});
