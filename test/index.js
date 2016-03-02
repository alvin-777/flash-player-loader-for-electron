var app = require('electron').app;
var BrowserWindow = require('electron').BrowserWindow;
var path = require('path');
require('colors');

var mainWindow = null;

app.on('window-all-closed', function() {
  app.quit();
});

var flashLoader = require('..');
var ppapi_flash_path = path.join(__dirname, flashLoader.FLASH_PLAYER_FILENAME);
flashLoader.debug(true,
  console.log.bind(console, '[INFO] %s'.cyan),
  console.error.bind(console, '[ERROR] %s'.bold.red));
flashLoader.addSource(ppapi_flash_path);
flashLoader.addSource('@chrome');
flashLoader.addSource('@system');
flashLoader.load();

app.on('ready', function() {
  mainWindow = new BrowserWindow({
    'width': 800,
    'height': 600,
    'web-preferences': {'plugins': true}
  });
  mainWindow.loadURL('http://www.adobe.com/software/flash/about/');
});
