var app = require('electron').app;
var BrowserWindow = require('electron').BrowserWindow;
var path = require('path');
var flashLoader = require('..');

var mainWindow = null;

app.on('window-all-closed', function() {
  app.quit();
});

var ppapi_flash_path = path.join(__dirname, flashLoader.FLASH_PLAYER_FILENAME);
flashLoader.addSource(ppapi_flash_path);
flashLoader.addSource('@chrome');
flashLoader.addSource('@system');

app.on('ready', function() {
  mainWindow = new BrowserWindow({
    'width': 800,
    'height': 600,
    'web-preferences': {'plugins': true}
  });
  mainWindow.loadURL('http://www.adobe.com/software/flash/about/');
});
