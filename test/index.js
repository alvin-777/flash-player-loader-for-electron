var app = require('electron').app;
var BrowserWindow = require('electron').BrowserWindow;
require('colors');

var mainWindow = null;

app.on('window-all-closed', function() {
  app.quit();
});

// Load the module
var flashLoader = require('..');
// Using custom log functions to add extra prefixes and colours.
flashLoader.debug(
  console.log.bind(console, '[INFO] %s'.cyan),
  console.error.bind(console, '[ERROR] %s'.bold.red));
// Try to load Flash Player in the directory 'path_to_this_module/test/' first.
// To make it work you need to copy the Flash Player to the 'test' directory,
// or change the path to where your Flash Player file locates.
// If that fails, then try to find the system plug-in (OS X only).
// And then try to find the Chrome integrated plug-in (OS X only).
var pathToDirContainsFlashPlayer = __dirname;
flashLoader.addSource(pathToDirContainsFlashPlayer, '1.2.3.4');
flashLoader.addSource('@system');
flashLoader.addSource('@chrome');
flashLoader.load();

chromeFlashes = flashLoader.getAllChromeFlashVersions();
if (chromeFlashes.length > 0) {
  console.log('\nGoogle Chrome has Pepper Flash Players at:'.blue);
  chromeFlashes.forEach((cf) => console.log('>>'.blue, cf[0].yellow, cf[1].magenta));
}

// Alternatively, you can chain the methods together.
// require('..').debug().addSource('@system').addSource('@chrome').load();

app.on('ready', function() {
  mainWindow = new BrowserWindow({
    'width': 416,
    'height': 425,
    'web-preferences': {'plugins': true}  // Do not forget to add this option
                                          // when creating BrowserWindow
  });
  var url;
  url = 'file://' + __dirname + '/index.html';
  // Try the other links out!
  // url = 'http://www.adobe.com/software/flash/about/';
  // url = 'https://helpx.adobe.com/flash-player.html';
  mainWindow.loadURL(url);
});
